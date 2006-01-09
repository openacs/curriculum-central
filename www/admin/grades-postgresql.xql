<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_grades">
     <querytext>
       SELECT g.type_id, g.name, g.lower_bound, g.upper_bound
	   FROM cc_uos_grade_type g
	   WHERE g.package_id = :package_id
	   [template::list::orderby_clause -orderby -name "grades"]
     </querytext>
   </fullquery>

</queryset>
