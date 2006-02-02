--
-- packages/curriculum-central/sql/postgresql/uos-names-create.sql
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
	''cc_uos_name'',			-- object_type
	''#curriculum-central.uos_name#'',	-- pretty_name
	''#curriculum-central.uos_names#'',	-- pretty_plural
	''acs_object'',				-- supertype
	''cc_uos_name'',			-- table_name
	''name_id'',				-- id_column
	null,					-- package_name
	''f'',					-- abstract_p
	null,					-- type_extension_table
	''cc_uos_name__name''			-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_uos_name (
	name_id	integer
                        constraint cc_uos_name_name_id_fk
                        references acs_objects(object_id)
			constraint cc_uos_name_name_id_pk primary key,
	uos_code	varchar(256)
			constraint cc_uos_name_uos_code_nn not null
			constraint cc_uos_name_uos_code_un unique,
	uos_name 	varchar(256)
			constraint cc_uos_name_uos_name_nn not null
			constraint cc_uos_name_uos_name_un unique,
	package_id	integer
			constraint cc_uos_name_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the UoS Name Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_uos_name'',		-- object_type
	  ''uos_code'',			-- attribute_name
	  ''string'',			-- datatype
	  ''curriculum-central.uos_code'',	-- pretty_name
	  ''curriculum-central.uos_codes'',	-- pretty_plural
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
	  ''cc_uos_name'',		-- object_type
	  ''uos_name'',			-- attribute_name
	  ''string'',			-- datatype
	  ''curriculum-central.uos_name'',	-- pretty_name
	  ''curriculum-central.uos_names'',	-- pretty_plural
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


select define_function_args ('cc_uos_name__new', 'name_id,uos_code,uos_name,creation_user,creation_ip,package_id');

create function cc_uos_name__new (
	integer,		-- name_id
	varchar,		-- uos_code
	varchar,		-- uos_name
	integer,		-- creation_user
	varchar,		-- creation_ip
	integer			-- package_id
) returns integer as'

declare

	p_name_id		alias for $1;
	p_uos_code		alias for $2;
	p_uos_name		alias for $3;
	p_creation_user		alias for $4;
	p_creation_ip		alias for $5;
	p_package_id		alias for $6;

	v_name_id		cc_uos_name.name_id%TYPE;
begin

	v_name_id := acs_object__new (
			p_name_id,
			''cc_uos_name'',
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_uos_name values (
		v_name_id,
		p_uos_code,
		p_uos_name,
		p_package_id
	);
	
	PERFORM acs_permission__grant_permission(
          v_name_id,
          p_creation_user,
          ''read''
    	);

	PERFORM acs_permission__grant_permission(
          v_name_id,
          p_creation_user,
          ''write''
    	);

	return v_name_id;

end;
' language plpgsql;


select define_function_args('cc_uos_name__delete', 'name_id');

create function cc_uos_name__delete (integer)
returns integer as '
declare
  p_name_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_name_id;

	delete from cc_uos_name
		   where name_id = p_name_id;

	raise NOTICE ''Deleting UoS Name...'';
	PERFORM acs_object__delete(p_name_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_uos_name__name', 'name_id');

create function cc_uos_name__name (integer)
returns varchar as '
declare
    p_name_id      		alias for $1;
    v_uos_name    		cc_uos_name.uos_name%TYPE;
begin
	select uos_name into v_uos_name
		from cc_uos_name
		where name_id = p_name_id;

    return v_uos_name;
end;
' language plpgsql;


create function cc_uos_name__code (integer)
returns varchar as '
declare
    p_name_id      		alias for $1;
    v_uos_code    		cc_uos_name.uos_code%TYPE;
begin
	select uos_code into v_uos_code
		from cc_uos_name
		where name_id = p_name_id;

    return v_uos_code;
end;
' language plpgsql;
