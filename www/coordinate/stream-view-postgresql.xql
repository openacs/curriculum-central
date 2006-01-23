<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="units_of_study">
     <querytext>
       SELECT map.map_id, uos.uos_code, uos.uos_name, uos.uos_id,
           rev.year_id, y.name, rev.semester_ids
       FROM cc_uos uos, cc_stream_uos_map map, cc_stream_uos_map_rev rev,
           cc_year y
       WHERE uos.uos_id = map.uos_id
       AND map.stream_id = :stream_id
       AND map.latest_revision_id = rev.map_rev_id
       AND rev.year_id = y.year_id
     </querytext>
   </fullquery>

   <fullquery name="stream_name">
     <querytext>
       SELECT cc_stream__name(:stream_id)
     </querytext>
   </fullquery>

   <fullquery name="semester_name">
     <querytext>
       SELECT cc_semester__name(:semester_id)
     </querytext>
   </fullquery>

</queryset>
