<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="live_tl">
     <querytext>
       SELECT t.tl_id, t.live_revision_id AS tl_live_rev_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_tl t
           WHERE u.uos_id = :uos_id
           AND i.item_id = u.uos_id
           AND r.uos_revision_id = i.live_revision
           AND t.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="get_methods">
     <querytext>
       SELECT m.method_id, n.name, m.description
       FROM cc_uos_tl_method m, acs_objects o, cc_uos_tl_method_map t,
           cc_uos_tl_name n
        WHERE o.package_id = :package_id
	   AND m.method_id = o.object_id
	   AND t.tl_revision_id = :tl_live_rev_id
	   AND m.method_id = t.method_id
	   AND n.name_id = m.name_id
	   ORDER BY n.name
     </querytext>
   </fullquery>

</queryset>
