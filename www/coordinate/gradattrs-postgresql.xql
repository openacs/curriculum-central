<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_gradattrs">
     <querytext>
       SELECT g.gradattr_id, n.name,
           g.identifier, g.description, g.level
       FROM cc_uos_gradattr g, acs_objects o, cc_uos_gradattr_name n
	   WHERE n.package_id = :package_id
	   AND g.gradattr_id = o.object_id
	   AND o.creation_user = :user_id
	   AND n.name_id = g.name_id
	   [template::list::orderby_clause -orderby -name "gradattrs"]
     </querytext>
   </fullquery>

</queryset>
