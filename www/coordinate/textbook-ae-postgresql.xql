<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="textbook_update">
     <querytext>
       UPDATE cc_uos_textbook
           SET title = :title,
	   author = :author,
	   publisher = :publisher,
	   isbn = :isbn
	   WHERE textbook_id = :textbook_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip,
	   package_id = :package_id
	   WHERE object_id = :textbook_id
     </querytext>
   </fullquery>

</queryset>
