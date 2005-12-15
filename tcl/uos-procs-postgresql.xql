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
</queryset>
