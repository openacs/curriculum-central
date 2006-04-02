<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::stream::streams_exist_p.streams_exist">
     <querytext>
       SELECT * FROM cc_stream WHERE package_id = :package_id LIMIT 1
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::years_get_options.years">
     <querytext>
       SELECT name, year_id FROM cc_year WHERE package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::semesters_get_options.semesters">
     <querytext>
       SELECT name, semester_id FROM cc_semester WHERE package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::years_for_uos_get_options.year_ids">
     <querytext>
       SELECT year_ids FROM cc_stream WHERE stream_id = :stream_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::years_for_uos_get_options.year_name">
     <querytext>
       SELECT name FROM cc_year WHERE year_id = :year_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::sessions_get_options.session_ids">
     <querytext>
       SELECT session_id FROM cc_session WHERE package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::sessions_get_options.session_name">
     <querytext>
       SELECT name from cc_session WHERE session_id = :session_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::all_uos_except_get_options.all_uos">
     <querytext>
       SELECT uos_code || ' ' || uos_name as name, uos_id
           FROM cc_uos
	   WHERE package_id = :package_id
	   AND uos_id != :except_uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::all_uos_get_options.all_uos">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS name, uos.uos_id
           FROM cc_uos uos, cc_uos_name n
	   WHERE uos.package_id = :package_id
	   AND uos.uos_name_id = n.name_id
	   ORDER BY n.uos_code ASC
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::all_uos_names_get_options.all_uos_names">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS name, n.name_id
           FROM cc_uos_name n
	   WHERE n.package_id = :package_id
	   ORDER BY n.uos_code ASC
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::stream_uos_relation_get_options.stream_uos_rels">
     <querytext>
       SELECT r.name, r.stream_uos_rel_id
           FROM cc_stream_uos_rel r
	   WHERE r.package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::stream_uos_relation_name.get_name">
     <querytext>
       SELECT r.name
           FROM cc_stream_uos_rel r
	   WHERE r.package_id = :package_id
	   AND r.stream_uos_rel_id = :id
     </querytext>
   </fullquery>

</queryset>
