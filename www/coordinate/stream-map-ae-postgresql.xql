<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="stream_name">
     <querytext>
       SELECT cc_stream__name(:stream_id)
     </querytext>
   </fullquery>

   <fullquery name="form_info">
     <querytext>
	SELECT map.uos_id, rev.year_id, rev.core_id, rev.note
	FROM cc_stream_uos_map map, cc_stream_uos_map_rev rev
	WHERE map.map_id = :map_id
	AND rev.map_rev_id = map.latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="new_revision">
     <querytext>
       SELECT cc_stream_uos_map_rev__new (
           NULL,
	   :map_id,
	   :year_id,
	   :core_id,
	   :note,
	   now(),
	   :modifying_user,
	   :modifying_ip
       )
     </querytext>
   </fullquery>

</queryset>
