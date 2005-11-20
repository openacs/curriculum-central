<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="stream_update">
     <querytext>
       UPDATE cc_stream
           SET coordinator_id = :coordinator_id,
	   stream_name = :stream_name,
	   stream_code = :stream_code,
	   department_id = :department_id
	   WHERE stream_id = :stream_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :stream_id
     </querytext>
   </fullquery>

</queryset>
