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
	   :online_course_content,
	   :unit_coordinator_id,
	   :contact_hours,
	   :assessments,
	   :core_uos_for,
	   :recommended_uos_for,
	   :prerequisites,
	   :objectives,
	   :outcomes,
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

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_revision">
     <querytext>
       SELECT latest_revision FROM cr_items WHERE item_id = :object_id
     </querytext>
   </fullquery>

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.set_live_revision">
     <querytext>
       UPDATE cc_uos SET live_revision_id = :latest_revision
           WHERE uos_id = :object_id
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
