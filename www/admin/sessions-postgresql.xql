<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_sessions">
     <querytext>
       SELECT s.session_id, s.name, s.start_date, s.end_date
	   FROM cc_session s
	   WHERE package_id = :package_id
	   [template::list::orderby_clause -orderby -name "sessions"]
     </querytext>
   </fullquery>

</queryset>
