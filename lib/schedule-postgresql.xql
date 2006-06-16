<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="live_schedule">
     <querytext>
       SELECT s.schedule_set_id, s.live_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_schedule_set s
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.live_revision
	   AND s.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="get_schedule">
     <querytext>
       SELECT w.week_id, rev.course_content, rev.assessment_ids
       FROM cc_uos_schedule_week w LEFT OUTER JOIN
           (SELECT s.week_id, s.course_content, s.assessment_ids
	       FROM cc_uos_schedule_map map, cc_uos_schedule s
	       WHERE map.revision_id = :live_revision_id
	       AND map.schedule_id = s.schedule_id) AS rev
       ON (w.week_id = rev.week_id)
       ORDER BY w.week_id ASC
     </querytext>
   </fullquery>

   <fullquery name="assess_name">
     <querytext>
       SELECT name FROM cc_uos_assess_method WHERE method_id = :assess_id
     </querytext>
   </fullquery>

</queryset>
