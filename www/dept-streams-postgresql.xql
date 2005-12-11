<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="streams">
     <querytext>
       SELECT stream_id, stream_name FROM cc_stream WHERE
           department_id = :department_id
     </querytext>
   </fullquery>

   <fullquery name="context_faculty">
     <querytext>
       SELECT f.faculty_id, f.faculty_name FROM cc_faculty f, cc_department d
           WHERE d.department_id = :department_id
           AND f.faculty_id = d.faculty_id
     </querytext>
   </fullquery>
</queryset>
