<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="context_details">
     <querytext>
       SELECT f.faculty_id, f.faculty_name, d.department_name,
           s.stream_name, n.uos_code, n.uos_name
       FROM cc_faculty f, cc_department d, cc_stream s,
           cc_uos u, cc_uos_name n
       WHERE f.faculty_id = d.faculty_id
           AND d.department_id = s.department_id
           AND s.stream_id = :stream_id
           AND s.package_id = :package_id
	   AND u.uos_id = :uos_id
	   AND n.name_id = u.uos_name_id
     </querytext>
   </fullquery>

   <fullquery name="context_details_no_stream">
     <querytext>
       SELECT f.faculty_id, f.faculty_name, d.department_name,
           n.uos_code, n.uos_name
       FROM cc_faculty f, cc_department d,
           cc_uos u, cc_uos_name n
       WHERE f.faculty_id = d.faculty_id
           AND d.department_id = :department_id
           AND d.package_id = :package_id
	   AND u.uos_id = :uos_id
	   AND n.name_id = u.uos_name_id
     </querytext>
   </fullquery>

   <fullquery name="uos_details">
     <querytext>
       SELECT ur.credit_value, ur.session_ids, ur.prerequisite_ids,
           ur.assumed_knowledge_ids, ur.corequisite_ids, ur.prohibition_ids,
	   ur.no_longer_offered_ids,
           s.title || ' ' || person__name(s.staff_id)
               AS unit_coordinator_pretty_name,
           dr.online_course_content, dr.objectives, dr.learning_outcomes,
	   dr.syllabus, dr.relevance, dr.note, dr.lecturer_ids, dr.tutor_ids,
	   wr.formal_contact_hrs, wr.student_commitment, wr.expected_feedback,
	   wr.student_feedback, wr.assumed_concepts, wr.informal_study_hrs
       FROM cc_uos u, cc_uos_revisions ur, cc_staff s, cc_uos_detail d,
           cc_uos_detail_revisions dr, cc_uos_workload w,
	   cc_uos_workload_revisions wr
       WHERE u.uos_id = :uos_id
           AND u.live_revision_id = ur.uos_revision_id
	   AND ur.unit_coordinator_id = s.staff_id
	   AND d.parent_uos_id = u.uos_id
	   AND dr.detail_revision_id = d.live_revision_id
	   AND w.parent_uos_id = :uos_id
	   AND wr.workload_revision_id = w.live_revision_id
     </querytext>
   </fullquery>

   <fullquery name="session_names">
     <querytext>
       SELECT s.name FROM cc_session s
       WHERE s.session_id IN ([join $session_ids ,])
     </querytext>
   </fullquery>

   <fullquery name="assessment_names">
     <querytext>
       SELECT m.name || ' (' || m.weighting || '%)' AS assessment_name
       FROM cc_uos_assess_method m, cc_uos_assess a,
       cc_uos_assess_method_map map
       WHERE a.parent_uos_id = :uos_id
       AND a.live_revision_id = map.assess_revision_id
       AND map.method_id = m.method_id
     </querytext>
   </fullquery>

   <fullquery name="prerequisites">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS prerequisite
       FROM cc_uos_name n
       WHERE n.name_id IN ([join $prerequisite_ids ,])
     </querytext>
   </fullquery>

   <fullquery name="assumed_knowledge">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS assumed_knowledge
       FROM cc_uos_name n
       WHERE n.name_id IN ([join $assumed_knowledge_ids ,])
     </querytext>
   </fullquery>

   <fullquery name="corequisites">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS corequisite
       FROM cc_uos_name n
       WHERE n.name_id IN ([join $corequisite_ids ,])
     </querytext>
   </fullquery>

   <fullquery name="prohibitions">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS prohibition
       FROM cc_uos_name n
       WHERE n.name_id IN ([join $prohibition_ids ,])
     </querytext>
   </fullquery>

   <fullquery name="no_longer_offered">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS no_longer_offered
       FROM cc_uos_name n
       WHERE n.name_id IN ([join $no_longer_offered_ids ,])
     </querytext>
   </fullquery>
</queryset>
