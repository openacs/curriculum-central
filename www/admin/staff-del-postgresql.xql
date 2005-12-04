<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="staff_delete">
     <querytext>
       SELECT cc_staff__delete(:staff_id)
     </querytext>
   </fullquery>

</queryset>
