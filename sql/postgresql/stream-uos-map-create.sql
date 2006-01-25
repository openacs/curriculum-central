--
-- packages/curriculum-central/sql/postgresql/stream-uos-map-create.sql
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
	''cc_stream_uos_map'',				-- object_type
	''#curriculum-central.stream_uos_map#'',	-- pretty_name
	''#curriculum-central.stream_uos_maps#'',	-- pretty_plural
	''acs_object'',					-- supertype
	''cc_stream_uos_map'',				-- table_name
	''map_id'',					-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- content_item subtype
create table cc_stream_uos_map (
	map_id			integer
                        	constraint cc_stream_uos_map_map_id_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_stream_uos_map_map_id_pk
				primary key,
	stream_id		integer,
	uos_id			integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the content_revision
create table cc_stream_uos_map_rev (
	map_rev_id		integer
				constraint cc_stream_uos_map_rev_pk
				primary key
				constraint cc_stream_uos_map_rev_rev_id_fk
				references cr_revisions(revision_id)
				on delete cascade,
	year_id			integer,
	semester_ids		varchar(256),
	core_id			integer,      -- core, elective, or recommended
	prerequisite_ids	varchar(256),
	assumed_knowledge_ids	varchar(256),
	corequisite_ids		varchar(256),
	prohibition_ids		varchar(256),
	no_longer_offered_ids	varchar(256)
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_stream_uos_map_rev',
    'content_revision',
    '#curriculum-central.stream_uos_map_revision#',
    '#curriculum-central.stream_uos_map_revisions#',
    'cc_stream_uos_map_rev',
    'map_rev_id',
    'content_revision.revision_name'
);


select define_function_args('cc_stream_uos_map__new', 'map_id,stream_id,uos_id,year_id,semester_ids,core_id,prerequisite_ids,assumed_knowledge_ids,corequisite_ids,prohibition_ids,no_longer_offered_ids,creation_user,creation_ip,context_id,item_subtype;cc_stream_uos_map,content_type;cc_stream_uos_map_rev,object_type,package_id');

create function cc_stream_uos_map__new(
	integer,	-- map_id
	integer,	-- stream_id
	integer,	-- uos_id
	integer,	-- year_id
	varchar,	-- semester_ids
	integer,	-- core_id
	varchar,	-- prerequisite_ids
	varchar,	-- assumed_knowledge_ids
	varchar,	-- corequisite_ids
	varchar,	-- prohibition_ids
	varchar,	-- no_longer_offered_ids
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer,	-- context_id
	varchar,	-- item_subtype
	varchar,	-- content_type
	varchar,	-- object_type
	integer		-- package_id
) returns integer as'
declare

	p_map_id			alias for $1;
	p_stream_id			alias for $2;
	p_uos_id			alias for $3;
	p_year_id			alias for $4;
	p_semester_ids			alias for $5;
	p_core_id			alias for $6;
	p_prerequisite_ids		alias for $7;
	p_assumed_knowledge_ids		alias for $8;
	p_corequisite_ids		alias for $9;
	p_prohibition_ids		alias for $10;
	p_no_longer_offered_ids		alias for $11;
	p_creation_user			alias for $12;
	p_creation_ip			alias for $13;
	p_context_id			alias for $14;
	p_item_subtype			alias for $15;
	p_content_type			alias for $16;
	p_object_type			alias for $17;
	p_package_id			alias for $18;

	v_map_id			cc_stream_uos_map.map_id%TYPE;
	v_folder_id			integer;
	v_revision_id			integer;
	v_name				varchar;
	v_rel_id			integer;
	v_unique_val			integer;
begin
	-- get the content folder for this instance
	select folder_id into v_folder_id
	    from cc_curriculum
	    where curriculum_id = p_package_id;

	-- Create a unique name
        select nextval
        into   v_unique_val
        from   acs_object_id_seq;

	v_name := ''map_uos_'' || p_uos_id || ''_to_stream_''
		|| p_stream_id || ''_'' || v_unique_val;

	-- create the content item
	v_map_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_map_id,		-- item_id
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
	v_revision_id := cc_stream_uos_map_rev__new (
		null,				-- revision_id
		v_map_id,			-- map_id
		p_year_id,			-- year_id
		p_semester_ids,			-- semester_ids
		p_core_id,			-- core_id
		p_prerequisite_ids,		-- requisite_ids
		p_assumed_knowledge_ids,	-- assumed_knowledge_ids
		p_corequisite_ids,		-- corequisite_ids
		p_prohibition_ids,		-- prohibition_ids
		p_no_longer_offered_ids,	-- no_longer_offered_ids
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	insert into cc_stream_uos_map (map_id, stream_id, uos_id,
	    latest_revision_id)
	VALUES (v_map_id, p_stream_id, p_uos_id, v_revision_id);

	return v_map_id;

end;
' language plpgsql;


select define_function_args('cc_stream_uos_map__delete', 'map_id');

create function cc_stream_uos_map__delete (integer)
returns integer as '
declare
	p_map_id			alias for $1;
begin

	perform content_item__delete(p_map_id);	

	delete from cc_stream_uos_map where map_id = p_map_id;

	return 0;

end;
' language 'plpgsql';


create or replace function cc_stream_uos_map_rev__new (
	integer,			-- revision_id
	integer,			-- map_id
	integer,			-- year_id
	varchar,			-- semester_ids
	integer,			-- core_id
	varchar,			-- prerequisite_ids
	varchar,			-- assumed_knowledge_ids
	varchar,			-- corequisite_ids
	varchar,			-- prohibition_ids
	varchar,			-- no_longer_offered_ids
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_revision_id				alias for $1;
	p_map_id				alias for $2;
	p_year_id				alias for $3;
	p_semester_ids				alias for $4;
	p_core_id				alias for $5;
	p_prerequisite_ids			alias for $6;
	p_assumed_knowledge_ids			alias for $7;
	p_corequisite_ids			alias for $8;
	p_prohibition_ids			alias for $9;
	p_no_longer_offered_ids			alias for $10;
	p_creation_date				alias for $11;
	p_creation_user				alias for $12;
	p_creation_ip				alias for $13;

	v_revision_id				integer;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.stream_uos_map#'',  -- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_map_id,				-- item_id
		p_revision_id,				-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- Insert into the uos-specific revision table
	INSERT into cc_stream_uos_map_rev (
		map_rev_id,
		year_id,
		semester_ids,
		core_id,
		prerequisite_ids,
		assumed_knowledge_ids,
		corequisite_ids,
		prohibition_ids,
		no_longer_offered_ids
	) VALUES (
		v_revision_id,
		p_year_id,
		p_semester_ids,
		p_core_id,
		p_prerequisite_ids,
		p_assumed_knowledge_ids,
		p_corequisite_ids,
		p_prohibition_ids,
		p_no_longer_offered_ids
	);

	-- Update the latest revision id in cc_stream_uos_map
	UPDATE cc_stream_uos_map SET latest_revision_id = v_revision_id
	WHERE map_id = p_map_id;

	return v_revision_id;
end;
' language 'plpgsql';
