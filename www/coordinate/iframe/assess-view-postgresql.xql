<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="latest_am">
     <querytext>
       SELECT s.assess_id, s.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_assess s
           WHERE u.uos_id = :uos_id
           AND i.item_id = u.uos_id
           AND r.uos_revision_id = i.latest_revision
           AND s.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="get_methods">
     <querytext>
       SELECT a.method_id, a.name, a.description, a.weighting
       FROM cc_uos_assess_method a, acs_objects o, cc_uos_assess_method_map m
        WHERE o.package_id = :package_id
	   AND a.method_id = o.object_id
	   AND m.assess_revision_id = :latest_revision_id
	   AND a.method_id = m.method_id
	   [template::list::orderby_clause -orderby -name "methods"]
     </querytext>
   </fullquery>

</queryset>
