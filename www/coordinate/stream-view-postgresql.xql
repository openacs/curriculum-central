<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="units_of_study">
     <querytext>
       SELECT map.map_id, n.uos_code, n.uos_name, uos.uos_id,
           rev.year_id, y.name, uosr.session_ids, rev.core_id,
	   map.live_revision_id, map.latest_revision_id
       FROM cc_uos uos, cc_stream_uos_map map, cc_stream_uos_map_rev rev,
           cc_year y, cc_uos_name n, cc_uos_revisions uosr, cr_items i
       WHERE uos.uos_id = map.uos_id
       AND map.stream_id = :stream_id
       AND map.latest_revision_id = rev.map_rev_id
       AND rev.year_id = y.year_id
       AND rev.year_id != 0
       AND n.name_id = uos.uos_name_id
       AND uosr.uos_revision_id = i.latest_revision
       AND i.item_id = uos.uos_id
     </querytext>
   </fullquery>

   <fullquery name="stream_name">
     <querytext>
       SELECT cc_stream__name(:stream_id)
     </querytext>
   </fullquery>

   <fullquery name="session_name">
     <querytext>
       SELECT cc_session__name(:session_id)
     </querytext>
   </fullquery>

   <fullquery name="not_offered">
     <querytext>
       SELECT map.map_id, n.uos_code, n.uos_name, uos.uos_id,
           rev.year_id, map.live_revision_id, map.latest_revision_id
       FROM cc_uos uos, cc_stream_uos_map map, cc_stream_uos_map_rev rev,
       cc_uos_name n
       WHERE uos.uos_id = map.uos_id
       AND map.stream_id = :stream_id
       AND map.latest_revision_id = rev.map_rev_id
       AND rev.year_id = 0
       AND n.name_id = uos.uos_name_id
     </querytext>
   </fullquery>

</queryset>
