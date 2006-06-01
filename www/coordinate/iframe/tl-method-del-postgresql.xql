<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="tl_method_delete">
     <querytext>
       SELECT cc_uos_tl__delete(:method_id)
     </querytext>
   </fullquery>

   <fullquery name="tl_method_map_update">
     <querytext>
       UPDATE cc_uos_tl_method_map SET method_id = NULL
       WHERE method_id = :method_id
     </querytext>
   </fullquery>

</queryset>
