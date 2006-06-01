<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_tl_names">
     <querytext>
       SELECT n.name_id, n.name, n.general_description
       FROM cc_uos_tl_name n
	   WHERE n.package_id = :package_id
	   [template::list::orderby_clause -orderby -name "names"]
     </querytext>
   </fullquery>

</queryset>
