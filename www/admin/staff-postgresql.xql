<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="staff">
     <querytext>
       SELECT s.title || ' ' || u.first_names || ' ' || u.last_name
         AS staff_name, s.staff_id,
         s.position, s.department_id, d.department_name, d.faculty_id,
	 (SELECT faculty_name FROM cc_faculty f
           WHERE f.faculty_id = d.faculty_id) as faculty_name
       FROM cc_users u, cc_staff s, cc_department d
       WHERE s.staff_id = u.user_id
       AND d.department_id = s.department_id
       [template::list::orderby_clause -orderby -name "staff"]
     </querytext>
   </fullquery>

</queryset>
