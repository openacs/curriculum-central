--
-- packages/curriculum-central/sql/postgresql/uos-assess-create.sql
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
	''cc_uos_assess'',				-- object_type
	''#curriculum-central.uos_assessment#'',  	-- pretty_name
	''#curriculum-central.uos_assessments#'',  	-- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_assess'',				-- table_name
	''assess_id'',					-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS assessment as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                -- parent_type 
    'cc_uos_assess',         -- child_type
    'generic',               -- relation_tag
    0,                       -- min_n
    null                     -- max_n
);


-- content_item subtype
create table cc_uos_assess (
	assess_id		integer
                        	constraint cc_uos_assess_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_assess_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS Assessment content_revision
-- A revision may point to many Assessment methods in the mapping
-- table below.
create table cc_uos_assess_revisions (
	assess_revision_id	integer
				constraint cc_uos_assess_rev_pk
				primary key
				constraint cc_uos_assess_rev_fk
				references cr_revisions(revision_id)
				on delete cascade
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_assess_revision',
    'content_revision',
    '#curriculum-central.uos_assessment_revision#',
    '#curriculum-central.uos_assessment_revisions#',
    'cc_uos_assess_revisions',
    'assess_revision_id',
    'content_revision.revision_name'
);

-- Register uos_assess_revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',		-- parent_type 
    'cc_uos_assess_revision',	-- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);

-- Create Assessment Methods object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_assess_method'',		-- object_type
    ''#curriculum-central.assessment_method#'',   -- pretty_name
    ''#curriculum-central.assessment_methods#'',  -- pretty_plural
    ''acs_object'',               	-- supertype
    ''cc_uos_assess_method'',     	-- table_name
    ''assess_id'',                	-- id_column
    null,                          	-- package_name
    ''f'',                         	-- abstract_p
    null,                          	-- type_extension_table
    ''cc_uos_assess_method__name''	-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about an
-- assessment method.  Types of methods include exam, quiz, project,
-- online activities, etc.
create table cc_uos_assess_method (
	method_id		integer
				constraint cc_uos_assess_method_fk
				references acs_objects(object_id)
				constraint cc_uos_assess_method_pk
				primary key,
	name			varchar(256), 	-- eg. Exam, Quiz, etc.
	identifier		varchar(256), 	-- for form multiselect.
	description		text,          	-- method description
	weighting		integer		-- eg 10 (% added later)
);

-- Create Mapping table between revision and assessment method.
-- A revision can refer to many assessment methods, since a
-- Unit of Study can have many multiple exams, quizzes, etc.
create table cc_uos_assess_method_map (
	assess_revision_id	integer
				constraint cc_uos_assess_method_map_rev_fk
				references
				cc_uos_assess_revisions(assess_revision_id),
	method_id		integer
				constraint cc_uos_assess_method_map_meth_fk
				references cc_uos_assess_method(method_id)
);


--
--
-- Create the functions for the assessment content item and revisions.
--
--

select define_function_args('cc_uos_assess__new', 'assess_id,parent_uos_id,creation_user,creation_ip,context_id,item_subtype;cc_uos_assess,content_type;cc_uos_assess_revision,object_type,package_id');

create function cc_uos_assess__new(
	integer,	-- assess_id
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

	p_assess_id			alias for $1;
	p_parent_uos_id			alias for $2;
	p_creation_user			alias for $3;
	p_creation_ip			alias for $4;
	p_context_id			alias for $5;
	p_item_subtype			alias for $6;
	p_content_type			alias for $7;
	p_object_type			alias for $8;
	p_package_id			alias for $9;

	v_assess_id			cc_uos_assess.assess_id%TYPE;
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
	-- Can only have one assess per Unit of Study, so append uos_id
	-- to "uos_assess_for_".
	v_name := ''uos_assess_for_'' || p_parent_uos_id;

	-- create the content item
	v_assess_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_assess_id,		-- item_id
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
	v_revision_id := cc_uos_assess_revision__new (
		null,				-- assess_revision_id
		v_assess_id,			-- assess_id
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	INSERT INTO cc_uos_assess (assess_id, parent_uos_id,
		latest_revision_id)
	VALUES (v_assess_id, p_parent_uos_id, v_revision_id);


	-- associate the UoS assess with the parent UoS
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
      		v_rel_id, p_parent_uos_id, v_assess_id, ''cc_uos_assess''
  	);	

	return v_assess_id;

end;
' language plpgsql;


select define_function_args('cc_uos_assess__delete', 'assess_id');

create function cc_uos_assess__delete (integer)
returns integer as '
declare
	p_assess_id		alias for $1;
begin

	perform content_item__delete(p_assess_id);

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_assess_revision__new (
	integer,			-- assess_revision_id
	integer,			-- assess_id
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_assess_revision_id		alias for $1;
	p_assess_id			alias for $2;
	p_creation_date			alias for $3;
	p_creation_user			alias for $4;
	p_creation_ip			alias for $5;

	v_revision_id			integer;
	v_title				varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_assessment#'',  -- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_assess_id,				-- item_id
		p_assess_revision_id,			-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- insert into the uos-specific revision table
	INSERT INTO cc_uos_assess_revisions (assess_revision_id)
	VALUES (v_revision_id);

	-- Update the latest revision id in cc_uos_assess
	UPDATE cc_uos_assess SET latest_revision_id = v_revision_id
	WHERE assess_id = p_assess_id;

	return v_revision_id;
end;
' language 'plpgsql';


--
--
-- Create the functions for the assessment method object.
--
--

select define_function_args('cc_uos_assess_method__new','method_id,name,identifier,description,weighting,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_assess_method__new (
	integer,			-- method_id
	varchar,			-- name
	varchar,			-- identifier
	text,				-- description
	integer,			-- weighting
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
	p_weighting			alias for $5;
    	p_creation_date             	alias for $6;        -- default now()
    	p_creation_user             	alias for $7;        -- default null
    	p_creation_ip              	alias for $8;        -- default null
	p_package_id			alias for $9;
    	p_context_id                	alias for $10;       -- default null

	v_method_id			cc_uos_assess_method.method_id%TYPE;
	v_title				varchar;
begin
	v_title := p_name || '' ('' || p_identifier || '')'';

	v_method_id := acs_object__new (
        	p_method_id,
        	''cc_uos_assess_method'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		v_title,
		p_package_id
    	);

	INSERT INTO cc_uos_assess_method (
		method_id, name, identifier, description, weighting
	)
	VALUES (
		v_method_id, p_name, p_identifier, p_description, p_weighting
	);

    return v_method_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_assess_method__del','method_id');

create function cc_uos_assess_method__del (integer)
returns integer as '
declare
    	p_method_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_method_id;

    	DELETE FROM cc_uos_assess_method WHERE method_id = p_method_id;

	RAISE NOTICE ''Deleting assessment method...'';
    	PERFORM acs_object__delete(p_method_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_assess_method__name','method_id');

create function cc_uos_assess_method__name (integer)
returns varchar as '
declare
    	p_method_id      alias for $1;

	v_method_name    cc_uos_assess_method.name%TYPE;
begin
	SELECT name INTO v_method_name
       	FROM cc_uos_assess_method
        WHERE method_id = p_method_id;

    	return v_method_name;
end;
' language 'plpgsql';


--
-- Maps a method to an assessment revision.
--
create function cc_uos_assess_method__map (
	integer,			-- assess_revision_id
	integer				-- method_id
) returns integer as '
declare
	p_assess_revision_id	alias for $1;
	p_method_id		alias for $2;
begin

	RAISE NOTICE ''Mapping method to an assessment revision...'';

	INSERT INTO cc_uos_assess_method_map (assess_revision_id, method_id)
	VALUES (p_assess_revision_id, p_method_id);

	return 0;
end;
' language 'plpgsql';


--
-- Unmaps a method to an assessment revision.
--
create function cc_uos_assess_method__unmap (
	integer,			-- assess_revision_id
	integer				-- method_id
) returns integer as '
declare
	p_assess_revision_id	alias for $1;
	p_method_id		alias for $2;
begin

	RAISE NOTICE ''Deleting mapping between method and assess revision...'';

	DELETE FROM cc_uos_assess_method_map
	WHERE assess_revision_id = p_assess_revision_id
	AND method_id = p_method_id;

	return 0;
end;
' language 'plpgsql';
