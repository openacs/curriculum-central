<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="dept_update">
     <querytext>
       UPDATE cc_department
           SET hod_id = :hod_id,
	   department_name = :department_name
	   WHERE department_id = :department_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :department_id
     </querytext>
   </fullquery>

</queryset>
