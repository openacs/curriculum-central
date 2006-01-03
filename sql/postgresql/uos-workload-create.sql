--
-- packages/curriculum-central/sql/postgresql/uos-workload-create.sql
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
	''cc_uos_workload'',				-- object_type
	''#curriculum-central.uos_workload#'',		-- pretty_name
	''#curriculum-central.uos_workload#'',		-- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_workload'',				-- table_name
	''workload_id'',				-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS workload as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                -- parent_type 
    'cc_uos_workload',         -- child_type
    'generic',               -- relation_tag
    0,                       -- min_n
    null                     -- max_n
);


-- content_item subtype
create table cc_uos_workload (
	workload_id		integer
                        	constraint cc_uos_workload_workload_id_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_workload_workload_id_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS workload content_revision
create table cc_uos_workload_revisions (
	workload_revision_id	integer
				constraint cc_uos_workload_rev_pk
				primary key
				constraint cc_uos_workload_rev_fk
				references cr_revisions(revision_id)
				on delete cascade,
	formal_contact_hrs	varchar(128),
	informal_study_hrs   	varchar(128),
	student_commitment	text,
	expected_feedback	text,
	student_feedback	text
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_workload_revision',
    'content_revision',
    '#curriculum-central.uos_workload_revision#',
    '#curriculum-central.uos_workload_revisions#',
    'cc_uos_workload_revisions',
    'workload_revision_id',
    'content_revision.revision_name'
);

-- Register UoS workload revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',		-- parent_type 
    'cc_uos_workload_revision',	-- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);

select define_function_args('cc_uos_workload__new', 'workload_id,parent_uos_id,formal_contact_hrs,informal_study_hrs,student_commitment,expected_feedback,student_feedback,creation_user,creation_ip,context_id,item_subtype;cc_uos_workload,content_type;cc_uos_workload_revision,object_type,package_id');

create function cc_uos_workload__new(
	integer,	-- workload_id
	integer,	-- parent_uos_id
	varchar,	-- formal_contact_hrs
	varchar,	-- informal_study_hrs
	text,		-- student_commitment
	text,		-- expected_feedback
	text,		-- student_feedback
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer,	-- context_id
	varchar,	-- item_subtype
	varchar,	-- content_type
	varchar,	-- object_type
	integer		-- package_id
) returns integer as'
declare

	p_workload_id			alias for $1;
	p_parent_uos_id			alias for $2;
	p_formal_contact_hrs		alias for $3;
	p_informal_study_hrs		alias for $4;
	p_student_commitment		alias for $5;
	p_expected_feedback		alias for $6;
	p_student_feedback		alias for $7;
	p_creation_user			alias for $8;
	p_creation_ip			alias for $9;
	p_context_id			alias for $10;
	p_item_subtype			alias for $11;
	p_content_type			alias for $12;
	p_object_type			alias for $13;
	p_package_id			alias for $14;

	v_workload_id			cc_uos_workload.workload_id%TYPE;
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
	-- There should only be one workload content item for each
	-- parent UoS.
	v_name := ''uos_workload_for_'' || p_parent_uos_id;

	-- create the content item
	v_workload_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_workload_id,		-- item_id
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
	v_revision_id := cc_uos_workload_revision__new (
		null,				-- workload_revision_id
		v_workload_id,			-- workload_id
		p_formal_contact_hrs,		-- formal_contact_hrs
		p_informal_study_hrs,		-- informal_study_hrs
		p_student_commitment,		-- student_commitment
		p_expected_feedback,		-- expected_feedback
		p_student_feedback,		-- student_feedback
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	insert into cc_uos_workload (workload_id, parent_uos_id,
	    latest_revision_id)
	VALUES (v_workload_id, p_parent_uos_id, v_revision_id);


	-- associate the UoS workload with the parent UoS
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
      		v_rel_id, p_parent_uos_id, v_workload_id, ''cc_uos_workload''
  	);

	return v_workload_id;

end;
' language plpgsql;


select define_function_args('cc_uos_workload__delete', 'workload_id');

create function cc_uos_workload__delete (integer)
returns integer as '
declare
	p_workload_id			alias for $1;
begin

	perform content_item__delete(p_workload_id);

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_workload_revision__new (
	integer,			-- workload_revision_id
	integer,			-- workload_id
	varchar,			-- formal_contact_hrs
	varchar,			-- informal_study_hrs
	text,				-- student_commitment
	text,				-- expected_feedback
	text,				-- student_feedback
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_workload_revision_id			alias for $1;
	p_workload_id				alias for $2;
	p_formal_contact_hrs			alias for $3;
	p_informal_study_hrs			alias for $4;
	p_student_commitment			alias for $5;
	p_expected_feedback			alias for $6;
	p_student_feedback			alias for $7;
	p_creation_date				alias for $8;
	p_creation_user				alias for $9;
	p_creation_ip				alias for $10;

	v_revision_id			integer;
	v_title				varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_workload#'',	-- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_workload_id,				-- item_id
		p_workload_revision_id,			-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- Insert into the uos-specific revision table
	INSERT into cc_uos_workload_revisions
		(workload_revision_id, formal_contact_hrs, informal_study_hrs,
		student_commitment, expected_feedback, student_feedback)
	VALUES
		(v_revision_id, p_formal_contact_hrs, p_informal_study_hrs,
		p_student_commitment, p_expected_feedback, p_student_feedback);

	-- Update the latest revision id in cc_uos_workload
	UPDATE cc_uos_workload SET latest_revision_id = v_revision_id
	WHERE workload_id = p_workload_id;

	return v_revision_id;
end;
' language 'plpgsql';
