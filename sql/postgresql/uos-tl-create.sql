--
-- packages/curriculum-central/sql/postgresql/uos-tl-create.sql
--
-- @author Nick Carroll (nick.c@rroll.net)
-- @creation-date 2005-12-28
-- @cvs-id $Id$
--
--


create function inline_0 ()
returns integer as'
begin 
    PERFORM acs_object_type__create_type (
	''cc_uos_tl'',					-- object_type
	''#curriculum-central.uos_teaching_and_learning#'',  -- pretty_name
	''#curriculum-central.uos_teaching_and_learning#'',  -- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_tl'',					-- table_name
	''tl_id'',					-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS teaching and learning as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                -- parent_type 
    'cc_uos_tl',             -- child_type
    'generic',               -- relation_tag
    0,                       -- min_n
    null                     -- max_n
);


-- content_item subtype
create table cc_uos_tl (
	tl_id			integer
                        	constraint cc_uos_tl_tl_id_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_tl_id_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS Teaching and Learning content_revision
-- A revision may point to many Teaching and Learning methods in the mapping
-- table below.
create table cc_uos_tl_revisions (
	tl_revision_id		integer
				constraint cc_uos_tl_rev_pk
				primary key
				constraint cc_uos_tl_rev_tl_id_fk
				references cr_revisions(revision_id)
				on delete cascade
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_tl_revision',
    'content_revision',
    '#curriculum-central.uos_teaching_and_learning_revision#',
    '#curriculum-central.uos_teaching_and_learning_revisions#',
    'cc_uos_tl_revisions',
    'tl_revision_id',
    'content_revision.revision_name'
);

-- Register uos_tl_revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',		-- parent_type 
    'cc_uos_tl_revision',	-- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);

-- Create Teaching and Learning Method object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_tl_method'',          -- object_type
    ''#curriculum-central.teaching_and_learning_method#'',   -- pretty_name
    ''#curriculum-central.teaching_and_learning_methods#'',  -- pretty_plural
    ''acs_object'',                -- supertype
    ''cc_uos_tl_method'',          -- table_name
    ''method_id'',                 -- id_column
    null,                          -- package_name
    ''f'',                         -- abstract_p
    null,                          -- type_extension_table
    ''cc_uos_tl_method__name''     -- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about a teaching
-- and learning method.  Types of methods include Lectures, Tutorials,
-- Online, Lab work, etc.
-- The pretty names will be used for presentation.
-- The short names will be used for select lists in forms.  Make sure
-- that short names do not contain any white space.
create table cc_uos_tl_method (
	method_id		integer
				constraint cc_uos_tl_method_id_fk
				references acs_objects(object_id)
				constraint cc_uos_tl_method_id_pk
				primary key,
	name			varchar(256), -- eg. Lecture, Tutorial.
	identifier		varchar(256), -- for form multiselect.
	description		text          -- method description
);

-- Create Mapping table between revision and teaching and learning method.
-- A revision can refer to many teaching and learning methods, since a
-- Unit of Study can have lectures, tutorials, and online components to
-- the course.
create table cc_uos_tl_method_map (
	tl_revision_id		integer
				constraint cc_uos_tl_method_map_tl_rev_id_fk
				references cc_uos_tl_revisions(tl_revision_id),
	method_id		integer
				constraint cc_uos_tl_method_map_method_id_fk
				references cc_uos_tl_method(method_id)
);


--
--
-- Create the functions for the tl content item and revisions.
--
--

select define_function_args('cc_uos_tl__new', 'tl_id,parent_uos_id,creation_user,creation_ip,context_id,item_subtype;cc_uos_tl,content_type;cc_uos_tl_revision,object_type,package_id');

create function cc_uos_tl__new(
	integer,	-- tl_id
	integer,	-- parent_uos_id
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer,	-- context_id
	varchar,	-- item_subtype
	varchar,	-- content_type
	varchar,	-- object_type
	integer		-- package_id
) returns integer as'
declare

	p_tl_id				alias for $1;
	p_parent_uos_id			alias for $2;
	p_creation_user			alias for $3;
	p_creation_ip			alias for $4;
	p_context_id			alias for $5;
	p_item_subtype			alias for $6;
	p_content_type			alias for $7;
	p_object_type			alias for $8;
	p_package_id			alias for $9;

	v_tl_id				cc_uos_tl.tl_id%TYPE;
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
	-- Can only have one tl per Unit of Study, so append uos_id
	-- to "uos_tl_for_".
	v_name := ''uos_tl_for_'' || p_parent_uos_id;

	-- create the content item
	v_tl_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_tl_id,		-- item_id
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
	v_revision_id := cc_uos_tl_revision__new (
		null,				-- tl_revision_id
		v_tl_id,			-- tl_id
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	INSERT INTO cc_uos_tl (tl_id, parent_uos_id, latest_revision_id)
	VALUES (v_tl_id, p_parent_uos_id, v_revision_id);


	-- associate the UoS tl with the parent UoS
	v_rel_id := acs_object__new(
		NULL,
      		''cr_item_child_rel'',
      		current_timestamp,
      		p_creation_user,
      		p_creation_ip,
      		p_package_id
	);

  	INSERT INTO cr_child_rels (
      		rel_id, parent_id, child_id, relation_tag
      	) VALUES (
      		v_rel_id, p_parent_uos_id, v_tl_id, ''cc_uos_tl''
  	);	

	return v_tl_id;

end;
' language plpgsql;


select define_function_args('cc_uos_tl__delete', 'tl_id');

create function cc_uos_tl__delete (integer)
returns integer as '
declare
	p_tl_id			alias for $1;
begin

	perform content_item__delete(p_tl_id);

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_tl_revision__new (
	integer,			-- tl_revision_id
	integer,			-- tl_id
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_tl_revision_id		alias for $1;
	p_tl_id				alias for $2;
	p_creation_date			alias for $3;
	p_creation_user			alias for $4;
	p_creation_ip			alias for $5;

	v_revision_id			integer;
	v_title				varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_teaching_and_learning#'',  -- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_tl_id,				-- item_id
		p_tl_revision_id,			-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- insert into the uos-specific revision table
	INSERT INTO cc_uos_tl_revisions (tl_revision_id)
	VALUES (v_revision_id);

	-- Update the latest revision id in cc_uos_tl
	UPDATE cc_uos_tl SET latest_revision_id = v_revision_id
	WHERE tl_id = p_tl_id;

	return v_revision_id;
end;
' language 'plpgsql';


--
--
-- Create the functions for the tl method object.
--
--

select define_function_args('cc_uos_tl_method__new','method_id,name,identifier,description,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_tl_method__new (
	integer,			-- method_id
	varchar,			-- name
	varchar,			-- identifier
	text,				-- description
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar,			-- creation_ip
	integer,			-- package_id
	integer				-- context_id
) returns integer as '
declare
    	p_method_id			alias for $1;        -- default null
    	p_name				alias for $2;
    	p_identifier			alias for $3;
	p_description			alias for $4;
    	p_creation_date             	alias for $5;        -- default now()
    	p_creation_user             	alias for $6;        -- default null
    	p_creation_ip              	alias for $7;        -- default null
	p_package_id			alias for $8;
    	p_context_id                	alias for $9;        -- default null

	v_method_id			cc_uos_tl_method.method_id%TYPE;
	v_title				varchar;
begin
	v_title := p_name || '' ('' || p_identifier || '')'';

	v_method_id := acs_object__new (
        	p_method_id,
        	''cc_uos_tl_method'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		v_title,
		p_package_id
    	);

	INSERT INTO cc_uos_tl_method (
		method_id, name, identifier, description
	)
	VALUES (
		v_method_id, p_name, p_identifier, p_description
	);

    return v_method_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_tl_method__del','method_id');

create function cc_uos_tl_method__del (integer)
returns integer as '
declare
    	p_method_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_method_id;

    	DELETE FROM cc_uos_tl_method WHERE method_id = p_method_id;

	RAISE NOTICE ''Deleting teaching and learning method...'';
    	PERFORM acs_object__delete(p_method_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_tl_method__name','method_id');

create function cc_uos_tl_method__name (integer)
returns varchar as '
declare
    	p_method_id      alias for $1;

	v_method_name    cc_uos_tl_method.name%TYPE;
begin
	SELECT name INTO v_method_name
       	FROM cc_uos_tl_method
        WHERE method_id = p_method_id;

    	return v_method_name;
end;
' language 'plpgsql';


--
-- Maps a method to a teaching and learning (tl) revision.
--
create function cc_uos_tl_method__map (
	integer,			-- tl_revision_id
	integer				-- method_id
) returns integer as '
declare
	p_tl_revision_id	alias for $1;
	p_method_id		alias for $2;
begin

	RAISE NOTICE ''Mapping method to a teaching and learning revision...'';

	INSERT INTO cc_uos_tl_method_map (tl_revision_id, method_id)
	VALUES (p_tl_revision_id, p_method_id);

	return 0;
end;
' language 'plpgsql';


--
-- Unmaps a method to a teaching and learning (tl) revision.
--
create function cc_uos_tl_method__unmap (
	integer,			-- tl_revision_id
	integer				-- method_id
) returns integer as '
declare
	p_tl_revision_id	alias for $1;
	p_method_id		alias for $2;
begin

	RAISE NOTICE ''Deleting mapping between method and tl revision...'';

	DELETE FROM cc_uos_tl_method_map
	WHERE tl_revision_id = p_tl_revision_id
	AND method_id = p_method_id;

	return 0;
end;
' language 'plpgsql';
