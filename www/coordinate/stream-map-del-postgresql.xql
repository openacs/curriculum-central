<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="delete_map">
     <querytext>
       select cc_stream_uos_map__delete(:map_id)
     </querytext>
   </fullquery>

</queryset>
