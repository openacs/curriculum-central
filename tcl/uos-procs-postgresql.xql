<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="curriculum_central::uos::get.select_latest_uos_data">
     <querytext>
       SELECT *
       FROM cc_uos u, cc_uos_revisions r, cr_items i
       WHERE u.uos_id = :uos_id
       AND i.item_id = u.uos_id
       AND r.uos_revision_id = i.latest_revision
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::get_details.latest_details">
     <querytext>
       SELECT d.detail_id, dr.lecturer_id, dr.objectives,
           dr.learning_outcomes, dr.syllabus, dr.relevance,
           dr.online_course_content
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

   <fullquery name="curriculum_central::uos::get_tl.latest_tl_method_ids">
     <querytext>
       SELECT method_id FROM cc_uos_tl_method_map
           WHERE tl_revision_id = :latest_revision_id
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
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::update.update_uos">
     <querytext>
       SELECT cc_uos_revision__new (
           null,
           :uos_id,
	   :uos_code,
	   :uos_name,
	   :credit_value,
	   :semester,
	   :unit_coordinator_id,
	   :activity_log,
	   :activity_log_format,
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
	   :lecturer_id,
	   :objectives,
	   :learning_outcomes,
	   :syllabus,
	   :relevance,
	   :online_course_content,
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

   <fullquery name="curriculum_central::uos::update_tl.map_tl_to_revision">
     <querytext>
       SELECT cc_uos_tl_method__map (
           :revision_id,
	   :tl_approach_id
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
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::graduate_attributes_get_options.select_ga">
     <querytext>
       SELECT g.name || ' (' || g.identifier || ')' AS ga_name,
           g.gradattr_id
       FROM cc_uos_gradattr g, acs_objects o
       WHERE o.object_id = g.gradattr_id
       AND o.package_id = :package_id
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

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_ga_revision">
     <querytext>
       UPDATE cc_uos_gradattr_set SET live_revision_id = :latest_ga_revision
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

</queryset>
