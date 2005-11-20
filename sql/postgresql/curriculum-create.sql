--
-- packages/curriculum-central/sql/postgresql/curriculum-create.sql
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
	''curriculum'',			-- object_type
	''Curriculum'',			-- pretty_name
	''Curriculums'',		-- pretty_plural
	''acs_object'',			-- supertype
	''cc_curriculum'',		-- table_name
	''curriculum_id'',		-- id_column
	null,				-- package_name
	''f'',				-- abstract_p
	null,				-- type_extension_table
	null				-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


create table cc_curriculum (
	curriculum_id		integer
                        	constraint cc_curriculum_apm_packages_fk
                        	references apm_packages(package_id)
				on delete cascade
				constraint cc_curriculum_pk primary key,
	description		text,
	email_subject_name	text,
	coordinator_id		integer
				constraint cc_curriculum_coodinator_id_fk
				references users(user_id),
	folder_id		integer
				constraint cc_curriculum_folder_fk
				references cr_folders(folder_id),
	root_keyword_id		integer
				constraint cc_curriculum_keyword_fk
				references cr_keywords(keyword_id)
);


create or replace function cc_curriculum__delete (
    integer		--curriculum_id
) returns integer
as '
declare
    p_curriculum_id	alias for $1;
    v_folder_id		integer;
    v_root_keyword_id	integer;
begin
    -- get the content folder for this instance
    SELECT folder_id, root_keyword_id
        INTO v_folder_id, v_root_keyword_id
        FROM cc_curriculum
        WHERE curriculum_id = p_curriculum_id;

    DELETE FROM cc_curriculum WHERE curriculum_id = p_curriculum_id;

    -- delete the content folder
    raise notice ''about to delete content_folder.'';
    perform content_folder__delete(v_folder_id);

    -- delete the curriculum keywords
    perform cc_curriculum__keywords_delete(p_curriculum_id, ''t'');

    return 0;
end;
' language 'plpgsql';


create or replace function cc_curriculum__keywords_delete(
    integer,                 -- curriculum_id
    bool                     -- delete_root_p
) returns integer
as '
declare
    p_curriculum_id          	alias for $1;
    p_delete_root_p      	alias for $1;
    v_root_keyword_id     	integer;
    rec                   	record;
begin
    -- get the content folder for this instance
    select root_keyword_id
    into   v_root_keyword_id
    from   cc_curriculum
    where  curriculum_id = p_curriculum_id;

    -- if we are deleting the root, remove it from the curriculum as well
    if p_delete_root_p = 1 then
        update cc_curriculum
        set    root_keyword_id = null 
        where  curriculum_id = p_curriculum_id;
    end if;

    -- delete the curriculum keywords
    for rec in 
        select k2.keyword_id
        from   cr_keywords k1, cr_keywords k2
        where  k1.keyword_id = v_root_keyword_id
        and    k2.tree_sortkey between k1.tree_sortkey and tree_right(k1.tree_sortkey)
        order  by length(k2.tree_sortkey) desc
    loop
        if (p_delete_root_p = 1) or (rec.keyword_id != v_root_keyword_id) then
            perform content_keyword__delete(rec.keyword_id);
        end if;
    end loop;

    return 0;
end;
' language 'plpgsql';