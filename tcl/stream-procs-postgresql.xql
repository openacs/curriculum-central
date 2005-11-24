<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::stream::streams_exist_p.streams_exist">
     <querytext>
       SELECT * FROM cc_stream LIMIT 1
     </querytext>
   </fullquery>
</queryset>
