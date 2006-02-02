<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_uos_names">
     <querytext>
       SELECT u.name_id, u.uos_code, u.uos_name
	   FROM cc_uos_name u
	   WHERE package_id = :package_id
	   [template::list::orderby_clause -orderby -name "uos_names"]
     </querytext>
   </fullquery>

</queryset>
