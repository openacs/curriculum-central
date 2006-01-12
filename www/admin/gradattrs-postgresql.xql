<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_gradattrs">
     <querytext>
       SELECT g.name_id, g.name
       FROM cc_uos_gradattr_name g
	   WHERE g.package_id = :package_id
	   [template::list::orderby_clause -orderby -name "gradattrs"]
     </querytext>
   </fullquery>

</queryset>
