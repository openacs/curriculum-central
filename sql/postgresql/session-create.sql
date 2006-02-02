--
-- packages/curriculum-central/sql/postgresql/session-create.sql
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
	''cc_session'',			-- object_type
	''#curriculum-central.session#'',	-- pretty_name
	''#curriculum-central.sessions#'',	-- pretty_plural
	''acs_object'',				-- supertype
	''cc_session'',			-- table_name
	''session_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_session__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_session (
	session_id	integer
                        constraint cc_session_session_id_fk
                        references acs_objects(object_id)
			constraint cc_session_session_id_pk primary key,
	name 		varchar(256)
			constraint cc_session_name_nn not null
			constraint cc_session_name_un unique,
	start_date 	timestamptz,
	end_date	timestamptz,
	package_id	integer
			constraint cc_session_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Session Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_session'',		-- object_type
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


select define_function_args('cc_session__new', 'session_id,name,start_date,end_date,creation_user,creation_ip,package_id');

create function cc_session__new(integer, varchar, timestamptz, timestamptz, integer, varchar, integer)
returns integer as'

declare

	p_session_id		alias for $1;
	p_name			alias for $2;
	p_start_date		alias for $3;
	p_end_date		alias for $4;
	p_creation_user		alias for $5;
	p_creation_ip		alias for $6;
	p_package_id		alias for $7;

	v_session_id		cc_session.session_id%TYPE;
begin

	v_session_id := acs_object__new (
			p_session_id,
			''cc_session'',
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_session values(v_session_id, p_name, p_start_date, p_end_date, p_package_id);
	
	PERFORM acs_permission__grant_permission(
          v_session_id,
          p_creation_user,
          ''read''
    	);

	PERFORM acs_permission__grant_permission(
          v_session_id,
          p_creation_user,
          ''write''
    	);

	return v_session_id;

end;
' language plpgsql;


select define_function_args('cc_session__delete', 'session_id');

create function cc_session__delete (integer)
returns integer as '
declare
  p_session_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_session_id;

	delete from cc_session
		   where session_id = p_session_id;

	raise NOTICE ''Deleting Session...'';
	PERFORM acs_object__delete(p_session_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_session__name', 'session_id');

create function cc_session__name (integer)
returns varchar as '
declare
    p_session_id      alias for $1;
    v_session_name    cc_session.name%TYPE;
begin
	select name into v_session_name
		from cc_session
		where session_id = p_session_id;

    return v_session_name;
end;
' language plpgsql;
