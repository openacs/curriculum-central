--
-- packages/curriculum-central/sql/postgresql/stream-uos-rel-create.sql
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
	''cc_stream_uos_rel'',			-- object_type
	''#curriculum-central.stream_uos_rel#'',	-- pretty_name
	''#curriculum-central.stream_uos_rels#'',	-- pretty_plural
	''acs_object'',				-- supertype
	''cc_stream_uos_rel'',			-- table_name
	''stream_uos_rel_id'',			-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	''cc_stream_uos_rel__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_stream_uos_rel (
	stream_uos_rel_id	integer
                        constraint cc_stream_uos_rel_stream_uos_rel_id_fk
                        references acs_objects(object_id)
			constraint cc_stream_uos_rel_stream_uos_rel_id_pk
			primary key,
	name 		varchar(256)
			constraint cc_stream_uos_rel_name_nn not null,
	package_id	integer
			constraint cc_stream_uos_rel_package_id_fk
			references apm_packages(package_id) on delete cascade
);


--
-- Attributes for the Stream_Uos_Rel Object
--
create function inline_1 ()
returns integer as '
begin
    PERFORM acs_attribute__create_attribute (
	  ''cc_stream_uos_rel'',		-- object_type
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


select define_function_args('cc_stream_uos_rel__new', 'stream_uos_rel_id,name,creation_user,creation_ip,package_id');

create function cc_stream_uos_rel__new(integer, varchar, integer, varchar, integer)
returns integer as'

declare

	p_stream_uos_rel_id	alias for $1;
	p_name			alias for $2;
	p_creation_user		alias for $3;
	p_creation_ip		alias for $4;
	p_package_id		alias for $5;

	v_stream_uos_rel_id	cc_stream_uos_rel.stream_uos_rel_id%TYPE;
begin

	v_stream_uos_rel_id := acs_object__new (
			p_stream_uos_rel_id,
			''cc_stream_uos_rel'',
			now(),
			p_creation_user,
			p_creation_ip,
			p_package_id
		);

	insert into cc_stream_uos_rel values(v_stream_uos_rel_id, p_name, p_package_id);
	
	PERFORM acs_permission__grant_permission(
          v_stream_uos_rel_id,
          p_creation_user,
          ''read''
    	);

	PERFORM acs_permission__grant_permission(
          v_stream_uos_rel_id,
          p_creation_user,
          ''write''
    	);

	return v_stream_uos_rel_id;

end;
' language plpgsql;


select define_function_args('cc_stream_uos_rel__delete', 'stream_uos_rel_id');

create function cc_stream_uos_rel__delete (integer)
returns integer as '
declare
  p_stream_uos_rel_id				alias for $1;
begin
    delete from acs_permissions
		   where object_id = p_stream_uos_rel_id;

	delete from cc_stream_uos_rel
		   where stream_uos_rel_id = p_stream_uos_rel_id;

	raise NOTICE ''Deleting Stream_Uos_Rel...'';
	PERFORM acs_object__delete(p_stream_uos_rel_id);

	return 0;

end;' 
language plpgsql;


select define_function_args('cc_stream_uos_rel__name', 'stream_uos_rel_id');

create function cc_stream_uos_rel__name (integer)
returns varchar as '
declare
    p_stream_uos_rel_id      alias for $1;
    v_stream_uos_rel_name    cc_stream_uos_rel.name%TYPE;
begin
	select name into v_stream_uos_rel_name
		from cc_stream_uos_rel
		where stream_uos_rel_id = p_stream_uos_rel_id;

    return v_stream_uos_rel_name;
end;
' language plpgsql;
