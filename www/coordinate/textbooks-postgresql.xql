<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_textbooks">
     <querytext>
       SELECT t.textbook_id, t.title, t.author, t.publisher, t.isbn
       FROM cc_uos_textbook t, acs_objects o
	   WHERE package_id = :package_id
	   AND t.textbook_id = o.object_id
	   AND o.creation_user = :user_id
	   [template::list::orderby_clause -orderby -name "textbooks"]
     </querytext>
   </fullquery>

</queryset>
