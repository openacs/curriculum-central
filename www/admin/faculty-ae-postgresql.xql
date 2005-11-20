<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="faculty_update">
     <querytext>
       UPDATE cc_faculty
           SET dean_id = :dean_id,
	   faculty_name = :faculty_name
	   WHERE faculty_id = :faculty_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :faculty_id
     </querytext>
   </fullquery>

</queryset>
