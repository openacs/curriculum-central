<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_semesters">
     <querytext>
       SELECT s.semester_id, s.name, s.start_date, s.end_date
	   FROM cc_semester s
	   WHERE package_id = :package_id
	   [template::list::orderby_clause -orderby -name "semesters"]
     </querytext>
   </fullquery>

</queryset>
