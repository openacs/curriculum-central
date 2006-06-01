<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="latest_tl">
     <querytext>
       SELECT t.tl_id, t.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_tl t
           WHERE u.uos_id = :uos_id
           AND i.item_id = u.uos_id
           AND r.uos_revision_id = i.latest_revision
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
	   AND o.creation_user = :user_id
	   AND t.tl_revision_id = :latest_revision_id
	   AND m.method_id = t.method_id
	   AND n.name_id = m.name_id
	   [template::list::orderby_clause -orderby -name "methods"]
     </querytext>
   </fullquery>

</queryset>
