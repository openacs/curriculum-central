--
-- packages/curriculum-central/sql/postgresql/uos-textbook-create.sql
--
-- @author Nick Carroll (nick.c@rroll.net)
-- @creation-date 2006-01-06
-- @cvs-id $Id$
--
--


create function inline_0 ()
returns integer as'
begin 
    PERFORM acs_object_type__create_type (
	''cc_uos_textbook_set'',			-- object_type
	''#curriculum-central.uos_textbook_set#'', 	-- pretty_name
	''#curriculum-central.uos_textbook_sets#'',  	-- pretty_plural
	''acs_object'',					-- supertype
	''cc_uos_textbook_set'',			-- table_name
	''textbook_set_id'',				-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	null						-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- Register UoS textbook set as a child type of Uos.
select content_type__register_child_type (
    'cc_uos',                	-- parent_type 
    'cc_uos_textbook_set',      -- child_type
    'generic',               	-- relation_tag
    0,                       	-- min_n
    null                     	-- max_n
);


-- content_item subtype
create table cc_uos_textbook_set (
	textbook_set_id		integer
                        	constraint cc_uos_textbook_set_fk
                        	references cr_items(item_id)
				on delete cascade
				constraint cc_uos_textbook_set_pk
				primary key,
	parent_uos_id		integer,
	live_revision_id	integer,
	latest_revision_id	integer
);


-- Create the UoS Textbook set content_revision
-- A revision may point to many Textbooks in the mapping
-- table below.
create table cc_uos_textbook_set_revs (
	tb_set_revision_id	integer
				constraint cc_uos_textbook_set_rev_pk
				primary key
				constraint cc_uos_textbook_set_rev_fk
				references cr_revisions(revision_id)
				on delete cascade
);

-- Create the UoS revision content type.
select content_type__create_type (
    'cc_uos_textbook_set_rev',
    'content_revision',
    '#curriculum-central.uos_textbook_set_revision#',
    '#curriculum-central.uos_textbook_set_revisions#',
    'cc_uos_textbook_set_revs',
    'tb_set_revision_id',
    'content_revision.revision_name'
);

-- Register uos_textbook_set_revision as a child type of uos_revision.
select content_type__register_child_type (
    'cc_uos_revision',			-- parent_type 
    'cc_uos_textbook_set_rev',		-- child_type
    'generic',               		-- relation_tag
    0,                       		-- min_n
    null                     		-- max_n
);


-- Create Textbook object
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
    ''cc_uos_textbook'', 				-- object_type
    ''#curriculum-central.textbook#'',	  	 	-- pretty_name
    ''#curriculum-central.textbooks#'', 	 	-- pretty_plural
    ''acs_object'',                			-- supertype
    ''cc_uos_textbook'',	    			-- table_name
    ''textbook_id'',               			-- id_column
    null,                          			-- package_name
    ''f'',                         			-- abstract_p
    null,                          			-- type_extension_table
    ''cc_uos_textbook__name''		      		-- name_method
    );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- Create the table that will be used to store information about a textbook.
create table cc_uos_textbook (
	textbook_id		integer
				constraint cc_uos_textbook_id_fk
				references acs_objects(object_id)
				constraint cc_uos_textbook_id_pk
				primary key,
	title			varchar(256), -- title of book
	author			varchar(256), -- author of book
	publisher		varchar(256), -- publisher of book
	isbn			varchar(256)  -- book's ISBN
);

-- Create Mapping table between revision and texbook.
-- A revision can refer to many textbookss, since a
-- Unit of Study may require students to study many textbooks.
create table cc_uos_textbook_map (
	revision_id		integer
				constraint cc_uos_textbook_map_rev_id_fk
				references cc_uos_textbook_set_revs(tb_set_revision_id),
	textbook_id		integer
				constraint cc_uos_textbook_map_textbook_id_fk
				references cc_uos_textbook(textbook_id)
);


--
--
-- Create the functions for the textbook content item and revisions.
--
--

select define_function_args('cc_uos_textbook_set__new', 'textbook_set_id,parent_uos_id,creation_user,creation_ip,context_id,item_subtype;cc_uos_textbook_set,content_type;cc_uos_textbook_set_rev,object_type,package_id');

create function cc_uos_textbook_set__new(
	integer,	-- textbook_set_id
	integer,	-- parent_uos_id
	integer,	-- creation_user
	varchar,	-- creation_ip
	integer,	-- context_id
	varchar,	-- item_subtype
	varchar,	-- content_type
	varchar,	-- object_type
	integer		-- package_id
) returns integer as'
declare

	p_textbook_set_id		alias for $1;
	p_parent_uos_id			alias for $2;
	p_creation_user			alias for $3;
	p_creation_ip			alias for $4;
	p_context_id			alias for $5;
	p_item_subtype			alias for $6;
	p_content_type			alias for $7;
	p_object_type			alias for $8;
	p_package_id			alias for $9;

	v_textbook_set_id		cc_uos_textbook_set.textbook_set_id%TYPE;
	v_folder_id			integer;
	v_revision_id			integer;
	v_name				varchar;
	v_rel_id			integer;
begin
	-- get the content folder for this instance
	select folder_id into v_folder_id
	    from cc_curriculum
	    where curriculum_id = p_package_id;

	-- Create a unique name
	-- Can only have one textbook set per Unit of Study,
	-- so append uos_id
	-- to "uos_textbook_set_for_".
	v_name := ''uos_textbook_set_for_'' || p_parent_uos_id;

	-- create the content item
	v_textbook_set_id := content_item__new (
		v_name,			-- name
		v_folder_Id,		-- parent_id
		p_textbook_set_id,	-- item_id
		null,			-- locale
		now(),			-- creation_date
		p_creation_user,	-- creation_user
		v_folder_id,		-- context_id
		p_creation_ip,		-- creation_ip
		p_item_subtype,		-- item_subtype
		p_content_type,		-- content_type
		null,			-- title
		null,			-- description
		null,			-- mime_type
		null,			-- nls_language
		null,			-- data
		p_package_id
	);

	-- create the initial revision
	v_revision_id := cc_uos_textbook_set_rev__new (
		null,				-- textbook_set_revision_id
		v_textbook_set_id,		-- textbook_set_id
		now(),				-- creation_date
		p_creation_user,		-- creation_user
		p_creation_ip			-- creation_ip
	);

	-- create the item type row
	INSERT INTO cc_uos_textbook_set (
		textbook_set_id, parent_uos_id, latest_revision_id
	) VALUES (
		v_textbook_set_id, p_parent_uos_id, v_revision_id
	);


	-- associate the UoS textbook set with the parent UoS
	v_rel_id := acs_object__new(
		NULL,
      		''cr_item_child_rel'',
      		current_timestamp,
      		p_creation_user,
      		p_creation_ip,
      		p_package_id
	);

  	INSERT INTO cr_child_rels (
      		rel_id, parent_id, child_id, relation_tag
      	) VALUES (
      		v_rel_id,
		p_parent_uos_id,
		v_textbook_set_id,
		''cc_uos_textbook_set''
  	);	

	return v_textbook_set_id;

end;
' language plpgsql;


select define_function_args('cc_uos_textbook_set__delete', 'textbook_set_id');

create function cc_uos_textbook_set__delete (integer)
returns integer as '
declare
	p_textbook_set_id		alias for $1;
begin

	perform content_item__delete(p_textbook_set_id);

	return 0;

end;
' language 'plpgsql';


create or replace function cc_uos_textbook_set_rev__new (
	integer,			-- textbook_set_revision_id
	integer,			-- textbook_set_id
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar				-- creation_ip
) returns int
as '
declare
	p_textbook_set_revision_id		alias for $1;
	p_textbook_set_id			alias for $2;
	p_creation_date				alias for $3;
	p_creation_user				alias for $4;
	p_creation_ip				alias for $5;

	v_revision_id				integer;
	v_title					varchar;
begin

	-- create the initial revision
	v_revision_id := content_revision__new (
		''#curriculum-central.uos_textbooks#'',  -- title
		null,					-- description
		current_timestamp,			-- publish_date
		null,					-- mime_type
		null,					-- nls_language
		null,					-- new_data
		p_textbook_set_id,			-- item_id
		p_textbook_set_revision_id,		-- revision_id
		p_creation_date,			-- creation_date
		p_creation_user,			-- creation_user
		p_creation_ip				-- creation_ip
	);

	-- insert into the uos-specific revision table
	INSERT INTO cc_uos_textbook_set_revs (tb_set_revision_id)
	VALUES (v_revision_id);

	-- Update the latest revision id in cc_uos_textbook_set
	UPDATE cc_uos_textbook_set SET latest_revision_id = v_revision_id
	WHERE textbook_set_id = p_textbook_set_id;

	return v_revision_id;
end;
' language 'plpgsql';


--
--
-- Create the functions for the cc_uos_textbook object.
--
--

select define_function_args('cc_uos_textbook__new','textbook_id,title,author,publisher,isbn,creation_date;now,creation_user,creation_ip,package_id,context_id');

create function cc_uos_textbook__new (
	integer,			-- textbook_id
	varchar,			-- title
	varchar,			-- author
	varchar,			-- publisher
	varchar,			-- isbn
	timestamptz,			-- creation_date
	integer,			-- creation_user
	varchar,			-- creation_ip
	integer,			-- package_id
	integer				-- context_id
) returns integer as '
declare
    	p_textbook_id			alias for $1;        -- default null
    	p_title				alias for $2;
    	p_author			alias for $3;
	p_publisher			alias for $4;
	p_isbn				alias for $5;
    	p_creation_date             	alias for $6;        -- default now()
    	p_creation_user             	alias for $7;        -- default null
    	p_creation_ip              	alias for $8;        -- default null
	p_package_id			alias for $9;
    	p_context_id                	alias for $10;       -- default null

	v_textbook_id			cc_uos_textbook.textbook_id%TYPE;
	v_title				varchar;
begin
	v_title := p_title || '', '' || p_author;

	v_textbook_id := acs_object__new (
        	p_textbook_id,
        	''cc_uos_textbook'',
        	p_creation_date,
        	p_creation_user,
        	p_creation_ip,
        	p_context_id,
		v_title,
		p_package_id
    	);

	INSERT INTO cc_uos_textbook (
		textbook_id, title, author, publisher, isbn
	)
	VALUES (
		v_textbook_id, p_title, p_author, p_publisher, p_isbn
	);

    return v_textbook_id;

end;' language 'plpgsql';


select define_function_args('cc_uos_textbook__del','textbook_id');

create function cc_uos_textbook__del (integer)
returns integer as '
declare
    	p_textbook_id                alias for $1;
begin
    	DELETE FROM acs_permissions WHERE object_id = p_textbook_id;

    	DELETE FROM cc_uos_textbook WHERE textbook_id = p_textbook_id;

	RAISE NOTICE ''Deleting textbook...'';
    	PERFORM acs_object__delete(p_textbook_id);

	return 0;

end;' language 'plpgsql';


select define_function_args('cc_uos_textbook__name','textbook_id');

create function cc_uos_textbook__name (integer)
returns varchar as '
declare
    	p_textbook_id      alias for $1;

	v_textbook_title    cc_uos_textbook.title%TYPE;
begin
	SELECT title INTO v_textbook_title
       	FROM cc_uos_textbook
        WHERE textbook_id = p_textbook_id;

    	return v_textbook_title;
end;
' language 'plpgsql';


--
-- Maps a textbook to a textbook revision set.
--
create function cc_uos_textbook__map (
	integer,			-- revision_id
	integer				-- textbook_id
) returns integer as '
declare
	p_revision_id		alias for $1;
	p_textbook_id		alias for $2;
begin

	RAISE NOTICE ''Mapping textbook to a revision set...'';

	INSERT INTO cc_uos_textbook_map (revision_id, textbook_id)
	VALUES (p_revision_id, p_textbook_id);

	return 0;
end;
' language 'plpgsql';


--
-- Unmaps a textbook from a revision set.
--
create function cc_uos_textbook__unmap (
	integer,			-- revision_id
	integer				-- textbook_id
) returns integer as '
declare
	p_revision_id		alias for $1;
	p_textbook_id		alias for $2;
begin

	RAISE NOTICE ''Deleting mapping between textbook and revision set...'';

	DELETE FROM cc_uos_textbook_map
	WHERE revision_id = p_revision_id
	AND textbook_id = p_textbook_id;

	return 0;
end;
' language 'plpgsql';
