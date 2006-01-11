<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_schedule">
     <querytext>
       SELECT s.week_id, s.name
	   FROM cc_uos_schedule_week s
	   WHERE s.package_id = :package_id
	   [template::list::orderby_clause -orderby -name "schedule"]
     </querytext>
   </fullquery>

</queryset>
