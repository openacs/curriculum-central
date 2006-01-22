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

   <fullquery name="curriculum_central::stream::semesters_in_a_year_get_options.semester_ids">
     <querytext>
       SELECT semester_ids FROM cc_stream WHERE stream_id = :stream_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::stream::semesters_in_a_year_get_options.semester_name">
     <querytext>
       SELECT name from cc_semester WHERE semester_id = :semester_id
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

   <fullquery name="curriculum_central::stream::non_mapped_uos.non_mapped_uos">
     <querytext>
       SELECT uos.uos_code || ' ' ||uos.uos_name AS name, uos.uos_id
           FROM cc_uos uos
	   WHERE uos.package_id = :package_id
	   AND uos.uos_id NOT IN (SELECT uos_id FROM cc_stream_uos_map WHERE stream_id = :stream_id)
     </querytext>
   </fullquery>

</queryset>
