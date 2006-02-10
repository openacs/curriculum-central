<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="context_details">
     <querytext>
       SELECT f.faculty_id, f.faculty_name, d.department_id, d.department_name,
           s.stream_name, n.uos_code, n.uos_name, wr.formal_contact_hrs
       FROM cc_faculty f, cc_department d, cc_stream s,
           cc_uos u, cc_uos_name n, cc_uos_workload w,
	   cc_uos_workload_revisions wr
       WHERE f.faculty_id = d.faculty_id
           AND d.department_id = s.department_id
           AND s.stream_id = :stream_id
           AND s.package_id = :package_id
	   AND u.uos_id = :uos_id
	   AND n.name_id = u.uos_name_id
	   AND w.parent_uos_id = :uos_id
	   AND wr.workload_revision_id = w.live_revision_id
     </querytext>
   </fullquery>

   <fullquery name="uos_details">
     <querytext>
       SELECT ur.credit_value, ur.session_ids,
           s.title || ' ' || person__name(s.staff_id)
               AS unit_coordinator_pretty_name,
           dr.online_course_content, dr.objectives, dr.learning_outcomes,
	   dr.syllabus, dr.relevance
       FROM cc_uos u, cc_uos_revisions ur, cc_staff s, cc_uos_detail d,
           cc_uos_detail_revisions dr
       WHERE u.uos_id = :uos_id
           AND u.live_revision_id = ur.uos_revision_id
	   AND ur.unit_coordinator_id = s.staff_id
	   AND d.parent_uos_id = u.uos_id
	   AND dr.detail_revision_id = d.live_revision_id
     </querytext>
   </fullquery>

   <fullquery name="session_names">
     <querytext>
       SELECT s.name FROM cc_session s
       WHERE s.session_id IN ([join $session_ids ,])
     </querytext>
   </fullquery>

</queryset>
