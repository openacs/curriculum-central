<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="am_delete">
     <querytext>
       SELECT cc_uos_assess_method__del(:method_id)
     </querytext>
   </fullquery>

   <fullquery name="am_map_update">
     <querytext>
       UPDATE cc_uos_assess_method_map SET method_id = NULL
       WHERE method_id = :method_id
     </querytext>
   </fullquery>

</queryset>
