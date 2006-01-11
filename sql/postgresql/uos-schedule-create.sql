--
-- packages/curriculum-central/sql/postgresql/uos-schedule-create.sql
--
-- @author Nick Carroll (nick.c@rroll.net)
-- @creation-date 2006-01-06
-- @cvs-id $Id$
--
--


-- Create Schedule Week object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_schedule_week'', 			        -- object_type
    ''#curriculum-central.schedule_week#'', 	 	-- pretty_name
    ''#curriculum-central.schedule_weeks#'',        	-- pretty_plural
    ''acs_object'',                			-- supertype
    ''cc_uos_schedule_week'',  				-- table_name
    ''week_id'',      	         			-- id_column
    null,                          			-- package_name
    ''f'',                         			-- abstract_p
    null,                          			-- type_extension_table
    ''cc_uos_schedule_week__name''		      	-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about a schedule.
create table cc_uos_schedule_week (
	week_id			integer
				constraint cc_uos_schedule_week_week_id_fk
				references acs_objects(object_id)
				constraint cc_uos_schedule_week_week_id_pk
				primary key,
	name			varchar(256),  -- Eg. Week 1, StuVac, Exams.
	package_id		integer
);


create function inline_0 ()
returns integer as'
begin 
    PERFORM acs_object_type__create_type (
	''cc_uos_schedule_set'',			-- object_type
	''#curriculum-central.uos_schedule_set#'', 	-- pretty_name
	''#curriculum-central.uos_schedule_sets#'',  	-- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_schedule_set'',			-- table_name
	''schedule_set_id'',				-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS schedule set as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                	-- parent_type 
    'cc_uos_schedule_set',      -- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);


-- content_item subtype
create table cc_uos_schedule_set (
	schedule_set_id		integer
                        	constraint cc_uos_schedule_set_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_schedule_set_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS Schedule set content_revision
-- A revision may point to many Schedules in the mapping
-- table below.
create table cc_uos_schedule_set_revs (
	schedule_set_revision_id	integer
					constraint cc_uos_schedule_set_rev_pk
					primary key
					constraint cc_uos_schedule_set_rev_fk
					references cr_revisions(revision_id)
					on delete cascade
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_schedule_set_rev',
    'content_revision',
    '#curriculum-central.uos_schedule_set_revision#',
    '#curriculum-central.uos_schedule_set_revisions#',
    'cc_uos_schedule_set_revs',
    'schedule_set_revision_id',
    'content_revision.revision_name'
);

-- Register uos_schedule_set_revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',			-- parent_type 
    'cc_uos_schedule_set_rev',		-- child_type
    'generic',               		-- relation_tag
    0,                       		-- min_n
    null                     		-- max_n
);


-- Create Schedule object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_schedule'', 				-- object_type
    ''#curriculum-central.schedule#'',  		-- pretty_name
    ''#curriculum-central.schedules#'',      		-- pretty_plural
    ''acs_object'',                			-- supertype
    ''cc_uos_schedule'',	    			-- table_name
    ''schedule_id'',               			-- id_column
    null,                          			-- package_name
    ''f'',                         			-- abstract_p
    null,                          			-- type_extension_table
    ''cc_uos_schedule__name''		      		-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about a schedule.
create table cc_uos_schedule (
	schedule_id		integer
				constraint cc_uos_schedule_id_fk
				references acs_objects(object_id)
				constraint cc_uos_schedule_id_pk
				primary key,
	week_id			integer
				constraint cc_uos_schedule_week_fk
				references cc_uos_schedule_week(week_id),
	course_content		text,
	assessment_ids		varchar(1024)
);

-- Create Mapping table between revision and texbook.
-- A revision can refer to many schedules, since a
-- Unit of Study may require students to study many schedules.
create table cc_uos_schedule_map (
	revision_id		integer
				constraint cc_uos_schedule_map_rev_id_fk
				references cc_uos_schedule_set_revs(schedule_set_revision_id),
	schedule_id		integer
				constraint cc_uos_schedule_map_schedule_id_fk
				references cc_uos_schedule(schedule_id)
);


--
--
-- Create the functions for the schedule content item and revisions.
--
--

select define_function_args('cc_uos_schedule_set__new', 'schedule_set_id,parent_uos_id,creation_user,creation_ip,context_id,item_subtype;cc_uos_schedule_set,content_type;cc_uos_schedule_set_rev,object_type,package_id');

create function cc_uos_schedule_set__new(
	integer,	-- schedule_set_id
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

	p_schedule_set_id		alias for $1;
	p_parent_uos_id			alias for $2;
	p_creation_user			alias for $3;
	p_creation_ip			alias for $4;
	p_context_id			alias for $5;
	p_item_subtype			alias for $6;
	p_content_type			alias for $7;
	p_object_type			alias for $8;
	p_package_id			alias for $9;

	v_schedule_set_id		cc_uos_schedule_set.schedule_set_id%TYPE;
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
	-- Can only have one schedule set per Unit of Study,
	-- so append uos_id
	-- to "uos_schedule_set_for_".
	v_name := ''uos_schedule_set_for_'' || p_parent_uos_id;

	-- create the content item
	v_schedule_set_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_schedule_set_id,	-- item_id
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
	v_revision_id := cc_uos_schedule_set_rev__new (
		null,				-- schedule_set_revision_id
		v_schedule_set_id,		-- schedule_set_id
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	INSERT INTO cc_uos_schedule_set (
		schedule_set_id, parent_uos_id, latest_revision_id
	) VALUES (
		v_schedule_set_id, p_parent_uos_id, v_revision_id
	);


	-- associate the UoS schedule set with the parent UoS
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
		v_schedule_set_id,
		''cc_uos_schedule_set''
  	);	

	return v_schedule_set_id;

end;
' language plpgsql;


select define_function_args('cc_uos_schedule_set__delete', 'schedule_set_id');

create function cc_uos_schedule_set__delete (integer)
returns integer as '
declare
	p_schedule_set_id		alias for $1;
begin

	perform content_item__delete(p_schedule_set_id);

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_schedule_set_rev__new (
	integer,			-- schedule_set_revision_id
	integer,			-- schedule_set_id
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_schedule_set_revision_id		alias for $1;
	p_schedule_set_id			alias for $2;
	p_creation_date				alias for $3;
	p_creation_user				alias for $4;
	p_creation_ip				alias for $5;

	v_revision_id				integer;
	v_title					varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_schedules#'',  	-- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_schedule_set_id,			-- item_id
		p_schedule_set_revision_id,		-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- insert into the uos-specific revision table
	INSERT INTO cc_uos_schedule_set_revs (schedule_set_revision_id)
	VALUES (v_revision_id);

	-- Update the latest revision id in cc_uos_schedule_set
	UPDATE cc_uos_schedule_set SET latest_revision_id = v_revision_id
	WHERE schedule_set_id = p_schedule_set_id;

	return v_revision_id;
end;
' language 'plpgsql';


--
--
-- Create the functions for the cc_uos_schedule object.
--
--

select define_function_args('cc_uos_schedule__new','schedule_id,week_id,course_content,assessment_ids,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_schedule__new (
	integer,			-- schedule_id
	integer,			-- week_id
	text,				-- course_content
	varchar,			-- assessment_ids
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar,			-- creation_ip
	integer,			-- package_id
	integer				-- context_id
) returns integer as '
declare
    	p_schedule_id			alias for $1;        -- default null
    	p_week_id			alias for $2;
    	p_course_content		alias for $3;
	p_assessment_ids		alias for $4;
    	p_creation_date             	alias for $5;        -- default now()
    	p_creation_user             	alias for $6;        -- default null
    	p_creation_ip              	alias for $7;        -- default null
	p_package_id			alias for $8;
    	p_context_id                	alias for $9;       -- default null

	v_schedule_id			cc_uos_schedule.schedule_id%TYPE;
begin
	v_schedule_id := acs_object__new (
        	p_schedule_id,
        	''cc_uos_schedule'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		NULL,
		p_package_id
    	);

	INSERT INTO cc_uos_schedule (
		schedule_id, week_id, course_content, assessment_ids
	)
	VALUES (
		v_schedule_id, p_week_id, p_course_content, p_assessment_ids
	);

    return v_schedule_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_schedule__del','schedule_id');

create function cc_uos_schedule__del (integer)
returns integer as '
declare
    	p_schedule_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_schedule_id;

    	DELETE FROM cc_uos_schedule WHERE schedule_id = p_schedule_id;

	RAISE NOTICE ''Deleting schedule...'';
    	PERFORM acs_object__delete(p_schedule_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_schedule__name','schedule_id');

create function cc_uos_schedule__name (integer)
returns varchar as '
declare
    	p_schedule_id      alias for $1;

	v_name    varchar;
begin
	SELECT cc_uos_schedule_week__name(week_id) INTO v_name
       	FROM cc_uos_schedule
        WHERE schedule_id = p_schedule_id;

    	return v_name;
end;
' language 'plpgsql';


--
-- Maps a schedule to a schedule revision set.
--
create function cc_uos_schedule__map (
	integer,			-- revision_id
	integer				-- schedule_id
) returns integer as '
declare
	p_revision_id		alias for $1;
	p_schedule_id		alias for $2;
begin

	RAISE NOTICE ''Mapping schedule to a revision set...'';

	INSERT INTO cc_uos_schedule_map (revision_id, schedule_id)
	VALUES (p_revision_id, p_schedule_id);

	return 0;
end;
' language 'plpgsql';


--
-- Unmaps a schedule from a revision set.
--
create function cc_uos_schedule__unmap (
	integer,			-- revision_id
	integer				-- schedule_id
) returns integer as '
declare
	p_revision_id		alias for $1;
	p_schedule_id		alias for $2;
begin

	RAISE NOTICE ''Deleting mapping between schedule and revision set...'';

	DELETE FROM cc_uos_schedule_map
	WHERE revision_id = p_revision_id
	AND schedule_id = p_schedule_id;

	return 0;
end;
' language 'plpgsql';


--
--
-- Create the functions for the cc_uos_schedule_week object.
--
--

select define_function_args('cc_uos_schedule_week__new','type_id,name,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_schedule_week__new (
	integer,			-- week_id
	varchar,			-- name
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar,			-- creation_ip
	integer,			-- package_id
	integer				-- context_id
) returns integer as '
declare
    	p_week_id			alias for $1;        -- default null
    	p_name				alias for $2;
    	p_creation_date             	alias for $3;        -- default now()
    	p_creation_user             	alias for $4;        -- default null
    	p_creation_ip              	alias for $5;        -- default null
	p_package_id			alias for $6;
    	p_context_id                	alias for $7;       -- default null

	v_week_id			cc_uos_schedule_week.week_id%TYPE;
begin
	v_week_id := acs_object__new (
        	p_week_id,
        	''cc_uos_schedule_week'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		NULL,
		p_package_id
    	);

	INSERT INTO cc_uos_schedule_week (
		week_id, name, package_id
	)
	VALUES (
		v_week_id, p_name, p_package_id
	);

    return v_week_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_schedule_week__del','week_id');

create function cc_uos_schedule_week__del (integer)
returns integer as '
declare
    	p_week_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_week_id;

    	DELETE FROM cc_uos_schedule_week WHERE week_id = p_week_id;

	RAISE NOTICE ''Deleting schedule...'';
    	PERFORM acs_object__delete(p_week_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_schedule_week__name','week_id');

create function cc_uos_schedule_week__name (integer)
returns varchar as '
declare
    	p_week_id      alias for $1;

	v_week_name    cc_uos_schedule_week.name%TYPE;
begin
	SELECT name INTO v_week_name
       	FROM cc_uos_schedule_week
        WHERE week_id = p_week_id;

    	return v_week_name;
end;
' language 'plpgsql';
