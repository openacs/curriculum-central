<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::uos::get_unit_coordinator::get_assignees.select_unit_coordinators">
     <querytext>
       SELECT staff_id FROM cc_staff
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_stream_coordinator::get_assignees.select_stream_coordinators">
     <querytext>
       SELECT staff_id FROM cc_staff
     </querytext>
   </fullquery>

</queryset>
