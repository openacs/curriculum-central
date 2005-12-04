<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="staff">
     <querytext>
       SELECT s.title || ' ' || u.first_names || ' ' || u.last_name AS name,
         s.position, s.department_id, d.department_name, s.staff_id
       FROM cc_users u, cc_staff s, cc_department d
       WHERE s.staff_id = u.user_id
       AND d.department_id = s.department_id
       ORDER BY department_id, u.last_name ASC
     </querytext>
   </fullquery>

</queryset>
