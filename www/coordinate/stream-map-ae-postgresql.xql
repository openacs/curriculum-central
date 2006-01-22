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
	SELECT map.uos_id, rev.year_ids, rev.semester_ids,
   	    rev.prerequisite_ids, rev.assumed_knowledge_ids,
	    rev.corequisite_ids, rev.prohibition_ids, rev.no_longer_offered_ids
	FROM cc_stream_uos_map map, cc_stream_uos_map_rev rev
	WHERE map.map_id = :map_id
	AND rev.revision_id = map.latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="new_revision">
     <querytext>
       SELECT cc_stream_uos_map_rev__new (
           NULL,
	   :map_id,
	   :year_ids,
	   :semester_ids,
	   :prerequisite_ids,
	   :assumed_knowledge_ids,
	   :corequisite_ids,
	   :prohibition_ids,
	   :no_longer_offered_ids,
	   now(),
	   :modifying_user,
	   :modifying_ip
       )
     </querytext>
   </fullquery>

   <fullquery name="set_live_revision">
     <querytext>
       UPDATE cc_stream_uos_map SET live_revision_id = :new_revision_id
           WHERE map_id = :map_id
     </querytext>
   </fullquery>

</queryset>
