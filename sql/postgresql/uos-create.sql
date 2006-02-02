--
-- packages/curriculum-central/sql/postgresql/uos-create.sql
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
	''cc_uos'',			-- object_type
	''UoS'',			-- pretty_name
	''UoS'',			-- pretty_plural
	''acs_object'',			-- supertype
	''cc_uos'',			-- table_name
	''uos_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_uos__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- content_item subtype
create table cc_uos (
	uos_id			integer
                        	constraint cc_uos_uos_id_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_uos_id_pk
				primary key,
	package_id		integer,
	-- denormalised from cr_items
	parent_id		integer,
	live_revision_id	integer,
	-- denormalised from cc_uos_revisions	
	uos_name_id 		integer,    -- references cc_uos_name(name_id)
	unit_coordinator_id	integer
				constraint cc_uos_coordinator_id_fk
				references users(user_id)
				constraint cc_uos_coordinator_id_nn
                        	not null
);


-- Create the UoS content_revision
create table cc_uos_revisions (
	uos_revision_id		integer
				constraint cc_uos_rev_pk
				primary key
				constraint cc_uos_rev_uos_id_fk
				references cr_revisions(revision_id)
				on delete cascade,
	uos_name_id 		integer
				constraint cc_uos_rev_uos_name_id_fk
				references cc_uos_name(name_id)
				constraint cc_uos_rev_uos_name_id_nn not null,
	credit_value		integer,
	department_id		integer
				constraint cc_stream_department_id_fk
				references cc_department(department_id)
				constraint cc_stream_department_id_nn
				not null,
	unit_coordinator_id	integer
				constraint cc_uos_rev_coordinator_id_fk
				references users(user_id)
				constraint cc_uos_rev_coordinator_id_nn
                        	not null,
	session_ids		varchar(256),
	prerequisite_ids	varchar(256),
	assumed_knowledge_ids	varchar(256),
	corequisite_ids		varchar(256),
	prohibition_ids		varchar(256),
	no_longer_offered_ids	varchar(256),
	activity_log		text
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_revision',
    'content_revision',
    'UoS Revision',
    'UoS Revisions',
    'cc_uos_revisions',
    'uos_revision_id',
    'content_revision.revision_name'
);


select define_function_args('cc_uos__new', 'uos_id,uos_name_id,unit_coordinator_id,credit_value,department_id,session_ids,prerequisite_ids,assumed_knowledge_ids,corequisite_ids,prohibition_ids,no_longer_offered_ids,activity_log,creation_user,creation_ip,context_id,item_subtype;cc_uos,content_type;cc_uos_revision,object_type,package_id');

create function cc_uos__new(
	integer,	-- uos_id
	integer,	-- uos_name_id
	integer,	-- unit_coordinator_id
	integer,	-- credit_value
	integer,	-- department_id
	varchar,	-- session_ids
	varchar,	-- prerequisite_ids
	varchar,	-- assumed_knowledge_ids
	varchar,	-- corequisite_ids
	varchar,	-- prohibition_ids
	varchar,	-- no_longer_offered_ids
	text,		-- activity_log
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer,	-- context_id
	varchar,	-- item_subtype
	varchar,	-- content_type
	varchar,	-- object_type
	integer		-- package_id
) returns integer as'
declare

	p_uos_id			alias for $1;
	p_uos_name_id			alias for $2;
	p_unit_coordinator_id		alias for $3;
	p_credit_value			alias for $4;
	p_department_id			alias for $5;
	p_session_ids			alias for $6;
	p_prerequisite_ids		alias for $7;
	p_assumed_knowledge_ids		alias for $8;
	p_corequisite_ids		alias for $9;
	p_prohibition_ids		alias for $10;
	p_no_longer_offered_ids		alias for $11;
	p_activity_log			alias for $12;
	p_creation_user			alias for $13;
	p_creation_ip			alias for $14;
	p_context_id			alias for $15;
	p_item_subtype			alias for $16;
	p_content_type			alias for $17;
	p_object_type			alias for $18;
	p_package_id			alias for $19;

	v_uos_id			cc_uos.uos_id%TYPE;
	v_folder_id			integer;
	v_revision_id			integer;
	v_uos_name			varchar;
begin
	-- get the content folder for this instance
	select folder_id into v_folder_id
	    from cc_curriculum
	    where curriculum_id = p_package_id;

	select uos_name into v_uos_name from cc_uos_name
	    where name_id = p_uos_name_id;

	-- create the content item
	v_uos_id := content_item__new (
			v_uos_name,		-- name
			v_folder_Id,		-- parent_id
			p_uos_id,		-- item_id
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
			null,			--data
			p_package_id
		);

	-- create the item type row
	insert into cc_uos (uos_id, package_id, parent_id,
	    uos_name_id, unit_coordinator_id)
	VALUES (v_uos_id, p_package_id, v_folder_id,
            p_uos_name_id, p_unit_coordinator_id);

	-- create the initial revision
	v_revision_id := cc_uos_revision__new (
		null,				-- uos_revision_id
		v_uos_id,			-- uos_id
		p_uos_name_id,			-- uos_name_id
		p_credit_value,			-- credit_value
		p_department_id,		-- department_id
		p_unit_coordinator_id,		-- unit_coordinator_id
		p_session_ids,			-- session_ids
		p_prerequisite_ids,		-- requisite_ids
		p_assumed_knowledge_ids,	-- assumed_knowledge_ids
		p_corequisite_ids,		-- corequisite_ids
		p_prohibition_ids,		-- prohibition_ids
		p_no_longer_offered_ids,	-- no_longer_offered_ids
		p_activity_log,			-- activity_log
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	return v_uos_id;

end;
' language plpgsql;


select define_function_args('cc_uos__delete', 'uos_id');

create function cc_uos__delete (integer)
returns integer as '
declare
	p_uos_id			alias for $1;

	v_case_id			integer;
	rec				record;
begin
	-- Every UoS is associated with a workflow case
	select case_id into v_case_id
	from workflow_cases
	where object_id = p_uos_id;

	perform workflow_case_pkg__delete(v_case_id);

	-- Every UoS may have notifications attached to it
	-- and there is one column in the notifications datamodel that
	-- doesn''t cascade
	for rec in select notification_id from notifications
			where response_id = p_uos_id loop

		PERFORM notification__delete (rec.notification_id);

	end loop;

	perform content_item__delete(p_uos_id);	

	return 0;

end;
' language 'plpgsql';


select define_function_args('cc_uos__name', 'uos_id');

create function cc_uos__name (integer)
returns varchar as '
declare
    p_uos_id      	alias for $1;
    v_uos_name    	varchar;
    v_uos_name_id 	cc_uos.uos_name_id%TYPE;
begin
	select uos_name_id into v_uos_name_id from cc_uos
		where uos_id = p_uos_id;

	select uos_name into v_uos_name from cc_uos_name
		where name_id = v_uos_name_id;

    return v_uos_name;
end;
' language 'plpgsql';


create or replace function cc_uos_revision__new (
	integer,			-- uos_revision_id
	integer,			-- uos_id
	integer,			-- uos_name_id
	integer,			-- credit_value
	integer,			-- department_id
	integer,			-- unit_coordinator_id
	varchar,			-- session_ids
	varchar,			-- prerequisite_ids
	varchar,			-- assumed_knowledge_ids
	varchar,			-- corequisite_ids
	varchar,			-- prohibition_ids
	varchar,			-- no_longer_offered_ids
	text,				-- activity_log
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_uos_revision_id		alias for $1;
	p_uos_id			alias for $2;
	p_uos_name_id			alias for $3;
	p_credit_value			alias for $4;
	p_department_id			alias for $5;
	p_unit_coordinator_id		alias for $6;
	p_session_ids			alias for $7;
	p_prerequisite_ids		alias for $8;
	p_assumed_knowledge_ids		alias for $9;
	p_corequisite_ids		alias for $10;
	p_prohibition_ids		alias for $11;
	p_no_longer_offered_ids		alias for $12;
	p_activity_log			alias for $13;
	p_creation_date			alias for $14;
	p_creation_user			alias for $15;
	p_creation_ip			alias for $16;

	v_revision_id			integer;
	v_uos_name			varchar;
begin
	select uos_name into v_uos_name from cc_uos_name
		where name_id = p_uos_name_id;

	-- create the initial revision
	v_revision_id := content_revision__new (
		v_uos_name,		-- title
		null,			-- description
		current_timestamp,	-- publish_date
		null,			-- mime_type
		null,			-- nls_language
		null,			-- new_data
		p_uos_id,		-- item_id
		p_uos_revision_id,	-- revision_id
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip		-- creation_ip
	);

	-- insert into the uos-specific revision table
	INSERT INTO cc_uos_revisions (
		uos_revision_id,
		uos_name_id,
		credit_value,
		department_id,
		unit_coordinator_id,
		session_ids,
		prerequisite_ids,
		assumed_knowledge_ids,
		corequisite_ids,
		prohibition_ids,
		no_longer_offered_ids,
		activity_log
	) VALUES (
		v_revision_id,
		p_uos_name_id,
		p_credit_value,
		p_department_id,
		p_unit_coordinator_id,
		p_session_ids,
		p_prerequisite_ids,
		p_assumed_knowledge_ids,
		p_corequisite_ids,
		p_prohibition_ids,
		p_no_longer_offered_ids,
		p_activity_log
	);

	return v_revision_id;
end;
' language 'plpgsql';


--
--
-- Create other UoS related tables.
--
--

-- UoS Details
\i uos-detail-create.sql

-- UoS Teaching and Learning
\i uos-tl-create.sql

-- UoS Workload
\i uos-workload-create.sql

-- UoS Graduate Attributes
\i uos-gradattr-create.sql

-- UoS Assessment Methods
\i uos-assess-create.sql

-- UoS Textbooks
\i uos-textbook-create.sql

-- UoS Grade Descriptors
\i uos-grades-create.sql

-- UoS Schedule
\i uos-schedule-create.sql

-- Session
\i session-create.sql

-- Year: 1st Year, 2nd Year, 3rd Year or Freshman, Sophomore, etc.
\i year-create.sql
