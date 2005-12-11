<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="faculties">
     <querytext>
       SELECT faculty_id, faculty_name FROM cc_faculty WHERE
           package_id = :package_id
     </querytext>
   </fullquery>

</queryset>
