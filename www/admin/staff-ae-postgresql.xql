<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="staff_update">
     <querytext>
       UPDATE cc_staff
           SET title = :title,
	   position = :position,
	   department_id = :department_id,
	   address_line_1 = :address_line_1,
	   address_line_2 = :address_line_2,
	   address_suburb = :address_suburb,
	   address_state = :address_state,
	   address_postcode = :address_postcode,
	   address_country = :address_country,
	   phone = :phone,
	   fax = :fax,
	   homepage_url = :homepage_url
	   WHERE staff_id = :staff_id
     </querytext>
   </fullquery>

</queryset>
