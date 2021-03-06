<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::uos::get.select_latest_uos_data">
     <querytext>
       SELECT *
       FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_name n
       WHERE u.uos_id = :uos_id
       AND i.item_id = u.uos_id
       AND r.uos_revision_id = i.latest_revision
       AND n.name_id = u.uos_name_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_pretty_name.pretty_name">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name
           FROM cc_uos u, cc_uos_name n
	   WHERE u.uos_id = :uos_id
	   AND n.name_id = u.uos_name_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::uos_available_name_get_options.names">
     <querytext>
       SELECT n.uos_code || ' ' || n.uos_name AS name, n.name_id
       FROM cc_uos_name n
       WHERE n.package_id = :package_id
       AND n.name_id NOT IN (
           SELECT uos_name_id FROM cc_uos WHERE package_id = :package_id
       )
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_details.latest_details">
     <querytext>
       SELECT d.detail_id, dr.lecturer_ids, dr.tutor_ids, dr.objectives,
           dr.learning_outcomes, dr.syllabus, dr.relevance,
           dr.online_course_content, dr.note
       FROM cc_uos u, cc_uos_revisions r, cr_items i,
           cc_uos_detail_revisions dr, cc_uos_detail d
       WHERE u.uos_id = :uos_id
       AND i.item_id = u.uos_id
       AND r.uos_revision_id = i.latest_revision
       AND d.parent_uos_id = :uos_id
       AND dr.detail_revision_id = d.latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_tl.latest_tl">
     <querytext>
       SELECT t.tl_id, t.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_tl t
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.latest_revision
	   AND t.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_textbooks.latest_textbook_set">
     <querytext>
       SELECT t.textbook_set_id, t.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_textbook_set t
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.latest_revision
	   AND t.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_graduate_attributes.latest_ga">
     <querytext>
       SELECT g.gradattr_set_id, g.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_gradattr_set g
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.latest_revision
	   AND g.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_workload.latest_workload">
     <querytext>
       SELECT w.workload_id, wr.formal_contact_hrs, wr.informal_study_hrs,
           wr.student_commitment, wr.expected_feedback, wr.student_feedback,
	   wr.assumed_concepts
       FROM cc_uos u, cc_uos_revisions r, cr_items i,
           cc_uos_workload_revisions wr, cc_uos_workload w
       WHERE u.uos_id = :uos_id
       AND i.item_id = u.uos_id
       AND r.uos_revision_id = i.latest_revision
       AND w.parent_uos_id = :uos_id
       AND wr.workload_revision_id = w.latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_assessment.latest_assess">
     <querytext>
       SELECT a.assess_id, a.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_assess a
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.latest_revision
	   AND a.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::add_grade_descriptor_widgets.latest_grade_set">
     <querytext>
       SELECT g.grade_set_id, g.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_grade_set g
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.latest_revision
	   AND g.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::add_schedule_widgets.latest_schedule_set">
     <querytext>
       SELECT s.schedule_set_id, s.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_schedule_set s
	   WHERE u.uos_id = :uos_id
	   AND i.item_id = u.uos_id
	   AND r.uos_revision_id = i.latest_revision
	   AND s.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_assessment.latest_assess_method_ids">
     <querytext>
       SELECT method_id FROM cc_uos_assess_method_map
           WHERE assess_revision_id = :latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_tl.latest_tl_method_ids">
     <querytext>
       SELECT method_id FROM cc_uos_tl_method_map
           WHERE tl_revision_id = :latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_textbooks.latest_textbook_ids">
     <querytext>
       SELECT textbook_id FROM cc_uos_textbook_map
           WHERE revision_id = :latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::add_grade_descriptor_widgets.latest_grade_descriptors">
     <querytext>
       SELECT t.type_id, grade_rev.description
       FROM cc_uos_grade_type t LEFT OUTER JOIN
           (SELECT g.grade_type_id, g.description
	       FROM cc_uos_grade_map map, cc_uos_grade g
	       WHERE map.revision_id = :latest_revision_id
	       AND map.grade_id = g.grade_id) AS grade_rev
       ON (t.type_id = grade_rev.grade_type_id)
       ORDER BY t.upper_bound DESC
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::add_schedule_widgets.latest_schedule">
     <querytext>
       SELECT w.week_id, rev.course_content, rev.assessment_ids
       FROM cc_uos_schedule_week w LEFT OUTER JOIN
           (SELECT s.week_id, s.course_content, s.assessment_ids
	       FROM cc_uos_schedule_map map, cc_uos_schedule s
	       WHERE map.revision_id = :latest_revision_id
	       AND map.schedule_id = s.schedule_id) AS rev
       ON (w.week_id = rev.week_id)
       ORDER BY w.week_id ASC
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_graduate_attributes.latest_gradattr_ids">
     <querytext>
       SELECT gradattr_id FROM cc_uos_gradattr_map
           WHERE revision_id = :latest_revision_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::num_pending.get_users_pending_uos">
     <querytext>
       SELECT count(*)
       FROM cc_uos u,
	    workflow_cases c,
	    workflow_case_fsm f,
	    workflow_fsm_states s
	    WHERE c.case_id = f.case_id
	AND s.state_id = f.current_state
	AND c.workflow_id = :workflow_id
	AND u.uos_id = c.object_id
	AND s.short_name != 'closed'
	AND u.unit_coordinator_id = :user_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::num_pending.get_all_pending_uos">
     <querytext>
       SELECT count(*)
       FROM cc_uos u,
	    workflow_cases c,
	    workflow_case_fsm f,
	    workflow_fsm_states s
	    WHERE c.case_id = f.case_id
	AND s.state_id = f.current_state
	AND c.workflow_id = :workflow_id
	AND u.uos_id = c.object_id
	AND s.short_name != 'closed'
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_stream_coordinator::get_assignees.select_stream_coordinators">
     <querytext>
       SELECT staff_id FROM cc_staff
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_unit_coordinator::get_assignees.select_unit_coordinators">
     <querytext>
       SELECT staff_id FROM cc_staff
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::new.get_stream_coordinator_ids">
     <querytext>
       SELECT DISTINCT coordinator_id FROM cc_stream
       WHERE package_id = :package_id
       AND department_id = :department_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update.update_uos">
     <querytext>
       SELECT cc_uos_revision__new (
           null,
           :uos_id,
	   :uos_name_id,
	   :credit_value,
	   :department_id,
	   :unit_coordinator_id,
	   :session_ids,
	   :prerequisite_ids,
	   :assumed_knowledge_ids,
	   :corequisite_ids,
	   :prohibition_ids,
	   :no_longer_offered_ids,
	   :activity_log,
	   now(),
	   :creation_user,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update.update_unit_coordinator">
     <querytext>
       UPDATE cc_uos SET unit_coordinator_id = :unit_coordinator_id
       WHERE uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_details.update_details">
     <querytext>
       SELECT cc_uos_detail_revision__new (
           null,
	   :detail_id,
	   :lecturer_ids,
	   :tutor_ids,
	   :objectives,
	   :learning_outcomes,
	   :syllabus,
	   :relevance,
	   :online_course_content,
	   :note,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_tl.update_tl">
     <querytext>
       SELECT cc_uos_tl_revision__new (
           null,
	   :tl_id,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_assess.update_assess">
     <querytext>
       SELECT cc_uos_assess_revision__new (
           null,
	   :assess_id,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_textbooks.update_textbook_set">
     <querytext>
       SELECT cc_uos_textbook_set_rev__new (
           null,
	   :textbook_set_id,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_graduate_attributes.update_ga">
     <querytext>
       SELECT cc_uos_gradattr_set_rev__new (
           null,
	   :gradattr_set_id,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_workload.update_workload">
     <querytext>
       SELECT cc_uos_workload_revision__new (
           null,
	   :workload_id,
	   :formal_contact_hrs,
	   :informal_study_hrs,
	   :student_commitment,
	   :expected_feedback,
	   :student_feedback,
	   :assumed_concepts,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_grade_descriptors.update_grade_set">
     <querytext>
       SELECT cc_uos_grade_set_rev__new (
           null,
	   :grade_set_id,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_grade_descriptors.map_grade_descriptor_revision">
     <querytext>
       SELECT cc_uos_grade__map (
           :revision_id,
	   :grade_id
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_tl.map_tl_to_revision">
     <querytext>
       SELECT cc_uos_tl_method__map (
           :revision_id,
	   :tl_approach_id
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_textbooks.map_textbook_revision">
     <querytext>
       SELECT cc_uos_textbook__map (
           :revision_id,
	   :textbook_id
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_assess.map_assess_to_revision">
     <querytext>
       SELECT cc_uos_assess_method__map (
           :revision_id,
	   :assess_method_id
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_graduate_attributes.map_ga_to_revision">
     <querytext>
       SELECT cc_uos_gradattr__map (
           :revision_id,
	   :gradattr_id
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::tl_method_get_options.tl_methods">
     <querytext>
       SELECT m.name || ' (' || m.identifier || ')' AS method_name,
           m.method_id
       FROM cc_uos_tl_method m, acs_objects o
       WHERE o.object_id = m.method_id
       AND o.package_id = :package_id
       AND o.creation_user = :user_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::textbook_get_options.textbooks">
     <querytext>
       SELECT t.title || ' (' || t.author || ')' AS textbook_name,
           t.textbook_id
       FROM cc_uos_textbook t, acs_objects o
       WHERE o.object_id = t.textbook_id
       AND o.package_id = :package_id
       AND o.creation_user = :user_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::graduate_attributes_get_options.select_ga">
     <querytext>
       SELECT cc_uos_gradattr_name__name(g.name_id) AS name,
           g.identifier, g.gradattr_id
       FROM cc_uos_gradattr g, acs_objects o
       WHERE o.object_id = g.gradattr_id
       AND o.package_id = :package_id
       AND o.creation_user = :user_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::assess_method_get_options.assess_methods">
     <querytext>
       SELECT m.name || ' (' || m.identifier || '): ' || m.weighting || '%'
           AS method_name, m.method_id
       FROM cc_uos_assess_method m, acs_objects o
       WHERE o.object_id = m.method_id
       AND o.package_id = :package_id
       AND o.creation_user = :user_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_revision">
     <querytext>
       SELECT latest_revision FROM cr_items WHERE item_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_detail_revision">
     <querytext>
       SELECT i.latest_revision AS latest_detail_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_detail'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_tl_revision">
     <querytext>
       SELECT i.latest_revision AS latest_tl_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_tl'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_assess_revision">
     <querytext>
       SELECT i.latest_revision AS latest_assess_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_assess'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_textbook_revision">
     <querytext>
       SELECT i.latest_revision AS latest_textbook_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_textbook_set'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_grade_revision">
     <querytext>
       SELECT i.latest_revision AS latest_grade_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_grade_set'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_schedule_revision">
     <querytext>
       SELECT i.latest_revision AS latest_schedule_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_schedule_set'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_ga_revision">
     <querytext>
       SELECT i.latest_revision AS latest_ga_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_gradattr_set'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_workload_revision">
     <querytext>
       SELECT i.latest_revision AS latest_workload_revision
           FROM cr_items i, cr_child_rels c
           WHERE c.relation_tag = 'cc_uos_workload'
	   AND c.parent_id = :object_id
	   AND i.item_id = c.child_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_revision">
     <querytext>
       UPDATE cc_uos SET live_revision_id = :latest_revision
           WHERE uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_detail_revision">
     <querytext>
       UPDATE cc_uos_detail SET live_revision_id = :latest_detail_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_tl_revision">
     <querytext>
       UPDATE cc_uos_tl SET live_revision_id = :latest_tl_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_assess_revision">
     <querytext>
       UPDATE cc_uos_assess SET live_revision_id = :latest_assess_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_grade_revision">
     <querytext>
       UPDATE cc_uos_grade_set SET live_revision_id = :latest_grade_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_schedule_revision">
     <querytext>
       UPDATE cc_uos_schedule_set
           SET live_revision_id = :latest_schedule_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_ga_revision">
     <querytext>
       UPDATE cc_uos_gradattr_set SET live_revision_id = :latest_ga_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_textbook_revision">
     <querytext>
       UPDATE cc_uos_textbook_set
           SET live_revision_id = :latest_textbook_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_workload_revision">
     <querytext>
       UPDATE cc_uos_workload SET live_revision_id = :latest_workload_revision
           WHERE parent_uos_id = :object_id
     </querytext>
   </fullquery>

   <partialquery name="curriculum_central::uos::get_unit_coordinator::get_subquery.unit_coordinator_subquery">
     <querytext>
       (select * from cc_users u, cc_staff s where u.user_id = s.staff_id)
     </querytext>
   </partialquery>

   <partialquery name="curriculum_central::uos::get_stream_coordinator::get_subquery.stream_coordinator_subquery">
     <querytext>
       (select * from cc_users u, cc_staff s where u.user_id = s.staff_id)
     </querytext>
   </partialquery>

   <fullquery name="curriculum_central::uos::get_assessment_total.latest_assess_total">
     <querytext>
       SELECT sum(weighting)
       FROM cc_uos_assess a,
	   cc_uos_assess_method_map map,
	   cc_uos_assess_method meth
       WHERE a.assess_id = :assess_id
           AND map.assess_revision_id = a.latest_revision_id
	   AND map.method_id = meth.method_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_grade_descriptor_pretty_name.pretty_name">
     <querytext>
       SELECT name || ' (' || lower_bound || ' to ' || upper_bound || ')'
           AS pretty_name
       FROM cc_uos_grade_type WHERE type_id = :type_id
           AND package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_grade_descriptor_fields.fields">
     <querytext>
       SELECT type_id, :prefix || type_id AS field_id
           FROM cc_uos_grade_type WHERE package_id = :package_id
	   ORDER BY upper_bound DESC
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_schedule.update_schedule_set">
     <querytext>
       SELECT cc_uos_schedule_set_rev__new (
           null,
	   :schedule_set_id,
	   now(),
	   :user_id,
	   :creation_ip
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update_schedule.map_schedule_revision">
     <querytext>
       SELECT cc_uos_schedule__map (
           :revision_id,
	   :schedule_id
       );
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_schedule_pretty_name.pretty_name">
     <querytext>
       SELECT name
       FROM cc_uos_schedule_week WHERE week_id = :week_id
           AND package_id = :package_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_schedule_fields.fields">
     <querytext>
       SELECT week_id, :content_prefix || week_id AS content_field,
           :assessment_prefix || week_id AS assessment_field
       FROM cc_uos_schedule_week WHERE package_id = :package_id
       ORDER BY week_id DESC
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::notification_info::get_notification_info.uos_details">
     <querytext>
       SELECT uosr.credit_value, uosr.session_ids, dept.department_name,
           dr.lecturer_ids, dr.tutor_ids, dr.objectives,
	   dr.learning_outcomes, dr.syllabus, dr.relevance,
	   dr.online_course_content, dr.note
       FROM cc_uos_revisions uosr, cr_items cr, cc_department dept,
       cc_uos_detail d, cc_uos_detail_revisions dr
       WHERE cr.item_id = :object_id
       AND uosr.uos_revision_id = cr.latest_revision
       AND dept.department_id = uosr.department_id
       AND d.parent_uos_id = :object_id
       AND d.latest_revision_id = dr.detail_revision_id
     </querytext>
   </fullquery>

</queryset>
