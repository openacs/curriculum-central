<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="depts">
     <querytext>
       SELECT department_id, department_name FROM cc_department WHERE
           faculty_id = :faculty_id
     </querytext>
   </fullquery>

</queryset>
