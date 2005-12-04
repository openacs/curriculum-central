<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="staff_update">
     <querytext>
       UPDATE cc_staff
           SET title = :title,
	   position = :position,
	   department_id = :department_id
	   WHERE staff_id = :staff_id
     </querytext>
   </fullquery>

</queryset>
