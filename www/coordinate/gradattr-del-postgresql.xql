<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="gradattr_delete">
     <querytext>
       SELECT cc_uos_gradattr__del(:gradattr_id)
     </querytext>
   </fullquery>

   <fullquery name="gradattr_map_update">
     <querytext>
       UPDATE cc_uos_gradattr_map SET gradattr_id = NULL
       WHERE gradattr_id = :gradattr_id
     </querytext>
   </fullquery>

</queryset>
