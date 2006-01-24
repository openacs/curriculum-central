<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="publish">
     <querytext>
       UPDATE cc_stream_uos_map
       SET live_revision_id = (SELECT latest_revision_id
           FROM cc_stream_uos_map
	   WHERE map_id = :map_id AND stream_id = :stream_id)
       WHERE map_id = :map_id
       AND stream_id = :stream_id
     </querytext>
   </fullquery>

</queryset>
