<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="faculty_info">
     <querytext>
       SELECT f.faculty_id, f.faculty_name, d.department_id, d.department_name,
           s.stream_name
       FROM cc_faculty f, cc_department d, cc_stream s
       WHERE f.faculty_id = d.faculty_id
           AND d.department_id = s.department_id
	   AND s.stream_id = :stream_id
	   AND s.package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="units_of_study">
     <querytext>
       SELECT map.map_id, n.uos_code, n.uos_name, uos.uos_id,
           rev.year_id, y.name, rev.core_id,
	   map.live_revision_id, uosr.session_ids, uos.uos_name_id,
	   rel.name AS rel_name, dr.learning_outcomes, dr.objectives,
	   dr.syllabus, dr.lecturer_ids
       FROM cc_uos uos, cc_uos_revisions uosr, cc_stream_uos_map map,
           cc_stream_uos_map_rev rev, cc_year y, cc_uos_name n,
	   cc_stream_uos_rel rel, cc_uos_detail_revisions dr, cc_uos_detail d
       WHERE uos.uos_id = map.uos_id
       AND map.stream_id = :stream_id
       AND map.live_revision_id = rev.map_rev_id
       AND rev.year_id = y.year_id
       AND rev.year_id != 0
       AND uos.live_revision_id = uosr.uos_revision_id
       AND n.name_id = uos.uos_name_id
       AND rev.core_id = rel.stream_uos_rel_id
       AND dr.detail_revision_id = d.live_revision_id
       AND d.parent_uos_id = uos.uos_id
     </querytext>
   </fullquery>

   <fullquery name="session_name">
     <querytext>
       SELECT cc_session__name(:session_id)
     </querytext>
   </fullquery>

   <fullquery name="graduate_attributes">
     <querytext>
       SELECT DISTINCT gan.name, ga.level, ga.description
       FROM cc_uos_gradattr_set gas, cc_uos_gradattr_map gam,
           cc_uos_gradattr_name gan, cc_uos_gradattr ga
       WHERE gas.parent_uos_id = :uos_id
       AND gas.live_revision_id = gam.revision_id
       AND gam.gradattr_id = ga.gradattr_id
       AND ga.name_id = gan.name_id
     </querytext>
   </fullquery>

</queryset>
