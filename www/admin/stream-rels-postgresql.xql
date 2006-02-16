<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_rels">
     <querytext>
       SELECT stream_uos_rel_id, name
	   FROM cc_stream_uos_rel
	   WHERE package_id = :package_id
	   [template::list::orderby_clause -orderby -name "stream_rels"]
     </querytext>
   </fullquery>

</queryset>
