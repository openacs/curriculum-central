<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="gradattr_update">
     <querytext>
       UPDATE cc_uos_gradattr_name
           SET name = :name
	   WHERE name_id = :name_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip,
	   package_id = :package_id
	   WHERE object_id = :name_id
     </querytext>
   </fullquery>

</queryset>
