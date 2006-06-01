<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="latest_ga">
     <querytext>
       SELECT s.gradattr_set_id, s.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_gradattr_set s
           WHERE u.uos_id = :uos_id
           AND i.item_id = u.uos_id
           AND r.uos_revision_id = i.latest_revision
           AND s.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="get_gradattrs">
     <querytext>
       SELECT g.gradattr_id, n.name, g.description, g.level
       FROM cc_uos_gradattr g, acs_objects o, cc_uos_gradattr_map m,
           cc_uos_gradattr_name n
        WHERE o.package_id = :package_id
	   AND g.gradattr_id = o.object_id
	   AND m.revision_id = :latest_revision_id
	   AND g.gradattr_id = m.gradattr_id
	   AND n.name_id = g.name_id
	   [template::list::orderby_clause -orderby -name "gradattrs"]
     </querytext>
   </fullquery>

</queryset>
