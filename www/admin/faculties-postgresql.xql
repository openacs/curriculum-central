<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_faculties">
     <querytext>
       SELECT faculty_id, faculty_name,
           (SELECT first_names || ' ' || last_name
	       FROM cc_users
	       WHERE user_id = dean_id) AS dean
	   FROM cc_faculty
	   [template::list::orderby_clause -orderby -name "faculties"]
     </querytext>
   </fullquery>

</queryset>
