<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="rel_update">
     <querytext>
       UPDATE cc_stream_uos_rel
	   SET name = :name
	   WHERE stream_uos_rel_id = :stream_uos_rel_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :stream_uos_rel_id
     </querytext>
   </fullquery>

</queryset>
