--
-- packages/curriculum-central/sql/postgresql/faculty-create.sql
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
	''cc_faculty'',			-- object_type
	''Faculty'',			-- pretty_name
	''Faculties'',			-- pretty_plural
	''acs_object'',			-- supertype
	''cc_faculty'',			-- table_name
	''faculty_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_faculty__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_faculty (
	faculty_id	integer
                        constraint cc_faculty_faculty_id_fk
                        references acs_objects(object_id)
			constraint cc_faculty_faculty_id_pk primary key,
	dean_id		integer
			constraint cc_faculty_dean_id_fk
			references users(user_id)
			constraint cc_faculty_dean_id_nn
                        not null,
	faculty_name 	varchar(256)
			constraint cc_faculty_faculty_name_nn not null
			constraint cc_faculty_faculty_name_un unique,
	package_id	integer
			constraint cc_faculty_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Faculty Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_faculty'',		-- object_type
	  ''faculty_name'',		-- attribute_name
	  ''string'',			-- datatype
	  ''Faculty Name'',		-- pretty_name
	  ''Faculty Names'',		-- pretty_plural
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
	  ''cc_faculty'',		-- object_type
	  ''dean_id'',			-- attribute_name
	  ''string'',			-- datatype
	  ''Dean'',			-- pretty_name
	  ''Deans'',			-- pretty_plural
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


select define_function_args('cc_faculty__new', 'faculty_id,faculty_name,dean_id,object_type,creation_user,creation_ip,package_id');

create function cc_faculty__new(integer, varchar, integer, varchar, integer, varchar, integer)
returns integer as'

declare

	p_faculty_id		alias for $1;
	p_faculty_name		alias for $2;
	p_dean_id		alias for $3;
	p_object_type		alias for $4;
	p_creation_user		alias for $5;
	p_creation_ip		alias for $6;
	p_package_id		alias for $7;

	v_faculty_id		cc_faculty.faculty_id%TYPE;
begin

	v_faculty_id := acs_object__new (
			p_faculty_id,
			p_object_type,
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_faculty values(v_faculty_id, p_dean_id, p_faculty_name, p_package_id);
	
	return v_faculty_id;

end;
' language plpgsql;


select define_function_args('cc_faculty__delete', 'faculty_id');

create function cc_faculty__delete (integer)
returns integer as '
declare
  p_faculty_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_faculty_id;

	delete from cc_faculty
		   where faculty_id = p_faculty_id;

	raise NOTICE ''Deleting Faculty...'';
	PERFORM acs_object__delete(p_faculty_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_faculty__name', 'faculty_id');

create function cc_faculty__name (integer)
returns varchar as '
declare
    p_faculty_id      alias for $1;
    v_faculty_name    cc_faculty.faculty_name%TYPE;
begin
	select faculty_name into v_faculty_name
		from cc_faculty
		where faculty_id = p_faculty_id;

    return v_faculty_name;
end;
' language plpgsql;
