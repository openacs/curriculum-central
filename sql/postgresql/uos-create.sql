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
	uos_code 		varchar(256)
				constraint cc_uos_uos_code_nn not null
				constraint cc_uos_uos_code_un unique,
	uos_name 		varchar(256)
				constraint cc_uos_uos_name_nn not null
				constraint cc_uos_uos_name_un unique,
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
	uos_code 		varchar(256)
				constraint cc_uos_rev_uos_code_nn not null
				constraint cc_uos_rev_uos_code_un unique,
	uos_name 		varchar(256)
				constraint cc_uos_rev_uos_name_nn not null
				constraint cc_uos_rev_uos_name_un unique,
	credit_value		integer,
	semester		varchar(32),
	online_course_content 	varchar(256),
	unit_coordinator_id	integer
				constraint cc_uos_rev_coordinator_id_fk
				references users(user_id)
				constraint cc_uos_rev_coordinator_id_nn
                        	not null,
	contact_hours		varchar(256),
	assessments		varchar(512),
	core_uos_for		varchar(512),
	recommended_uos_for	varchar(512),
	prerequisites		varchar(256),
	objectives		text,
	outcomes		text,
	syllabus		text,
	syllabus_format		varchar(256)
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


select define_function_args('cc_uos__new', 'uos_id,uos_code,uos_name,unit_coordinator_id,credit_value,semester,online_course_content,contact_hours,assessments,core_uos_for,recommended_uos_for,prerequisites,objectives,outcomes,syllabus,syllabus_format,creation_user,creation_ip,context_id,item_subtype;cc_uos,content_type;cc_uos_revision,object_type,package_id');

create function cc_uos__new(
	integer,	-- uos_id
	varchar,	-- uos_code
	varchar,	-- uos_name
	integer,	-- unit_coordinator_id
	integer,	-- credit_value
	varchar,	-- semester
	varchar,	-- online_course_content
	varchar,	-- contact_hours
	varchar,	-- assessments
	varchar,	-- core_uos_for
	varchar,	-- recommended_uos_for
	varchar,	-- prerequisites
	text,		-- objectives
	text,		-- outcomes
	text,		-- syllabus
	varchar,	-- syllabus_format
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
	p_uos_code			alias for $2;
	p_uos_name			alias for $3;
	p_unit_coordinator_id		alias for $4;
	p_credit_value			alias for $5;
	p_semester			alias for $6;
	p_online_course_content		alias for $7;
	p_contact_hours			alias for $8;
	p_assessments			alias for $9;
	p_core_uos_for			alias for $10;
	p_recommended_uos_for		alias for $11;
	p_prerequisites			alias for $12;
	p_objectives			alias for $13;
	p_outcomes			alias for $14;
	p_syllabus			alias for $15;
	p_syllabus_format		alias for $16;
	p_creation_user			alias for $17;
	p_creation_ip			alias for $18;
	p_context_id			alias for $19;
	p_item_subtype			alias for $20;
	p_content_type			alias for $21;
	p_object_type			alias for $22;
	p_package_id			alias for $23;

	v_uos_id			cc_uos.uos_id%TYPE;
	v_folder_id			integer;
	v_revision_id			integer;
begin
	-- get the content folder for this instance
	select folder_id into v_folder_id
	    from cc_curriculum
	    where curriculum_id = p_package_id;

	-- create the content item
	v_uos_id := content_item__new (
			p_uos_name,		-- name
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
	    uos_code, uos_name, unit_coordinator_id)
	VALUES (v_uos_id, p_package_id, v_folder_id, p_uos_code,
            p_uos_name, p_unit_coordinator_id);

	-- create the initial revision
	v_revision_id := cc_uos_revision__new (
		null,				-- uos_revision_id
		v_uos_id,			-- uos_id
		p_uos_code,			-- uos_code
		p_uos_name,			-- uos_name
		p_credit_value,			-- credit_value
		p_semester,			-- semester
		p_online_course_content,	-- online_course_content
		p_unit_coordinator_id,		-- unit_coordinator_id
		p_contact_hours,		-- contact_hours
		p_assessments,			-- assessments
		p_core_uos_for,			-- core_uos_for
		p_recommended_uos_for,		-- recommended_uos_for
		p_prerequisites,		-- prerequisites
		p_objectives,			-- objectives
		p_outcomes,			-- outcomes
		p_syllabus,			-- syllabus
		p_syllabus_format,		-- syllabus_format
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
    p_uos_id      alias for $1;
    v_uos_name    cc_uos.uos_name%TYPE;
begin
	select uos_name into v_uos_name
		from cc_uos
		where uos_id = p_uos_id;

    return v_uos_name;
end;
' language 'plpgsql';


create or replace function cc_uos_revision__new (
	integer,			-- uos_revision_id
	integer,			-- uos_id
	varchar,			-- uos_code
	varchar,			-- uos_name
	integer,			-- credit_value
	varchar,			-- semester
	varchar,			-- online_course_content
	integer,			-- unit_coordinator_id
	varchar,			-- contact_hours
	varchar,			-- assessments
	varchar,			-- core_uos_for
	varchar,			-- recommended_uos_for
	varchar,			-- prerequisites
	text,				-- objectives
	text,				-- outcomes
	text,				-- syllabus
	varchar,			-- syllabus_format
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_uos_revision_id		alias for $1;
	p_uos_id			alias for $2;
	p_uos_code			alias for $3;
	p_uos_name			alias for $4;
	p_credit_value			alias for $5;
	p_semester			alias for $6;
	p_online_course_content		alias for $7;
	p_unit_coordinator_id		alias for $8;
	p_contact_hours			alias for $9;
	p_assessments			alias for $10;
	p_core_uos_for			alias for $11;
	p_recommended_uos_for		alias for $12;
	p_prerequisites			alias for $13;
	p_objectives			alias for $14;
	p_outcomes			alias for $15;
	p_syllabus			alias for $16;
	p_syllabus_format		alias for $17;
	p_creation_date			alias for $18;
	p_creation_user			alias for $19;
	p_creation_ip			alias for $20;

	v_revision_id			integer;
begin
	-- create the initial revision
	v_revision_id := content_revision__new (
		p_uos_name,		-- title
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
	insert into cc_uos_revisions
		(uos_revision_id, uos_code, uos_name, credit_value,
		semester, online_course_content, unit_coordinator_id,
		contact_hours, assessments, core_uos_for, recommended_uos_for,
		prerequisites, objectives, outcomes, syllabus, syllabus_format)
	values
		(v_revision_id, p_uos_code, p_uos_name, p_credit_value,
		p_semester, p_online_course_content, p_unit_coordinator_id,
		p_contact_hours, p_assessments, p_core_uos_for,
		p_recommended_uos_for, p_prerequisites, p_objectives,
		p_outcomes, p_syllabus, p_syllabus_format);

	-- make the revision live
	PERFORM content_item__set_live_revision(v_revision_id);

	-- update the cache
	update cc_uos
	set	live_revision_id = v_revision_id,
		uos_code = p_uos_code,
		uos_name = p_uos_name,
		unit_coordinator_id = p_unit_coordinator_id
	where	uos_id = p_uos_id;

	-- update the title in acs_objects
	update acs_objects
	set	title = cc_uos__name(p_uos_id)
	where object_id = p_uos_id;

	return v_revision_id;
end;
' language 'plpgsql';
