--
-- packages/curriculum-central/sql/postgresql/semester-create.sql
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
	''cc_semester'',			-- object_type
	''#curriculum-central.semester#'',	-- pretty_name
	''#curriculum-central.semesters#'',	-- pretty_plural
	''acs_object'',				-- supertype
	''cc_semester'',			-- table_name
	''semester_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_semester__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_semester (
	semester_id	integer
                        constraint cc_semester_semester_id_fk
                        references acs_objects(object_id)
			constraint cc_semester_semester_id_pk primary key,
	name 		varchar(256)
			constraint cc_semester_name_nn not null
			constraint cc_semester_name_un unique,
	start_date 	timestamptz,
	end_date	timestamptz,
	package_id	integer
			constraint cc_semester_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Semester Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_semester'',		-- object_type
	  ''name'',			-- attribute_name
	  ''string'',			-- datatype
	  ''curriculum-central.name'',	-- pretty_name
	  ''curriculum-central.names'',	-- pretty_plural
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


select define_function_args('cc_semester__new', 'semester_id,name,start_date,end_date,creation_user,creation_ip,package_id');

create function cc_semester__new(integer, varchar, timestamptz, timestamptz, integer, varchar, integer)
returns integer as'

declare

	p_semester_id		alias for $1;
	p_name			alias for $2;
	p_start_date		alias for $3;
	p_end_date		alias for $4;
	p_creation_user		alias for $5;
	p_creation_ip		alias for $6;
	p_package_id		alias for $7;

	v_semester_id		cc_semester.semester_id%TYPE;
begin

	v_semester_id := acs_object__new (
			p_semester_id,
			''cc_semester'',
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_semester values(v_semester_id, p_name, p_start_date, p_end_date, p_package_id);
	
	PERFORM acs_permission__grant_permission(
          v_semester_id,
          p_creation_user,
          ''read''
    	);

	PERFORM acs_permission__grant_permission(
          v_semester_id,
          p_creation_user,
          ''write''
    	);

	return v_semester_id;

end;
' language plpgsql;


select define_function_args('cc_semester__delete', 'semester_id');

create function cc_semester__delete (integer)
returns integer as '
declare
  p_semester_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_semester_id;

	delete from cc_semester
		   where semester_id = p_semester_id;

	raise NOTICE ''Deleting Semester...'';
	PERFORM acs_object__delete(p_semester_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_semester__name', 'semester_id');

create function cc_semester__name (integer)
returns varchar as '
declare
    p_semester_id      alias for $1;
    v_semester_name    cc_semester.name%TYPE;
begin
	select name into v_semester_name
		from cc_semester
		where semester_id = p_semester_id;

    return v_semester_name;
end;
' language plpgsql;
