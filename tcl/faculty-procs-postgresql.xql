<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::faculty::faculties_exist_p.exist">
     <querytext>
       SELECT * FROM cc_faculty WHERE package_id = :package_id LIMIT 1
     </querytext>
   </fullquery>
</queryset>
