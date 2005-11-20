<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_faculty_name">
     <querytext>
       SELECT faculty_name FROM cc_faculty
           WHERE faculty_id = :faculty_id
     </querytext>
   </fullquery>

   <fullquery name="get_depts">
     <querytext>
       SELECT department_id, department_name,
           (SELECT first_names || ' ' || last_name
	       FROM cc_users
	       WHERE user_id = hod_id) AS hod
	   FROM cc_department
           WHERE faculty_id = :faculty_id
     </querytext>
   </fullquery>
</queryset>
