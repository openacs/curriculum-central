--
-- packages/curriculum-central/sql/postgresql/uos-grade-create.sql
--
-- @author Nick Carroll (nick.c@rroll.net)
-- @creation-date 2006-01-06
-- @cvs-id $Id$
--
--


-- Create Grade Type object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_grade_type'', 			        -- object_type
    ''#curriculum-central.grade_type#'', 	 	-- pretty_name
    ''#curriculum-central.grade_types#'',        	-- pretty_plural
    ''acs_object'',                			-- supertype
    ''cc_uos_grade_type'',  				-- table_name
    ''type_id'',      	         			-- id_column
    null,                          			-- package_name
    ''f'',                         			-- abstract_p
    null,                          			-- type_extension_table
    ''cc_uos_grade_type__name''		      		-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about a grade.
create table cc_uos_grade_type (
	type_id			integer
				constraint cc_uos_grade_type_type_id_fk
				references acs_objects(object_id)
				constraint cc_uos_grade_type_type_id_pk
				primary key,
	name			varchar(256),
	lower_bound 		integer,
	upper_bound		integer,
	package_id		integer
);


create function inline_0 ()
returns integer as'
begin 
    PERFORM acs_object_type__create_type (
	''cc_uos_grade_set'',				-- object_type
	''#curriculum-central.uos_grade_set#'', 	-- pretty_name
	''#curriculum-central.uos_grade_sets#'',  	-- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_grade_set'',				-- table_name
	''grade_set_id'',				-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS grade set as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                	-- parent_type 
    'cc_uos_grade_set',      -- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);


-- content_item subtype
create table cc_uos_grade_set (
	grade_set_id		integer
                        	constraint cc_uos_grade_set_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_grade_set_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS Grade set content_revision
-- A revision may point to many Grades in the mapping
-- table below.
create table cc_uos_grade_set_revs (
	grade_set_revision_id	integer
				constraint cc_uos_grade_set_rev_pk
				primary key
				constraint cc_uos_grade_set_rev_fk
				references cr_revisions(revision_id)
				on delete cascade
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_grade_set_rev',
    'content_revision',
    '#curriculum-central.uos_grade_set_revision#',
    '#curriculum-central.uos_grade_set_revisions#',
    'cc_uos_grade_set_revs',
    'grade_set_revision_id',
    'content_revision.revision_name'
);

-- Register uos_grade_set_revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',			-- parent_type 
    'cc_uos_grade_set_rev',		-- child_type
    'generic',               		-- relation_tag
    0,                       		-- min_n
    null                     		-- max_n
);


-- Create Grade object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_grade'', 				        -- object_type
    ''#curriculum-central.grade_descriptor#'',  	-- pretty_name
    ''#curriculum-central.grade_descriptors#'',        -- pretty_plural
    ''acs_object'',                			-- supertype
    ''cc_uos_grade'',	    				-- table_name
    ''grade_id'',               			-- id_column
    null,                          			-- package_name
    ''f'',                         			-- abstract_p
    null,                          			-- type_extension_table
    ''cc_uos_grade__name''		      		-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about a grade.
create table cc_uos_grade (
	grade_id		integer
				constraint cc_uos_grade_id_fk
				references acs_objects(object_id)
				constraint cc_uos_grade_id_pk
				primary key,
	grade_type_id		integer
				constraint cc_uos_grade_type_fk
				references cc_uos_grade_type(type_id),
	description		text  -- Grade descriptor entry
);

-- Create Mapping table between revision and texbook.
-- A revision can refer to many gradess, since a
-- Unit of Study may require students to study many grades.
create table cc_uos_grade_map (
	revision_id		integer
				constraint cc_uos_grade_map_rev_id_fk
				references cc_uos_grade_set_revs(grade_set_revision_id),
	grade_id		integer
				constraint cc_uos_grade_map_grade_id_fk
				references cc_uos_grade(grade_id)
);


--
--
-- Create the functions for the grade content item and revisions.
--
--

select define_function_args('cc_uos_grade_set__new', 'grade_set_id,parent_uos_id,creation_user,creation_ip,context_id,item_subtype;cc_uos_grade_set,content_type;cc_uos_grade_set_rev,object_type,package_id');

create function cc_uos_grade_set__new(
	integer,	-- grade_set_id
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

	p_grade_set_id		alias for $1;
	p_parent_uos_id			alias for $2;
	p_creation_user			alias for $3;
	p_creation_ip			alias for $4;
	p_context_id			alias for $5;
	p_item_subtype			alias for $6;
	p_content_type			alias for $7;
	p_object_type			alias for $8;
	p_package_id			alias for $9;

	v_grade_set_id		cc_uos_grade_set.grade_set_id%TYPE;
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
	-- Can only have one grade set per Unit of Study,
	-- so append uos_id
	-- to "uos_grade_set_for_".
	v_name := ''uos_grade_set_for_'' || p_parent_uos_id;

	-- create the content item
	v_grade_set_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_grade_set_id,		-- item_id
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
	v_revision_id := cc_uos_grade_set_rev__new (
		null,				-- grade_set_revision_id
		v_grade_set_id,			-- grade_set_id
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	INSERT INTO cc_uos_grade_set (
		grade_set_id, parent_uos_id, latest_revision_id
	) VALUES (
		v_grade_set_id, p_parent_uos_id, v_revision_id
	);


	-- associate the UoS grade set with the parent UoS
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
      		v_rel_id,
		p_parent_uos_id,
		v_grade_set_id,
		''cc_uos_grade_set''
  	);	

	return v_grade_set_id;

end;
' language plpgsql;


select define_function_args('cc_uos_grade_set__delete', 'grade_set_id');

create function cc_uos_grade_set__delete (integer)
returns integer as '
declare
	p_grade_set_id		alias for $1;
begin

	perform content_item__delete(p_grade_set_id);

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_grade_set_rev__new (
	integer,			-- grade_set_revision_id
	integer,			-- grade_set_id
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_grade_set_revision_id		alias for $1;
	p_grade_set_id			alias for $2;
	p_creation_date				alias for $3;
	p_creation_user				alias for $4;
	p_creation_ip				alias for $5;

	v_revision_id				integer;
	v_title					varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_grades#'',  	-- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_grade_set_id,				-- item_id
		p_grade_set_revision_id,		-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- insert into the uos-specific revision table
	INSERT INTO cc_uos_grade_set_revs (grade_set_revision_id)
	VALUES (v_revision_id);

	-- Update the latest revision id in cc_uos_grade_set
	UPDATE cc_uos_grade_set SET latest_revision_id = v_revision_id
	WHERE grade_set_id = p_grade_set_id;

	return v_revision_id;
end;
' language 'plpgsql';


--
--
-- Create the functions for the cc_uos_grade object.
--
--

select define_function_args('cc_uos_grade__new','grade_id,grade_type_id,description,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_grade__new (
	integer,			-- grade_id
	integer,			-- grade_type_id
	text,				-- description
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar,			-- creation_ip
	integer,			-- package_id
	integer				-- context_id
) returns integer as '
declare
    	p_grade_id			alias for $1;        -- default null
    	p_grade_type_id			alias for $2;
    	p_description			alias for $3;
    	p_creation_date             	alias for $4;        -- default now()
    	p_creation_user             	alias for $5;        -- default null
    	p_creation_ip              	alias for $6;        -- default null
	p_package_id			alias for $7;
    	p_context_id                	alias for $8;       -- default null

	v_grade_id			cc_uos_grade.grade_id%TYPE;
begin
	v_grade_id := acs_object__new (
        	p_grade_id,
        	''cc_uos_grade'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		NULL,
		p_package_id
    	);

	INSERT INTO cc_uos_grade (
		grade_id, grade_type_id, description
	)
	VALUES (
		v_grade_id, p_grade_type_id, p_description
	);

    return v_grade_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_grade__del','grade_id');

create function cc_uos_grade__del (integer)
returns integer as '
declare
    	p_grade_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_grade_id;

    	DELETE FROM cc_uos_grade WHERE grade_id = p_grade_id;

	RAISE NOTICE ''Deleting grade...'';
    	PERFORM acs_object__delete(p_grade_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_grade__name','grade_id');

create function cc_uos_grade__name (integer)
returns varchar as '
declare
    	p_grade_id      alias for $1;

	v_name    varchar;
begin
	SELECT cc_uos_grade_type__name(grade_type_id) INTO v_name
       	FROM cc_uos_grade
        WHERE grade_id = p_grade_id;

    	return v_name;
end;
' language 'plpgsql';


--
-- Maps a grade to a grade revision set.
--
create function cc_uos_grade__map (
	integer,			-- revision_id
	integer				-- grade_id
) returns integer as '
declare
	p_revision_id		alias for $1;
	p_grade_id		alias for $2;
begin

	RAISE NOTICE ''Mapping grade to a revision set...'';

	INSERT INTO cc_uos_grade_map (revision_id, grade_id)
	VALUES (p_revision_id, p_grade_id);

	return 0;
end;
' language 'plpgsql';


--
-- Unmaps a grade from a revision set.
--
create function cc_uos_grade__unmap (
	integer,			-- revision_id
	integer				-- grade_id
) returns integer as '
declare
	p_revision_id		alias for $1;
	p_grade_id		alias for $2;
begin

	RAISE NOTICE ''Deleting mapping between grade and revision set...'';

	DELETE FROM cc_uos_grade_map
	WHERE revision_id = p_revision_id
	AND grade_id = p_grade_id;

	return 0;
end;
' language 'plpgsql';


--
--
-- Create the functions for the cc_uos_grade_type object.
--
--

select define_function_args('cc_uos_grade_type__new','type_id,name,lower_bound,upper_bound,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_grade_type__new (
	integer,			-- type_id
	varchar,			-- name
	integer,			-- lower_bound
	integer,			-- upper_bound
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar,			-- creation_ip
	integer,			-- package_id
	integer				-- context_id
) returns integer as '
declare
    	p_type_id			alias for $1;        -- default null
    	p_name				alias for $2;
    	p_lower_bound			alias for $3;
	p_upper_bound			alias for $4;
    	p_creation_date             	alias for $5;        -- default now()
    	p_creation_user             	alias for $6;        -- default null
    	p_creation_ip              	alias for $7;        -- default null
	p_package_id			alias for $8;
    	p_context_id                	alias for $9;       -- default null

	v_type_id			cc_uos_grade_type.type_id%TYPE;
begin
	v_type_id := acs_object__new (
        	p_type_id,
        	''cc_uos_grade_type'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		NULL,
		p_package_id
    	);

	INSERT INTO cc_uos_grade_type (
		type_id, name, lower_bound, upper_bound, package_id
	)
	VALUES (
		v_type_id, p_name, p_lower_bound, p_upper_bound, p_package_id
	);

    return v_type_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_grade_type__del','type_id');

create function cc_uos_grade_type__del (integer)
returns integer as '
declare
    	p_type_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_type_id;

    	DELETE FROM cc_uos_grade_type WHERE type_id = p_type_id;

	RAISE NOTICE ''Deleting grade...'';
    	PERFORM acs_object__delete(p_type_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_grade_type__name','type_id');

create function cc_uos_grade_type__name (integer)
returns varchar as '
declare
    	p_type_id      alias for $1;

	v_type_name    cc_uos_grade_type.name%TYPE;
begin
	SELECT name INTO v_type_name
       	FROM cc_uos_grade_type
        WHERE type_id = p_type_id;

    	return v_type_name;
end;
' language 'plpgsql';
