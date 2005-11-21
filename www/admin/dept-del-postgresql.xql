<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="dept_delete">
     <querytext>
       SELECT cc_department__delete(:department_id)
     </querytext>
   </fullquery>

</queryset>
