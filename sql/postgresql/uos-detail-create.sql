--
-- packages/curriculum-central/sql/postgresql/uos-detail-create.sql
--
-- @author Nick Carroll (nick.c@rroll.net)
-- @creation-date 2005-11-16
-- @cvs-id $Id$
--
--


create function inline_0 ()
returns integer as'
begin 
    PERFORM acs_object_type__create_type (
	''cc_uos_detail'',				-- object_type
	''#curriculum-central.uos_detail#'',		-- pretty_name
	''#curriculum-central.uos_details#'',		-- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_detail'',				-- table_name
	''detail_id'',					-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS detail as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                -- parent_type 
    'cc_uos_detail',         -- child_type
    'generic',               -- relation_tag
    0,                       -- min_n
    null                     -- max_n
);


-- content_item subtype
create table cc_uos_detail (
	detail_id		integer
                        	constraint cc_uos_detail_detail_id_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_detail_detail_id_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS Detail content_revision
create table cc_uos_detail_revisions (
	detail_revision_id	integer
				constraint cc_uos_detail_rev_pk
				primary key
				constraint cc_uos_detail_rev_detail_rev_id_fk
				references cr_revisions(revision_id)
				on delete cascade,
	lecturer_ids		varchar(256),
	tutor_ids		varchar(256),
	objectives		text,
	learning_outcomes	text,
	syllabus		text,
	relevance		text,
	online_course_content 	varchar(256),
	note			text
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_detail_revision',
    'content_revision',
    '#curriculum-central.uos_detail_revision#',
    '#curriculum-central.uos_detail_revisions#',
    'cc_uos_detail_revisions',
    'detail_revision_id',
    'content_revision.revision_name'
);

-- Register UoS detail revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',		-- parent_type 
    'cc_uos_detail_revision',	-- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);

select define_function_args('cc_uos_detail__new', 'detail_id,parent_uos_id,lecturer_ids,tutor_ids,objectives,learning_outcomes,syllabus,relevance,online_course_content,note,creation_user,creation_ip,context_id,item_subtype;cc_uos_detail,content_type;cc_uos_detail_revision,object_type,package_id');

create function cc_uos_detail__new(
	integer,	-- detail_id
	integer,	-- parent_uos_id
	varchar,	-- lecturer_ids
	varchar,	-- tutor_ids
	text,		-- objectives
	text,		-- learning_outcomes
	text,		-- syllabus
	text,		-- relevance
	varchar,	-- online_course_content
	text,		-- note
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer,	-- context_id
	varchar,	-- item_subtype
	varchar,	-- content_type
	varchar,	-- object_type
	integer		-- package_id
) returns integer as'
declare

	p_detail_id			alias for $1;
	p_parent_uos_id			alias for $2;
	p_lecturer_ids			alias for $3;
	p_tutor_ids			alias for $4;
	p_objectives			alias for $5;
	p_learning_outcomes		alias for $6;
	p_syllabus			alias for $7;
	p_relevance			alias for $8;
	p_online_course_content		alias for $9;
	p_note				alias for $10;
	p_creation_user			alias for $11;
	p_creation_ip			alias for $12;
	p_context_id			alias for $13;
	p_item_subtype			alias for $14;
	p_content_type			alias for $15;
	p_object_type			alias for $16;
	p_package_id			alias for $17;

	v_detail_id			cc_uos_detail.detail_id%TYPE;
	v_folder_id			integer;
	v_revision_id			integer;
	v_name				varchar;
	v_rel_id			integer;
begin
	-- get the content folder for this instance
	select folder_id into v_folder_id
	    from cc_curriculum
	    where curriculum_id = p_package_id;

	-- Create a unique name
	v_name := ''uos_detail_for_'' || p_parent_uos_id;

	-- create the content item
	v_detail_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_detail_id,		-- item_id
		null,			-- locale
		now(),			-- creation_date
		p_creation_user,	-- creation_user
		v_folder_id,		-- context_id
		p_creation_ip,		-- creation_ip
		p_item_subtype,		-- item_subtype
		p_content_type,		-- content_type
		null,			-- title
		null,			-- description
		null,			-- mime_type
		null,			-- nls_language
		null,			-- data
		p_package_id
	);

	-- create the initial revision
	v_revision_id := cc_uos_detail_revision__new (
		null,				-- detail_revision_id
		v_detail_id,			-- detail_id
		p_lecturer_ids,			-- lecturer_ids
		p_tutor_ids,			-- tutor_ids
		p_objectives,			-- objectives
		p_learning_outcomes,		-- learning_outcomes
		p_syllabus,			-- syllabus
		p_relevance,			-- relevance
		p_online_course_content,	-- online_course_content
		p_note,				-- note
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	insert into cc_uos_detail (detail_id, parent_uos_id,
	    latest_revision_id)
	VALUES (v_detail_id, p_parent_uos_id, v_revision_id);


	-- associate the UoS detail with the parent UoS
	v_rel_id := acs_object__new(
		NULL,
      		''cr_item_child_rel'',
      		current_timestamp,
      		p_creation_user,
      		p_creation_ip,
      		p_package_id
	);

  	insert into cr_child_rels (
      		rel_id, parent_id, child_id, relation_tag
      	) values (
      		v_rel_id, p_parent_uos_id, v_detail_id, ''cc_uos_detail''
  	);	

	return v_detail_id;

end;
' language plpgsql;


select define_function_args('cc_uos_detail__delete', 'detail_id');

create function cc_uos_detail__delete (integer)
returns integer as '
declare
	p_detail_id			alias for $1;
begin

	perform content_item__delete(p_detail_id);	

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_detail_revision__new (
	integer,			-- detail_revision_id
	integer,			-- detail_id
	varchar,			-- lecturer_ids
	varchar,			-- tutor_ids
	text,				-- objectives
	text,				-- learning_outcomes
	text,				-- syllabus
	text,				-- relevance
	varchar,			-- online_course_content
	text,				-- note
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_detail_revision_id			alias for $1;
	p_detail_id				alias for $2;
	p_lecturer_ids				alias for $3;
	p_tutor_ids				alias for $4;
	p_objectives				alias for $5;
	p_learning_outcomes			alias for $6;
	p_syllabus				alias for $7;
	p_relevance				alias for $8;
	p_online_course_content			alias for $9;
	p_note					alias for $10;
	p_creation_date				alias for $11;
	p_creation_user				alias for $12;
	p_creation_ip				alias for $13;

	v_revision_id			integer;
	v_title				varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_detail#'',	-- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_detail_id,				-- item_id
		p_detail_revision_id,			-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- Insert into the uos-specific revision table
	INSERT into cc_uos_detail_revisions
		(detail_revision_id, lecturer_ids, tutor_ids, objectives,
		learning_outcomes, syllabus, relevance, online_course_content,
		note)
	VALUES
		(v_revision_id, p_lecturer_ids, p_tutor_ids, p_objectives,
		p_learning_outcomes, p_syllabus, p_relevance,
		p_online_course_content, p_note);

	-- Update the latest revision id in cc_uos_detail
	UPDATE cc_uos_detail SET latest_revision_id = v_revision_id
	WHERE detail_id = p_detail_id;

	return v_revision_id;
end;
' language 'plpgsql';
