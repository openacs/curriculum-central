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


-- TODO: variable assignment
select define_function_args('cc_uos__new', 'uos_id,owner_id,object_type,name,code,department,faculty,creation_user,creation_ip,context_id');

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
	varchar		-- content_type
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

	v_uos_id		cc_uos.uos_id%TYPE;
begin

	v_uos_id := acs_object__new (
			p_uos_id,
			p_object_type,
			now(),
			p_creation_user,
			p_creation_ip,
			p_context_id
		);

	insert into cc_uos values(v_uos_id, p_owner_id, p_name, p_code, p_department, p_faculty);
	
	PERFORM acs_permission__grant_permission(
          v_uos_id,
          p_unit_coordinator_id,
          ''admin''
    	);

	return v_uos_id;

end;
' language plpgsql;


select define_function_args('cc_uos__delete', 'uos_id');

create function cc_uos__delete (integer)
returns integer as '
declare
  p_uos_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_uos_id;

	delete from cc_uos
		   where uos_id = p_uos_id;

	raise NOTICE ''Deleting UoS...'';
	PERFORM acs_object__delete(p_uos_id);

	return 0;

end;' 
language plpgsql;


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

    return v_uos;
end;
' language plpgsql;
