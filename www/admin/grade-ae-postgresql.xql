<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="grade_update">
     <querytext>
       UPDATE cc_uos_grade_type
           SET name = :name,
	   lower_bound = :lower_bound,
	   upper_bound = :upper_bound
	   WHERE type_id = :type_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :type_id
     </querytext>
   </fullquery>

</queryset>
