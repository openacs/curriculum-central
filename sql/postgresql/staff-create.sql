--
-- packages/curriculum-central/sql/postgresql/staff-create.sql
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
	''cc_staff'',			-- object_type
	''Staff'',			-- pretty_name
	''Staff'',			-- pretty_plural
	''acs_object'',			-- supertype
	''cc_staff'',			-- table_name
	''staff_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_staff__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_staff (
	staff_id	integer
                        constraint cc_staff_staff_id_fk
                        references users(user_id)
			constraint cc_staff_staff_id_pk primary key,
	title 		varchar(256)
			constraint cc_staff_title_nn not null,
	position 	varchar(256)
			constraint cc_staff_position_nn not null,
	department_id	integer
			constraint cc_staff_department_id_fk
			references cc_department(department_id)
);


--
-- Attributes for the Staff Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_staff'',			-- object_type
	  ''title'',			-- attribute_name
	  ''string'',			-- datatype
	  ''Title'',			-- pretty_name
	  ''Titles'',			-- pretty_plural
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
	  ''cc_staff'',		-- object_type
	  ''position'',			-- attribute_name
	  ''string'',			-- datatype
	  ''Position'',			-- pretty_name
	  ''Positions'',		-- pretty_plural
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


select define_function_args('cc_staff__new', 'staff_id,title,position,department_id');

create function cc_staff__new(integer, varchar, varchar, integer)
returns integer as'

declare

	p_staff_id		alias for $1;
	p_title			alias for $2;
	p_position		alias for $3;
	p_department_id		alias for $4;
begin

	-- The p_staff_id should already exist in acs_objects and users
	-- tables.  cc_staff is a "subtype" of the users table.
	insert into cc_staff values(p_staff_id, p_title, p_position, p_department_id);
	
	return p_staff_id;

end;
' language plpgsql;


select define_function_args('cc_staff__delete', 'staff_id');

create function cc_staff__delete (integer)
returns integer as '
declare
  p_staff_id				alias for $1;
begin
	delete from cc_staff
		   where staff_id = p_staff_id;

	raise NOTICE ''Deleting staff...'';

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_staff__name', 'staff_id');

create function cc_staff__name (integer)
returns varchar as '
declare
    p_staff_id      alias for $1;
begin
    return person__name(p_staff_id);
end;
' language plpgsql;
