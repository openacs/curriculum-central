<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="live_grades">
     <querytext>
       SELECT g.grade_set_id, g.live_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_grade_set g
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.live_revision
	   AND g.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="get_grades">
     <querytext>
       SELECT t.type_id, grade_rev.description
       FROM cc_uos_grade_type t LEFT OUTER JOIN
           (SELECT g.grade_type_id, g.description
	       FROM cc_uos_grade_map map, cc_uos_grade g
	       WHERE map.revision_id = :live_revision_id
	       AND map.grade_id = g.grade_id) AS grade_rev
       ON (t.type_id = grade_rev.grade_type_id)
       ORDER BY t.upper_bound DESC
     </querytext>
   </fullquery>

</queryset>
