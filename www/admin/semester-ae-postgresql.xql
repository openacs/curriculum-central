<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="object_new">
     <querytext>
       SELECT cc_semester__new (NULL, :name, $start_date, $end_date,
           :user_id, :peeraddr, :package_id)
     </querytext>
   </fullquery>

   <fullquery name="semester_update">
     <querytext>
       UPDATE cc_semester
	   name = :name,
	   start_date = :start_date,
	   end_date = :end_date
	   WHERE semester_id = :semester_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :semester_id
     </querytext>
   </fullquery>

</queryset>
