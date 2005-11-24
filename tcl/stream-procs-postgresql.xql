<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::stream::streams_exist_p.streams_exist">
     <querytext>
       SELECT * FROM cc_stream WHERE package_id = :package_id LIMIT 1
     </querytext>
   </fullquery>
</queryset>
