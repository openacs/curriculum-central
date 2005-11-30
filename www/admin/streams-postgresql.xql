<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="get_streams">
     <querytext>
       SELECT s.stream_id, s.stream_name, s.stream_code,
           (SELECT d.department_name FROM cc_department d
               WHERE d.department_id = s.department_id) as department,
           (SELECT first_names || ' ' || last_name
	       FROM cc_users
	       WHERE user_id = s.coordinator_id) AS stream_coordinator
	   FROM cc_stream s
	   WHERE package_id = :package_id
	   [template::list::orderby_clause -orderby -name "streams"]
     </querytext>
   </fullquery>

</queryset>
