<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="textbook_delete">
     <querytext>
       SELECT cc_uos_textbook__del(:textbook_id)
     </querytext>
   </fullquery>

   <fullquery name="textbook_map_update">
     <querytext>
       UPDATE cc_uos_textbook_map SET textbook_id = NULL
       WHERE textbook_id = :textbook_id
     </querytext>
   </fullquery>

</queryset>
