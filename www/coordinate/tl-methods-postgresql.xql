<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_methods">
     <querytext>
       SELECT m.method_id, m.name, m.identifier, m.description
       FROM cc_uos_tl_method m, acs_objects o
	   WHERE package_id = :package_id
	   AND m.method_id = o.object_id
	   [template::list::orderby_clause -orderby -name "methods"]
     </querytext>
   </fullquery>

</queryset>
