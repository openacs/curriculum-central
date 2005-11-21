--
-- packages/curriculum-central/sql/postgresql/department-create.sql
--
-- @author Nick Carroll (nick.c@rroll.net)
-- @creation-date 2005-11-08
-- @cvs-id $Id$
--
--


create function inline_0 ()
returns integer as'
begin 
    PERFORM acs_object_type__create_type (
	''cc_department'',			-- object_type
	''Department'',			-- pretty_name
	''Departments'',			-- pretty_plural
	''acs_object'',			-- supertype
	''cc_department'',			-- table_name
	''department_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_department__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_department (
	department_id	integer
                        constraint cc_department_department_id_fk
                        references acs_objects(object_id)
			constraint cc_department_department_id_pk primary key,
	-- Head of Department (HoD)
	hod_id		integer
			constraint cc_department_hod_id_fk
			references users(user_id)
			constraint cc_department_hod_id_nn
                        not null,
	department_name varchar(256)
			constraint cc_department_department_name_nn not null
			constraint cc_department_department_name_un unique,
	faculty_id	integer
			constraint cc_department_faculty_id_fk
			references cc_faculty(faculty_id)
			constraint cc_department_faculty_id_nn
			not null,
	package_id	integer
			constraint cc_department_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Department Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_department'',		-- object_type
	  ''department_name'',		-- attribute_name
	  ''string'',			-- datatype
	  ''Department Name'',		-- pretty_name
	  ''Department Names'',		-- pretty_plural
	  null,				-- table_name
	  null,				-- column_name
	  null,				-- default_value
	  1,				-- min_n_values
	  1,				-- max_n_values
	  null,				-- sort_order
	  ''type_specific'',		-- storage
	  ''f''				-- static_p
	);

    PERFORM acs_attribute__create_attribute (
	  ''cc_department'',		-- object_type
	  ''hod_id'',			-- attribute_name
	  ''string'',			-- datatype
	  ''Head of Department'',	-- pretty_name
	  ''Heads of Department'',	-- pretty_plural
	  null,				-- table_name
	  null,				-- column_name
	  null,				-- default_value
	  1,				-- min_n_values
	  1,				-- max_n_values
	  null,				-- sort_order
	  ''type_specific'',		-- storage
	  ''f''				-- static_p
	);

    return 0;
end;' 
language 'plpgsql';
select inline_1 ();
drop function inline_1 ();


select define_function_args('cc_department__new', 'department_id,department_name,hod_id,faculty_id,object_type,creation_user,creation_ip,package_id');

create function cc_department__new(integer, varchar, integer, integer, varchar, integer, varchar, integer)
returns integer as'

declare

	p_department_id		alias for $1;
	p_department_name	alias for $2;
	p_hod_id		alias for $3;
	p_faculty_id		alias for $4;
	p_object_type		alias for $5;
	p_creation_user		alias for $6;
	p_creation_ip		alias for $7;
	p_package_id		alias for $8;

	v_department_id		cc_department.department_id%TYPE;
begin

	v_department_id := acs_object__new (
			p_department_id,
			p_object_type,
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_department values(v_department_id, p_hod_id, p_department_name, p_faculty_id, p_package_id);
	
	return v_department_id;

end;
' language plpgsql;


select define_function_args('cc_department__delete', 'department_id');

create function cc_department__delete (integer)
returns integer as '
declare
  p_department_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_department_id;

	delete from cc_department
		   where department_id = p_department_id;

	raise NOTICE ''Deleting Department...'';
	PERFORM acs_object__delete(p_department_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_department__name', 'department_id');

create function cc_department__name (integer)
returns varchar as '
declare
    p_department_id      alias for $1;
    v_department_name    cc_department.department_name%TYPE;
begin
	select department_name into v_department_name
		from cc_department
		where department_id = p_department_id;

    return v_department_name;
end;
' language plpgsql;
