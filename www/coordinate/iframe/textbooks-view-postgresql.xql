<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="latest_textbooks">
     <querytext>
       SELECT s.textbook_set_id, s.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_textbook_set s
           WHERE u.uos_id = :uos_id
           AND i.item_id = u.uos_id
           AND r.uos_revision_id = i.latest_revision
           AND s.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="get_textbooks">
     <querytext>
       SELECT t.textbook_id, t.title, t.author, t.publisher, t.isbn
       FROM cc_uos_textbook t, acs_objects o, cc_uos_textbook_map m
       WHERE o.package_id = :package_id
	   AND t.textbook_id = o.object_id
	   AND m.revision_id = :latest_revision_id
	   AND t.textbook_id = m.textbook_id
	   [template::list::orderby_clause -orderby -name "textbooks"]
     </querytext>
   </fullquery>

</queryset>
