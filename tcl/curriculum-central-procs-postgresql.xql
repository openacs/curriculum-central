<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::curriculum_new.instance_info">
     <querytext>
	select p.instance_name, o.creation_user, o.creation_ip
	from apm_packages p join acs_objects o on (p.package_id = o.object_id)
        where p.package_id = :curriculum_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::curriculum_new.already_there">
     <querytext>
       SELECT 1 from cc_curriculum where curriculum_id = :curriculum_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::curriculum_new.cc_curriculum_insert">
     <querytext>
       INSERT INTO cc_curriculum (curriculum_id, folder_id, root_keyword_id)
           VALUES (:curriculum_id, :folder_id, :keyword_id)
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::curriculum_delete.delete_curriculum">
     <querytext>
       SELECT cc_curriculum__delete(:curriculum_id)
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::users_get_options.users">
     <querytext>
       SELECT first_names || ' ' || last_name || ' (' || email || ')'  AS name,
           user_id
	   FROM   cc_users
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::non_staff_get_options.non_staff">
     <querytext>
       SELECT first_names || ' ' || last_name || ' (' || email || ')'  AS name,
           user_id
	   FROM   cc_users
	   WHERE user_id NOT IN (SELECT staff_id FROM cc_staff)
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::staff_get_options.staff">
     <querytext>
       SELECT s.title || ' ' || u.first_names || ' ' || u.last_name || ' (' || email || ')'  AS name,
           staff_id
	   FROM   cc_staff s, cc_users u
	   WHERE s.staff_id = u.user_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::departments_get_options.departments">
     <querytext>
       SELECT department_name, department_id FROM cc_department
           WHERE package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::tl_names_get_options.tl_names">
     <querytext>
       SELECT name, name_id FROM cc_uos_tl_name
           WHERE package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::graduate_attribute_names_get_options.ga_names">
     <querytext>
       SELECT name, name_id FROM cc_uos_gradattr_name
           WHERE package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::join_sessions.session_name">
     <querytext>
       SELECT name FROM cc_session
       WHERE session_id = :session_id
       AND package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::join_graduate_attributes.ga_name">
     <querytext>
       SELECT gan.name
       FROM cc_uos_gradattr_name gan, cc_uos_gradattr_map gam,
           cc_uos_gradattr ga, cc_uos_gradattr_set gas
       WHERE gas.parent_uos_id = :uos_id
       AND gas.latest_revision_id = gam.revision_id
       AND gam.gradattr_id = ga.gradattr_id
       AND ga.name_id = gan.name_id
     </querytext>
   </fullquery>

</queryset>
