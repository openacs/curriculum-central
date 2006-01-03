<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="tl_method_update">
     <querytext>
       UPDATE cc_uos_tl_method
           SET name = :name,
	   identifier = :identifier,
	   description = :description
	   WHERE method_id = :method_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip,
	   package_id = :package_id
	   WHERE object_id = :method_id
     </querytext>
   </fullquery>

</queryset>
