<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="week_update">
     <querytext>
       UPDATE cc_uos_schedule_week
           SET name = :name
	   WHERE week_id = :week_id
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
