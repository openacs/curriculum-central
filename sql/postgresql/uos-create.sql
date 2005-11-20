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


create table cc_uos (
	uos_id		integer
                        constraint cc_uos_uos_id_fk
                        references acs_objects(object_id)
			constraint cc_uos_uos_id_pk primary key,
	coordinator_id	integer
			constraint cc_uos_coordinator_id_fk
			references users(user_id)
			constraint cc_uos_coordinator_id_nn
                        not null,
	uos_name 	varchar(256)
			constraint cc_uos_uos_name_nn not null
			constraint cc_uos_uos_name_un unique,
	uos_code 	varchar(256),
	department_id	integer,
	faculty_id	integer
);


select define_function_args('cc_uos__new', 'uos_id,owner_id,object_type,name,code,department,faculty,creation_user,creation_ip,context_id');

create function cc_uos__new(integer, integer, varchar, varchar, varchar, varchar, varchar, integer, varchar, integer)
returns integer as'

declare

	p_uos_id		alias for $1;
	p_owner_id		alias for $2;
	p_object_type		alias for $3;
	p_name			alias for $4;
	p_code			alias for $5;
	p_department		alias for $6;
	p_faculty		alias for $7;
	p_creation_user		alias for $8;
	p_creation_ip		alias for $9;
	p_context_id		alias for $10;

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
          p_owner_id,
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
