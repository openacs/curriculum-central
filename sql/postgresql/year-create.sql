--
-- packages/curriculum-central/sql/postgresql/year-create.sql
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
	''cc_year'',			-- object_type
	''#curriculum-central.year#'',	-- pretty_name
	''#curriculum-central.years#'',	-- pretty_plural
	''acs_object'',			-- supertype
	''cc_year'',			-- table_name
	''year_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_year__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_year (
	year_id	integer
                        constraint cc_year_year_id_fk
                        references acs_objects(object_id)
			constraint cc_year_year_id_pk primary key,
	name 		varchar(256)
			constraint cc_year_name_nn not null
			constraint cc_year_name_un unique,
	package_id	integer
			constraint cc_year_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Year Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_year'',		-- object_type
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


select define_function_args('cc_year__new', 'year_id,name,creation_user,creation_ip,package_id');

create function cc_year__new(integer, varchar, integer, varchar, integer)
returns integer as'

declare

	p_year_id		alias for $1;
	p_name			alias for $2;
	p_creation_user		alias for $3;
	p_creation_ip		alias for $4;
	p_package_id		alias for $5;

	v_year_id		cc_year.year_id%TYPE;
begin

	v_year_id := acs_object__new (
			p_year_id,
			''cc_year'',
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_year values(v_year_id, p_name, p_package_id);
	
	PERFORM acs_permission__grant_permission(
          v_year_id,
          p_creation_user,
          ''read''
    	);

	PERFORM acs_permission__grant_permission(
          v_year_id,
          p_creation_user,
          ''write''
    	);

	return v_year_id;

end;
' language plpgsql;


select define_function_args('cc_year__delete', 'year_id');

create function cc_year__delete (integer)
returns integer as '
declare
  p_year_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_year_id;

	delete from cc_year
		   where year_id = p_year_id;

	raise NOTICE ''Deleting Year...'';
	PERFORM acs_object__delete(p_year_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_year__name', 'year_id');

create function cc_year__name (integer)
returns varchar as '
declare
    p_year_id      alias for $1;
    v_year_name    cc_year.name%TYPE;
begin
	select name into v_year_name
		from cc_year
		where year_id = p_year_id;

    return v_year_name;
end;
' language plpgsql;
