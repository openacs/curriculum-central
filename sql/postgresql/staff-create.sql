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
			references cc_department(department_id),
	address_line_1	varchar(256),
	address_line_2	varchar(256),
	address_suburb	varchar(256),
	address_state	varchar(256),
	address_postcode	varchar(256),
	address_country	varchar(256),
	phone		varchar(256),
	fax		varchar(256),
	homepage_url	varchar(256)
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
	  ''cc_staff'',					-- object_type
	  ''position'',					-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.position'',		-- pretty_name
	  ''curriculum-central.positions'',		-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''address_line_1'',				-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.address_line_1'',	-- pretty_name
	  ''curriculum-central.address_line_1'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''address_line_2'',				-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.address_line_2'',	-- pretty_name
	  ''curriculum-central.address_line_2'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''address_suburb'',				-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.address_suburb'',	-- pretty_name
	  ''curriculum-central.address_suburbs'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''address_state'',				-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.address_state'',		-- pretty_name
	  ''curriculum-central.address_states'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''address_postcode'',				-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.address_postcode'',	-- pretty_name
	  ''curriculum-central.address_postcodes'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''address_country'',				-- attribute_name
	  ''string'',					-- datatype
	  ''curriculum-central.address_country'',	-- pretty_name
	  ''curriculum-central.address_countries'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''phone'',					-- attribute_name
	  ''string'',					-- datatype
	  ''#curriculum-central.phone_number#'',	-- pretty_name
	  ''#curriculum-central.phone_numbers#'',	-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''fax'',					-- attribute_name
	  ''string'',					-- datatype
	  ''#curriculum-central.fax_number#'',		-- pretty_name
	  ''#curriculum-central.fax_numbers#'',		-- pretty_plural
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
	  ''cc_staff'',					-- object_type
	  ''homepage_url'',				-- attribute_name
	  ''string'',					-- datatype
	  ''#curriculum-central.homepage#'',		-- pretty_name
	  ''#curriculum-central.homepages#'',		-- pretty_plural
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


select define_function_args('cc_staff__new', 'staff_id,title,position,department_id,address_line_1,address_line_2,address_suburb,address_state,address_postcode,address_country,phone,fax,homepage_url');

create function cc_staff__new(integer, varchar, varchar, integer, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar)
returns integer as'

declare

	p_staff_id		alias for $1;
	p_title			alias for $2;
	p_position		alias for $3;
	p_department_id		alias for $4;
	p_address_line_1	alias for $5;
	p_address_line_2	alias for $6;
	p_address_suburb	alias for $7;
	p_address_state		alias for $8;
	p_address_postcode	alias for $9;
	p_address_country	alias for $10;
	p_phone			alias for $11;
	p_fax			alias for $12;
	p_homepage_url		alias for $13;
begin

	-- The p_staff_id should already exist in acs_objects and users
	-- tables.  cc_staff is a "subtype" of the users table.
	insert into cc_staff values(p_staff_id, p_title, p_position, p_department_id, p_address_line_1, p_address_line_2, p_address_suburb, p_address_state, p_address_postcode, p_address_country, p_phone, p_fax, p_homepage_url);
	
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
