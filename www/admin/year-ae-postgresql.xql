<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="year_update">
     <querytext>
       UPDATE cc_year
	   name = :name
	   WHERE year_id = :year_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip
	   WHERE object_id = :year_id
     </querytext>
   </fullquery>

</queryset>
