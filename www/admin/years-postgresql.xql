<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_years">
     <querytext>
       SELECT year_id, name
	   FROM cc_year
	   WHERE package_id = :package_id
	   [template::list::orderby_clause -orderby -name "years"]
     </querytext>
   </fullquery>

</queryset>
