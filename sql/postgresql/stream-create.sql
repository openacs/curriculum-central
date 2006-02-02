--
-- packages/curriculum-central/sql/postgresql/stream-create.sql
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
	''cc_stream'',			-- object_type
	''Stream'',			-- pretty_name
	''Streams'',			-- pretty_plural
	''acs_object'',			-- supertype
	''cc_stream'',			-- table_name
	''stream_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_stream__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_stream (
	stream_id	integer
                        constraint cc_stream_stream_id_fk
                        references acs_objects(object_id)
			constraint cc_stream_stream_id_pk primary key,
	coordinator_id	integer
			constraint cc_stream_coordinator_id_fk
			references users(user_id)
			constraint cc_stream_coordinator_id_nn
                        not null,
	stream_name 	varchar(256)
			constraint cc_stream_stream_name_nn not null
			constraint cc_stream_stream_name_un unique,
	stream_code 	varchar(256),
	year_ids	varchar(256),
	department_id	integer
			constraint cc_stream_department_id_fk
			references cc_department(department_id)
			constraint cc_stream_department_id_nn
			not null,
	package_id	integer
			constraint cc_stream_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Stream Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_stream'',		-- object_type
	  ''stream_name'',		-- attribute_name
	  ''string'',			-- datatype
	  ''Stream Name'',		-- pretty_name
	  ''Stream Names'',		-- pretty_plural
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
	  ''cc_stream'',		-- object_type
	  ''stream_code'',		-- attribute_name
	  ''string'',			-- datatype
	  ''Stream Code'',		-- pretty_name
	  ''Stream Codes'',		-- pretty_plural
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


select define_function_args('cc_stream__new', 'stream_id,coordinator_id,object_type,stream_name,stream_code,year_ids,department_id,creation_user,creation_ip,package_id');

create function cc_stream__new(
	integer,	-- stream_id
	integer,	-- coordinator_id
	varchar,	-- object_type
	varchar,	-- stream_name
	varchar,	-- stream_code
	varchar,	-- year_ids
	integer,	-- department_id
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer		-- package_id
) returns integer as'

declare

	p_stream_id		alias for $1;
	p_coordinator_id	alias for $2;
	p_object_type		alias for $3;
	p_stream_name		alias for $4;
	p_stream_code		alias for $5;
	p_year_ids		alias for $6;
	p_department_id		alias for $7;
	p_creation_user		alias for $8;
	p_creation_ip		alias for $9;
	p_package_id		alias for $10;

	v_stream_id		cc_stream.stream_id%TYPE;
begin

	v_stream_id := acs_object__new (
			p_stream_id,
			p_object_type,
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_stream values(v_stream_id, p_coordinator_id, p_stream_name, p_stream_code, p_year_ids, p_department_id,  p_package_id);
	
	PERFORM acs_permission__grant_permission(
          v_stream_id,
          p_coordinator_id,
          ''read''
    	);

	PERFORM acs_permission__grant_permission(
          v_stream_id,
          p_coordinator_id,
          ''write''
    	);

	return v_stream_id;

end;
' language plpgsql;


select define_function_args('cc_stream__delete', 'stream_id');

create function cc_stream__delete (integer)
returns integer as '
declare
  p_stream_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_stream_id;

	delete from cc_stream
		   where stream_id = p_stream_id;

	raise NOTICE ''Deleting Stream...'';
	PERFORM acs_object__delete(p_stream_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_stream__name', 'stream_id');

create function cc_stream__name (integer)
returns varchar as '
declare
    p_stream_id      alias for $1;
    v_stream_name    cc_stream.stream_name%TYPE;
begin
	select stream_name into v_stream_name
		from cc_stream
		where stream_id = p_stream_id;

    return v_stream_name;
end;
' language plpgsql;


-- Create Stream to UoS mapping object.
\i stream-uos-map-create.sql
