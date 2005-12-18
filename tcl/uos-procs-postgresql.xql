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

   <fullquery name="curriculum_central::uos::go_live::do_side_effect.get_latest_revision">
     <querytext>
       SELECT latest_revision FROM cr_items WHERE item_id = :object_id
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
