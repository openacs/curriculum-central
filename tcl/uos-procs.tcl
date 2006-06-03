ad_library {

    Curriculum Central UoS Library
    
    Procedures that deal with a single Unit of Study (UoS).

    @creation-date 2005-11-08
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$

}

namespace eval curriculum_central::uos {}
namespace eval curriculum_central::uos::format_log_title {}
namespace eval curriculum_central::uos::get_unit_coordinator {}
namespace eval curriculum_central::uos::get_stream_coordinator {}
namespace eval curriculum_central::uos::notification_info {}
namespace eval curriculum_central::uos::go_live {}


ad_proc -public curriculum_central::uos::workflow_short_name {} {
    Get the short name of the workflow for Units of Study.
} {
    return "uos"
}


ad_proc -public curriculum_central::uos::object_type {} {
    Get the short name of the workflow for Units of Study.
} {
    return "cc_uos"
}


ad_proc -private curriculum_central::uos::workflow_create {} {
    Create the 'uos' workflow for curriculum-central
} {
    set spec {
        uos {
            pretty_name "#curriculum-central.uos#"
            package_key "curriculum-central"
            object_type "cc_uos"
            callbacks { 
                curriculum-central.FormatLogTitle
                curriculum-central.UoSNotificationInfo
            }
            roles {
                stream_coordinator {
                    pretty_name "#curriculum-central.stream_coordinator#"
		    callbacks { 
                        workflow.Role_DefaultAssignees_CreationUser
			curriculum-central.StreamCoordinator_Default_Assignees
			curriculum-central.StreamCoordinator_Assignee_PickList
			curriculum-central.StreamCoordinator_Assignee_SubQuery
                    }
                }
                unit_coordinator {
                    pretty_name "#curriculum-central.unit_coordinator#"
                    callbacks {
			curriculum-central.UnitCoordinator_Default_Assignees
			curriculum-central.UnitCoordinator_Assignee_PickList
			curriculum-central.UnitCoordinator_Assignee_SubQuery
                    }
                }
		lecturer {
		    pretty_name "#curriculum-central.lecturer#"
		}
            }
            states {
                open {
                    pretty_name "#curriculum-central.open#"
                }
                submitted {
                    pretty_name "#curriculum-central.submitted#"
                }
                closed {
                    pretty_name "#curriculum-central.closed#"
                }
            }
            actions {
                open {
                    pretty_name "#curriculum-central.open#"
                    pretty_past_tense "#curriculum-central.opened#"
		    allowed_roles { stream_coordinator }
                    new_state open
		    edit_fields {
			activity_log
		    }
                    initial_action_p t
                }
                comment {
                    pretty_name "#curriculum-central.comment#"
                    pretty_past_tense "#curriculum-central.commented#"
                    allowed_roles {
			stream_coordinator
			unit_coordinator
			lecturer
		    }
		    edit_fields {
			activity_log
		    }
                    privileges { read write }
                    always_enabled_p t
                }
                edit_details {
                    pretty_name "#curriculum-central.edit_details#"
                    pretty_past_tense "#curriculum-central.edited_details#"
                    allowed_roles {
			stream_coordinator
		    }
                    privileges { write }
		    assigned_states { open }
                    edit_fields { 
			uos_name
			role_unit_coordinator
			credit_value
			department_id
			session_ids
			prerequisite_ids
			assumed_knowledge_ids
			corequisite_ids
			prohibition_ids
			no_longer_offered_ids
                    }
                }
                edit_tl {
                    pretty_name "#curriculum-central.edit_tl#"
                    pretty_past_tense "#curriculum-central.edited_tl#"
                    allowed_roles {
			stream_coordinator
			unit_coordinator
			lecturer
		    }
                    privileges { write }
		    edit_fields {
			lecturer_ids
			tutor_ids
			objectives
			learning_outcomes
			syllabus
			relevance
			online_course_content
			note
			tl_approach_ids
			gradattr_ids
			textbook_ids
			formal_contact_hrs
			informal_study_hrs
			student_commitment
			expected_feedback
			student_feedback
			assumed_concepts
		    }
		    assigned_states { open }
                }
		edit_assessment {
		    pretty_name "#curriculum-central.edit_assessment#"
		    pretty_past_tense "#curriculum-central.edited_assessment#"
		    allowed_roles {
			stream_coordinator
			unit_coordinator
			lecturer
		    }
		    privileges { write }
		    edit_fields {
			assess_method_ids
		    }
		    assigned_states { open }
		}
		edit_schedule {
		    pretty_name "#curriculum-central.edit_schedule#"
		    pretty_past_tense "#curriculum-central.edited_schedule#"
		    allowed_roles {
			stream_coordinator
			unit_coordinator
			lecturer
		    }
		    privileges { write }
		    assigned_states { open }
		}
                submit {
                    pretty_name "#curriculum-central.submit#"
                    pretty_past_tense "#curriculum-central.submitted#"
                    assigned_role { unit_coordinator }
                    assigned_states { open }
                    new_state { submitted }
		    edit_fields {
			activity_log
		    }
                    privileges { write }
                }
                close {
                    pretty_name "#curriculum-central.close#"
                    pretty_past_tense "#curriculum-central.closed#"
                    assigned_role { stream_coordinator }
                    assigned_states { submitted }
                    new_state closed
                    privileges { write }
		    edit_fields {
			activity_log
		    }
		    callbacks {
			curriculum-central.UoSGoLive
		    }
                }
                reopen {
                    pretty_name "#curriculum-central.reopen#"
                    pretty_past_tense "#curriculum-central.reopened#"
                    allowed_roles { stream_coordinator unit_coordinator }
                    enabled_states { submitted closed }
                    new_state { open }
		    edit_fields {
			activity_log
		    }
                    privileges { write }
                }
            }
        }
    }

    set workflow_id [workflow::fsm::new_from_spec -spec $spec]

    return $workflow_id
}


ad_proc -private curriculum_central::uos::workflow_delete {} {
    Delete the 'uos' workflow for curriculum-central
} {
    set workflow_id [get_package_workflow_id]
    if { ![empty_string_p $workflow_id] } {
        workflow::delete -workflow_id $workflow_id
    }
}


ad_proc -public curriculum_central::uos::get_package_workflow_id {} { 
    Return the workflow_id for the package (not instance) workflow
} {
    return [workflow::get_id \
            -short_name [workflow_short_name] \
            -package_key [curriculum_central::package_key]]
}


ad_proc -public curriculum_central::uos::get_instance_workflow_id {
    {-package_id {}}
} { 
    Return the workflow_id for the package (not instance) workflow
} {
    if { [empty_string_p $package_id] } {
        set package_id [ad_conn package_id]
    }

    return [workflow::get_id \
            -short_name [workflow_short_name] \
            -object_id $package_id]
}

ad_proc -private curriculum_central::uos::instance_workflow_create {
    {-package_id:required}
} {
    Creates a clone of the default curriculum-central package workflow for a
    specific package instance 
} {
    set workflow_id [workflow::fsm::clone \
            -workflow_id [get_package_workflow_id] \
            -object_id $package_id]
    
    return $workflow_id
}

ad_proc -private curriculum_central::uos::instance_workflow_delete {
    {-package_id:required}
} {
    Deletes the instance workflow
} {
    workflow::delete -workflow_id [get_instance_workflow_id -package_id $package_id]
}


#####
#
# Workflow procs.
#
#####

ad_proc -public curriculum_central::uos::get {
    {-uos_id:required}
    {-array:required}
    {-enabled_action_id {}}
} {
    Get the fields for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    fields for.
    @param array A predefined array for returning fields in.
    @param enabled_action_id ID ofthe enabled workflow action.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    db_1row select_latest_uos_data {} -column_array row

    # Get the case ID, so we can get state information
    set case_id [workflow::case::get_id \
        -object_id $uos_id \
	-workflow_short_name [curriculum_central::uos::workflow_short_name]]

    # Get state information
    workflow::case::fsm::get -case_id $case_id -array case \
	-enabled_action_id $enabled_action_id

    set row(pretty_state) $case(pretty_state)
    set row(state_short_name) $case(state_short_name)
    set row(hide_fields) $case(state_hide_fields)
    set row(entry_id) $case(entry_id)
}


ad_proc -public curriculum_central::uos::new {
    -uos_id:required
    -package_id:required
    -uos_name_id:required
    -credit_value:required
    -department_id:required
    -unit_coordinator_id:required
    -session_ids:required
    -prerequisite_ids:required
    -assumed_knowledge_ids:required
    -corequisite_ids:required
    -prohibition_ids:required
    -no_longer_offered_ids:required
    -activity_log:required
    {-user_id ""}
} {
    Create a new Unit of Study, then send out notifications, starts
    workflow, etc.

    This proc creates a new Unit of Study revision.  The live revision is
    set at the end of the workflow, when the stream coordinator approves
    the Unit of Study.

    Calls curriculum_central::uos::insert.

    @see curriculum_central::uos::insert.
    @return uos_id The same uos_id passed in, for convenience.
} {
    db_transaction {
	if { $user_id eq ""} {
	    set user_id [ad_conn user_id]
	}

	set uos_id [curriculum_central::uos::insert \
			-uos_id $uos_id \
			-package_id $package_id \
			-user_id $user_id \
			-uos_name_id $uos_name_id \
			-credit_value $credit_value \
			-department_id $department_id \
			-unit_coordinator_id $unit_coordinator_id \
			-session_ids $session_ids \
			-prerequisite_ids $prerequisite_ids \
			-assumed_knowledge_ids $assumed_knowledge_ids \
			-corequisite_ids $corequisite_ids \
			-prohibition_ids $prohibition_ids \
			-no_longer_offered_ids $no_longer_offered_ids \
			-activity_log $activity_log ]

	# Get a list of stream coordinator IDs.
	# All stream coordinators for the given department_id
	# are assigned to the workflow case.
	set stream_coordinator_ids [db_list get_stream_coordinator_ids {}]
	set notify_user_ids [list]
	lappend notify_user_ids $stream_coordinator_ids

	# Add the unit coordinator for notifications, if they
	# are not a stream coordinator for the given department.
	if { [lsearch -exact $notify_user_ids $unit_coordinator_id] == -1 } {
	    lappend notify_user_ids $unit_coordinator_id
	}

	# Initiate notifications
	set type_id [notification::type::get_type_id \
			 -short_name "workflow_case"]

	set request_id [notification::request::get_request_id \
			    -type_id $type_id \
			    -object_id $uos_id \
			    -user_id $user_id]

	set delivery_method_id \
	    [notification::get_delivery_method_id -name "email"]

	set interval_id \
	    [notification::interval::get_id_from_name -name "instant"]

	foreach notify_user_id $notify_user_ids {
	    notification::request::new \
		-request_id $request_id \
		-type_id $type_id \
		-user_id $notify_user_id \
		-object_id $uos_id \
		-interval_id $interval_id \
		-delivery_method_id $delivery_method_id
	}

	# Initiate the workflow case.
	set workflow_id [workflow::get_id \
			     -object_id $package_id \
			     -short_name [workflow_short_name]]

	array set assign_array [list unit_coordinator $unit_coordinator_id]

	# Create a new workflow case for the given UoS.
	set case_id [workflow::case::new \
			 -workflow_id $workflow_id \
			 -object_id $uos_id \
			 -comment $activity_log \
			 -comment_mime_type "text/plain" \
			 -user_id $user_id \
			 -assignment [array get assign_array]]


	# Get the role_id for the stream coordinator role.
	set stream_coordinator_role_id [workflow::role::get_id \
					    -workflow_id $workflow_id \
					    -short_name stream_coordinator]
    
	# Assign the stream coordinators
	workflow::case::role::assignee_insert -case_id $case_id \
	    -role_id $stream_coordinator_role_id \
	    -party_ids $stream_coordinator_ids -replace

	return $uos_id
    }
}


ad_proc -public curriculum_central::uos::insert {
    -uos_id:required
    -package_id:required
    -uos_name_id:required
    -credit_value:required
    -department_id:required
    -unit_coordinator_id:required
    -session_ids:required
    -prerequisite_ids:required
    -assumed_knowledge_ids:required
    -corequisite_ids:required
    -prohibition_ids:required
    -no_longer_offered_ids:required
    -activity_log:required
    {-user_id ""}
} {
    Inserts a new Unit of Study into the content repository.  You should
    use curriculum_central::uos::new to make use of workflow side-effects.
    
    @see curriculum_central::uos::new
    @return uos_id The same uos_id passed in, for convenience.
} {
    set uos_id [package_instantiate_object \
        -var_list [list [list uos_id $uos_id] \
		       [list package_id $package_id] \
		       [list user_id $user_id] \
		       [list uos_name_id $uos_name_id] \
		       [list credit_value $credit_value] \
		       [list department_id $department_id] \
		       [list unit_coordinator_id $unit_coordinator_id] \
		       [list session_ids $session_ids] \
		       [list prerequisite_ids $prerequisite_ids] \
		       [list assumed_knowledge_ids $assumed_knowledge_ids] \
		       [list corequisite_ids $corequisite_ids] \
		       [list prohibition_ids $prohibition_ids] \
		       [list no_longer_offered_ids $no_longer_offered_ids] \
		       [list activity_log $activity_log] \
		       [list object_type "cc_uos"]] \
		    -package_name "cc_uos" \
		    "cc_uos"]

    # Initiate cc_uos_detail
    set detail_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_detail"]] \
		       "cc_uos_detail"]

    # Initiate cc_uos_tl
    set tl_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_tl"]] \
		       "cc_uos_tl"]

    # Initiate cc_uos_textbook_set
    set textbook_set_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_textbook_set"]] \
		       "cc_uos_textbook_set"]

    # Initiate cc_uos_gradattr_set
    set ga_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_gradattr_set"]] \
		       "cc_uos_gradattr_set"]

    # Initiate cc_uos_workload
    set workload_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_workload"]] \
		       "cc_uos_workload"]

    # Initiate cc_uos_assess
    set assess_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_assess"]] \
		       "cc_uos_assess"]

    # Initiate cc_uos_grade_set
    set textbook_set_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_grade_set"]] \
		       "cc_uos_grade_set"]

    # Initiate cc_uos_schedule_set
    set textbook_set_id [package_instantiate_object \
        -var_list [list [list parent_uos_id $uos_id] \
	  	        [list package_id $package_id] \
		        [list object_type "cc_uos_schedule_set"]] \
		       "cc_uos_schedule_set"]

    return $uos_id
}


ad_proc -public curriculum_central::uos::edit {
    -uos_id:required
    -enabled_action_id:required
    -activity_log:required
    -array:required
    {-user_id ""}
    {-creation_ip ""}
    {-entry_id {}}
} {
    Edit a Unit of Study, then send out notifications as workflow
    side-effects.

    @return uos_id The same uos_id passed in, for convenience.
    @see curriculum_central::uos::update
} {

    upvar $array row

    array set assignments [list]

    if { $user_id eq "" } {
	set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    set role_prefix "role_"
    foreach name [array names row "${role_prefix}*"] {
        set assignments([string range $name \
			     [string length $role_prefix] end]) $row($name)
	
	# Get the reassigned unit_coordinator_id
	if { $name eq "role_unit_coordinator" } {
	    set row(unit_coordinator_id) $row($name)
	}

        unset row($name)
    }

    db_transaction {

	# Update the UoS info.
	curriculum_central::uos::update -uos_id $uos_id \
	    -user_id $user_id \
	    -creation_ip $creation_ip \
	    -array row

	set case_id [workflow::case::get_id \
			 -workflow_short_name [workflow_short_name] \
			 -object_id $uos_id]

	# Assignments
	workflow::case::role::assign \
	    -replace \
	    -case_id $case_id \
	    -array assignments

	workflow::case::action::execute \
	    -enabled_action_id $enabled_action_id \
	    -comment $activity_log \
	    -comment_mime_type "text/plain" \
	    -user_id $user_id \
	    -entry_id $entry_id
	    
    }

    return $uos_id
}


ad_proc -public curriculum_central::uos::update {
    -uos_id:required
    {-user_id ""}
    {-creation_ip ""}
    -array:required
} {
    Update a Unit of Study in the DB.  This proc is called by
    curriculum_central::uos::edit.  Use the edit proc to change
    workflow.  This update proc creates a new revision of the
    given Unit of Study.

    @param uos_id The ID of the Unit of Study to update.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.
    @param array An array of updated Unit of Study fields.
    @see curriculum_central::uos::edit
    @return uos_id The same uos_id passed in, for convenience.
} {
    upvar $array row

    if { ![exists_and_not_null user_id] } {
        set user_id [ad_conn user_id]
    }

    curriculum_central::uos::get -uos_id $uos_id -array new_row

    foreach column [array names row] {
        set new_row($column) $row($column)
    }
    set new_row(creation_user) $user_id
    set new_row(creation_ip) $creation_ip

    foreach name [array names new_row] {
        set $name $new_row($name)
    }

    db_transaction {
	set revision_id [db_exec_plsql update_uos {}]

	# If unit_coordinator_id exists, then update the cc_uos table
	# that caches the coordinator for a UoS.  This is required
	# when the Unit Coordinator has been reassigned.
	if { [info exists unit_coordinator_id] } {
	    db_dml update_unit_coordinator {}
	}
    }

    return $uos_id
}


ad_proc -public curriculum_central::uos::update_details {
    -detail_id:required
    {-lecturer_ids ""}
    {-tutor_ids ""}
    {-objectives ""}
    {-learning_outcomes ""}
    {-syllabus ""}
    {-relevance ""}
    {-online_course_content ""}
    {-note ""}
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the details for a Unit of Study.  This update proc creates
    a new details revision of the given Unit of Study.

    @param detail_id The ID of the Unit of Study to update.
    @param lecturer_ids The ID of the selected lecturers.
    @param tutor_ids The ID of the selected tutors.
    @param objectives Unit of Study objectives.
    @param learning_outcomes Unit of Study learning outcomes.
    @param syllabus Unit of Study syllabus.
    @param relevance Unit of Study relevance.
    @param online_course_content URL of the online course content for the
    associated Unit of Study.
    @param note Note for the UoS.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	set revision_id [db_exec_plsql update_details {}]
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_tl {
    -tl_id:required
    -uos_id:required
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the teaching and learning component for a Unit of Study.
    This update proc creates a new teaching and learning revision..

    @param tl_id The ID of the teaching and learning object to update.
    @param uos_id Unit of Study ID.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	# Retrieve teaching and learning info for Unit of Study.
	curriculum_central::uos::get_tl \
	    -uos_id $uos_id \
	    -array uos_tl

	set revision_id [db_exec_plsql update_tl {}]

	# Foreach tl_approach_id map to the newly created revision_id
	# retrieved above.
	foreach tl_approach_id $uos_tl(tl_approach_ids) {
	    db_exec_plsql map_tl_to_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_textbooks {
    -textbook_set_id:required
    -uos_id:required
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the textbooks component for a Unit of Study.
    This update proc creates a new textbook revision.

    @param textbook_set_id The ID for a set of textbooks.
    @param Unit of Study ID.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	# Retrieve textbook info for Unit of Study.
	curriculum_central::uos::get_textbooks \
	    -uos_id $uos_id \
	    -array uos_textbook

	set revision_id [db_exec_plsql update_textbook_set {}]

	# Foreach textbook_id map to the newly created revision_id
	# retrieved above.
	foreach textbook_id $uos_textbook(textbook_ids) {
	    db_exec_plsql map_textbook_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_graduate_attributes {
    -gradattr_set_id:required
    -uos_id:required
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the graduate attributes component for a Unit of Study.
    This update proc creates a new graduate attributes revision.

    @param gradattr_set_id The ID for a set of graduate attributes.
    @param uos_id Unit of Study ID.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	# Retrieve graduate attribute infor for Unit of Study.
	curriculum_central::uos::get_graduate_attributes \
	    -uos_id $uos_id \
	    -array uos_gradattr

	set revision_id [db_exec_plsql update_ga {}]

	# Foreach gradattr_id map to the newly created revision_id
	# retrieved above.
	foreach gradattr_id $uos_gradattr(gradattr_ids) {
	    db_exec_plsql map_ga_to_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_workload {
    -workload_id:required
    {-formal_contact_hrs ""}
    {-informal_study_hrs ""}
    {-student_commitment ""}
    {-expected_feedback ""}
    {-student_feedback ""}
    {-assumed_concepts ""}
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the workload for a Unit of Study.  This update proc creates
    a new workload revision for the given Unit of Study.

    @param workload_id The ID of the Unit of Study to update.
    @param formal_contact_hrs Formal contact hours.
    @param informal_study_hrs Informal study hours required to master concepts.
    @param student_commitment Students are expected to commit to this UoS by...
    @param expected_feedback Students can expect feedback for this UoS in the
    nature of...
    @param student_feedback Students can provide feedback for this UoS by...
    @param assumed_concepts Concepts that we assume that the student has a grasp of.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	set revision_id [db_exec_plsql update_workload {}]
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_assess {
    -assess_id:required
    -uos_id:required
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the assessment component for a Unit of Study.
    This update proc creates a new assessment revision.

    @param assess_id The ID of the assessment object to update.
    @param uos_id Unit of Study ID.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	# Retrieve assessment info for Unit of Study.
	curriculum_central::uos::get_assessment \
	    -uos_id $uos_id \
	    -array uos_assess

	set revision_id [db_exec_plsql update_assess {}]

	# Foreach assess_method_id map to the newly created revision_id
	# retrieved above.
	foreach assess_method_id $uos_assess(assess_method_ids) {
	    db_exec_plsql map_assess_to_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_grade_descriptors {
    -grade_set_id:required
    -grade_descriptors:required
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the grade descriptor component for a Unit of Study.
    This update proc creates a new grade descriptor revision.

    @param grade_set_id The ID for a set of grade descriptors.
    @param grade_descriptors List of grade descriptors
    to be mapped to the textbook set.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    set package_id [ad_conn package_id]

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	set revision_id [db_exec_plsql update_grade_set {}]

	# Foreach grade_descriptor map to the newly created revision_id
	# retrieved above.
	foreach grade_descriptor $grade_descriptors {
	    set grade_type_id [lindex $grade_descriptor 0]
	    set description [lindex $grade_descriptor 1]

	    set grade_id [package_instantiate_object \
	        -var_list [list [list package_id $package_id] \
 			        [list grade_type_id $grade_type_id] \
			        [list description $description] \
			        [list object_type "cc_uos_grade"]] \
			      "cc_uos_grade"]
	    
	    # Use the above grade_id to map to the revision_id
	    db_exec_plsql map_grade_descriptor_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::update_schedule {
    -schedule_set_id:required
    -schedule_fields:required
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the weekly schedule component for a Unit of Study.
    This update proc creates a new schedule revision.

    @param schedule_set_id The ID for a set of schedule weeks.
    @param schedule_fields List of schedule fields to be mapped
    to the textbook set.  The list is structured to contain the week_id
    as the first item, the value for the course content field as the
    second item, and a list of assessment IDs as the third item.
    @param user_id The ID of the user that updated the Unit of Study.
    @param creation_ip The IP of the user that made the update.

    @return revision_id Returns the ID of the newly created revision for
    convenience, otherwise the empty string if unsuccessful.
} {
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    if { $creation_ip eq "" } {
	set creation_ip [ad_conn peeraddr]
    }

    set package_id [ad_conn package_id]

    # Set the default value for revision_id.
    set revision_id ""
    db_transaction {
	set revision_id [db_exec_plsql update_schedule_set {}]

	# Foreach schedule field, map to the newly created revision_id
	# retrieved above.
	foreach field $schedule_fields {
	    set week_id [lindex $field 0]
	    set course_content [lindex $field 1]
	    set assessment_ids [lindex $field 2]

	    set schedule_id [package_instantiate_object \
	        -var_list [list [list package_id $package_id] \
 			        [list week_id $week_id] \
			        [list course_content $course_content] \
			        [list assessment_ids $assessment_ids] \
			        [list object_type "cc_uos_schedule"]] \
			      "cc_uos_schedule"]
	    
	    # Use the above schedule_id to map to the revision_id
	    db_exec_plsql map_schedule_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::get_pretty_name {
    {-uos_id:required}
} {
    Get the name for a UoS.

    @param uos_id The ID of the Unit of Study for which we return
    the name for.

    @return The name of the given UoS ID.  Returns an empty string
    if a name could not be found.
} {
    return [db_string pretty_name {} -default ""]
}


ad_proc -private curriculum_central::uos::uos_available_name_get_options {
    {-package_id ""}
} {
    Returns a two-column list of registered UoS names that cannot be found
    in cc_uos.

    @param package_id ID of the current package instance.

    @return Returns a two-column list of registered UoS names.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    set names_list [db_list_of_lists names {}]

    return $names_list
}


ad_proc -public curriculum_central::uos::get_details {
    {-uos_id:required}
    {-array:required}
} {
    Get the details fields for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    detail fields for.
    @param array A predefined array for returning fields in.  Values include
    detail_id, lecturer_ids, tutor_ids, objectives, learning_outcomes,
    syllabus, relevance, online_course_content, note.

    @return Array containing all valid fields for the cc_uos_detail table.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_details {} -column_array row] } {
	# Set default values
	set row(detail_id) ""
	set row(lecturer_ids) ""
	set row(tutor_ids) ""
	set row(objectives) ""
	set row(learning_outcomes) ""
	set row(syllabus) ""
	set row(relevance) ""
	set row(online_course_content) ""
	set row(note) ""
    }
}


ad_proc -public curriculum_central::uos::get_tl {
    {-uos_id:required}
    {-array:required}
} {
    Get the teaching and learning fields for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    teaching and learning info for.
    @param array A predefined array for returning fields in.  Values include
    tl_id, tl_approach_ids, latest_revision_id.

    @return Array containing all valid fields for the cc_uos_tl table.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_tl {} -column_array row] } {
	# Set default values
	set row(tl_id) ""
	set row(latest_revision_id) ""
    }
    
    if { $row(latest_revision_id) ne "" } {
	set latest_revision_id $row(latest_revision_id)
	set row(tl_approach_ids) [db_list latest_tl_method_ids {}]
    } else {
	set row(tl_approach_ids) ""
    }
}


ad_proc -public curriculum_central::uos::get_textbooks {
    {-uos_id:required}
    {-array:required}
} {
    Get textbook info for the given Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    textbook info for.
    @param array A predefined array for returning fields in.  Values include
    textbook_set_id, textbook_ids, latest_revision_id.

    @return Array containing all valid fields for the cc_uos_textbook table.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_textbook_set {} -column_array row] } {
	# Set default values
	set row(textbook_set_id) ""
	set row(latest_revision_id) ""
    }
    
    if { $row(latest_revision_id) ne "" } {
	set latest_revision_id $row(latest_revision_id)
	set row(textbook_ids) [db_list latest_textbook_ids {}]
    } else {
	set row(textbook_ids) ""
    }
}


ad_proc -public curriculum_central::uos::get_graduate_attributes {
    {-uos_id:required}
    {-array:required}
} {
    Get the graduate attributes for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    graduate attributes for.
    @param array A predefined array for returning fields in.  Values include
    gradattr_set_id, gradattr_ids, latest_revision_id.

    @return Array containing graduate attributes infor for a UoS.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_ga {} -column_array row] } {
	# Set default values
	set row(gradattr_set_id) ""
	set row(latest_revision_id) ""
    }
    
    if { $row(latest_revision_id) ne "" } {
	set latest_revision_id $row(latest_revision_id)
	set row(gradattr_ids) [db_list latest_gradattr_ids {}]
    } else {
	set row(gradattr_ids) ""
    }
}


ad_proc -public curriculum_central::uos::get_workload {
    {-uos_id:required}
    {-array:required}
} {
    Get the workload fields for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    workload fields for.
    @param array A predefined array for returning fields in.  Values include
    workload_id, formal_contact_hrs, informal_study_hrs, student_commitment,
    expected_feedback, student_feedback, assumed_concepts.

    @return Array containing all valid fields for the cc_uos_workload table.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_workload {} -column_array row] } {
	# Set default values
	set row(workload_id) ""
	set row(formal_contact_hrs) ""
	set row(informal_study_hrs) ""
	set row(student_commitment) ""
	set row(expected_feedback) ""
	set row(student_feedback) ""
	set row(assumed_concepts) ""
    }
}


ad_proc -public curriculum_central::uos::get_assessment {
    {-uos_id:required}
    {-array:required}
} {
    Get the assessment info for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    assessment info for.
    @param array A predefined array for returning fields in.  Values include
    assess_id, assess_method_ids, latest_revision_id.

    @return Array containing all valid fields for the cc_uos_assess table.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_assess {} -column_array row] } {
	# Set default values
	set row(assess_id) ""
	set row(latest_revision_id) ""
    }
    
    if { $row(latest_revision_id) ne "" } {
	set latest_revision_id $row(latest_revision_id)
	set row(assess_method_ids) [db_list latest_assess_method_ids {}]
    } else {
	set row(assess_method_ids) ""
    }
}


ad_proc curriculum_central::uos::tl_method_get_options {
    {-package_id ""}
    {-user_id ""}
} {
    Returns a two-column list of registered teaching and learning methods.

    @param package_id ID of the current package instance.
    @param user_id Specify a user to retrieve their list of
    T&L methods, otherwise a list of T&L methods is
    returned by default for the requesting user.

    @return Returns a two-column list of registered teaching and
    learning methods.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    if { $user_id eq ""} {
	set user_id [ad_conn user_id]
    }

    set method_list [db_list_of_lists tl_methods {}]

    return $method_list
}


ad_proc curriculum_central::uos::textbook_get_options {
    {-package_id ""}
    {-user_id ""}
} {
    Returns a two-column list of registered textbooks.

    @param package_id ID of the current package instance.
    @param user_id Specify a user to retrieve their list of
    textbooks, otherwise a list of textbooks are
    returned by default for the requesting user.

    @return Returns a two-column list of registered textbooks.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    if { $user_id eq ""} {
	set user_id [ad_conn user_id]
    }

    set textbook_list [db_list_of_lists textbooks {}]

    return $textbook_list
}


ad_proc curriculum_central::uos::graduate_attributes_get_options {
    {-package_id ""}
    {-user_id ""}
} {
    Returns a two-column list of user registered graduate attributes.
    These are graduate attributes that have been selected from the
    global list of graduate attributes, and assigned a description
    by the Unit Coordinator.

    @param package_id ID of the current package instance.
    @param user_id Specify a user to retrieve their list of
    graduate attribtues, otherwise a list of graduate attributes is
    returned by default for the requesting user.

    @return Returns a two-column list of registered graduate attributes.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    if { $user_id eq ""} {
	set user_id [ad_conn user_id]
    }

    set ga_list [list]
    db_foreach select_ga {} {
	set ga_name "[lang::util::localize $name] ($identifier)"
	
	lappend ga_list [list $ga_name $gradattr_id]
    }

    return $ga_list
}


ad_proc curriculum_central::uos::assess_method_get_options {
    {-package_id ""}
    {-user_id ""}
} {
    Returns a two-column list of registered assessment methods.

    @param package_id ID of the current package instance.
    @param user_id Specify a user to retrieve their list of
    assessment methods, otherwise a list of assessment methods is
    returned by default for the requesting user.

    @return Returns a two-column list of registered assessment methods.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    if { $user_id eq ""} {
	set user_id [ad_conn user_id]
    }

    # Create an empty option that the user can select.  The value of
    # which is an empty string.
    set empty_option [list [list [list [_ curriculum-central.none]] 0]]
    set method_list [db_list_of_lists assess_methods {}]

    return [concat $empty_option $method_list]
}


#####
#
# UoS Pending
#
#####

ad_proc -public curriculum_central::uos::num_pending {
    {-workflow_id ""}
    {-user_id ""}
} {
    Get the number of all pending Units of Study, or those that belong
    to a single Unit Coordinator.  Note: Pending is a workflow state that
    isn't "closed".

    @param workflow_id The workflow ID for the current package instance
    of curriculum central.
    @param user_id The user_id of a Unit Coordinator.

    @return Returns the number of pending Units of Study for the specified
    Unit Coordinator.  If a user_id isn't provided, then this proc
    returns the number of all pending Units of Study.

    @see curriculum_central::uos::get_instance_workflow_id
} {
    if { $workflow_id eq ""} {
	set workflow_id [curriculum_central::uos::get_instance_workflow_id]
    }

    if { $user_id eq ""} {
	return [db_string get_all_pending_uos {} -default {}]
    }

    return [db_string get_users_pending_uos {} -default {}]    
}


#####
#
# Format log title
#
#####

ad_proc -private curriculum_central::uos::format_log_title::pretty_name {} {
    return "[_ curriculum-central.activity_log]"
}

ad_proc -private curriculum_central::uos::format_log_title::format_log_title {
    case_id
    object_id
    action_id
    entry_id
    data_arraylist
} {
    array set data $data_arraylist

    return {}
}


#####
#
# Get Unit Coordinator
#
#####

ad_proc -private curriculum_central::uos::get_unit_coordinator::pretty_name {} {
    return "[_ curriculum-central.unit_coordinator]"
}

ad_proc -private curriculum_central::uos::get_unit_coordinator::get_assignees {
    case_id
    object_id
    role_id
} {
    return [db_list select_unit_coordinators {}]
}

ad_proc -private curriculum_central::uos::get_unit_coordinator::get_pick_list {
    case_id
    object_id
    role_id
} {
    return [db_list select_unit_coordinators {}]
}

ad_proc -private curriculum_central::uos::get_unit_coordinator::get_subquery {
    case_id
    object_id
    role_id
} {
    return [db_map unit_coordinator_subquery]
}


#####
#
# Get Stream Coordinator
#
#####

ad_proc -private curriculum_central::uos::get_stream_coordinator::pretty_name {} {
    return "[_ curriculum-central.stream_coordinator]"
}

ad_proc -private curriculum_central::uos::get_stream_coordinator::get_assignees {
    case_id
    object_id
    role_id
} {
    return [db_list select_stream_coordinators {}]
}

ad_proc -private curriculum_central::uos::get_stream_coordinator::get_pick_list {
    case_id
    object_id
    role_id
} {
    return [db_list select_stream_coordinators {}]
}

ad_proc -private curriculum_central::uos::get_stream_coordinator::get_subquery {
    case_id
    object_id
    role_id
} {
    return [db_map stream_coordinator_subquery]
}


#####
#
# Notification Info
#
#####

ad_proc -private curriculum_central::uos::notification_info::pretty_name {} {
    return "[_ curriculum-central.uos_info]"
}


ad_proc -private curriculum_central::uos::notification_info::get_notification_info {
    case_id
    object_id
} {

    set package_id [ad_conn package_id]
    set url "[ad_url][apm_package_url_from_id $package_id]coordinate/uos-edit?[export_vars { {uos_id $object_id} }]"

    set one_line [curriculum_central::uos::get_pretty_name -uos_id $object_id]

    set details_list [list]
    
    if { [db_0or1row uos_details {}] } {
	lappend details_list [_ curriculum-central.credit_value] $credit_value
	lappend details_list [_ curriculum-central.department] $department_name
	lappend details_list [_ curriculum-central.sessions] \
	    [curriculum_central::join_sessions -session_ids $session_ids]

	lappend details_list [_ curriculum-central.lecturers] \
	    [curriculum_central::join_staff -staff_ids $lecturer_ids]

	lappend details_list [_ curriculum-central.tutors] \
	    [curriculum_central::join_staff -staff_ids $tutor_ids]

	lappend details_list [_ curriculum-central.aims_and_objectives] \
	    [template::util::richtext::get_property text $objectives]

	lappend details_list [_ curriculum-central.learning_outcomes] \
	    [template::util::richtext::get_property text $learning_outcomes]

	lappend details_list [_ curriculum-central.syllabus] \
	    [template::util::richtext::get_property text $syllabus]

	lappend details_list [_ curriculum-central.relevance] \
	    [template::util::richtext::get_property text $relevance]

	lappend details_list [_ curriculum-central.online_course_content] \
	    $online_course_content

	lappend details_list [_ curriculum-central.graduate_attributes] \
	    [curriculum_central::join_graduate_attributes \
		 -uos_id $object_id]

	lappend details_list [_ curriculum-central.note] \
	    [template::util::richtext::get_property text $note]
    }
    

    # Learning Outcomes
    # Syllabus
    # Relevance
    # Online Course Content
    # Graduate attributes
    # Note

    set notification_subject_tag [_ curriculum-central.notification]

    return [list $url $one_line $details_list $notification_subject_tag]
}


#####
#
# UoS Go Live
#
#####

ad_proc -private curriculum_central::uos::go_live::pretty_name {} {
    return "[_ curriculum-central.go_live]"
}


ad_proc -private curriculum_central::uos::go_live::do_side_effect {
    case_id
    object_id
    action_id
    entry_id
} {
    # Get the latest revision for the given content item.
    db_1row get_latest_revision {}

    # Set the latest revision as the live revision for the given
    # content item (object_id).
    content::item::set_live_revision -revision_id $latest_revision

    # Also set the latest revision to the live revision in cc_uos.
    db_dml set_live_revision {}

    # NC: This needs to be done better.  Works for the timebeing.

    # Do the same for cc_uos_detail
    db_1row get_latest_detail_revision {}
    content::item::set_live_revision -revision_id $latest_detail_revision
    db_dml set_live_detail_revision {}

    # Do the same for cc_uos_tl
    db_1row get_latest_tl_revision {}
    content::item::set_live_revision -revision_id $latest_tl_revision
    db_dml set_live_tl_revision {}

    # Do the same for cc_uos_textbook_set
    db_1row get_latest_textbook_revision {}
    content::item::set_live_revision -revision_id $latest_textbook_revision
    db_dml set_live_textbook_revision {}

    # Do the same for cc_uos_gradattr_set
    db_1row get_latest_ga_revision {}
    content::item::set_live_revision -revision_id $latest_ga_revision
    db_dml set_live_ga_revision {}

    # Do the same for cc_uos_workload
    db_1row get_latest_workload_revision {}
    content::item::set_live_revision -revision_id $latest_workload_revision
    db_dml set_live_workload_revision {}

    # Do the same for cc_uos_assess
    db_1row get_latest_assess_revision {}
    content::item::set_live_revision -revision_id $latest_assess_revision
    db_dml set_live_assess_revision {}

    # Do the same for cc_uos_grade
    db_1row get_latest_grade_revision {}
    content::item::set_live_revision -revision_id $latest_grade_revision
    db_dml set_live_grade_revision {}

    # Do the same for cc_uos_schedule
    db_1row get_latest_schedule_revision {}
    content::item::set_live_revision -revision_id $latest_schedule_revision
    db_dml set_live_schedule_revision {}
}


#####
#
# Utility procs
#
#####

ad_proc -public curriculum_central::uos::get_assessment_total {
    {-assess_id:required}
} {
    Get the current assessment weighting total for the given assessment group.

    @param assess_id The ID for an assessment group.

    @return Returns the sum of all assessment weightings for a given
    assessment group identified by the assess_id in table  cc_uos_assess.
    If the result is an empty string, then 0 is returned.
} {
    set total [db_string latest_assess_total {} -default ""]

    # Return 0 if there is an empty result.
    if { $total eq ""} {
	return 0
    }

    return $total
}


ad_proc -public curriculum_central::uos::get_grade_descriptor_pretty_name {
    {-type_id:required}
    {-package_id ""}
} {
    Returns a pretty name for the grade descriptor that matches the given
    type_id.

    @param type_id The ID for a grade descriptor type.
    @param package_id Instance ID of a package.

    @return Returns a pretty name for the grade descriptor that matches the
    given type_id.  Pretty name includes the grade bounds.  Returns an
    empty string if there is no name for the given type_id.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    return [db_string pretty_name {} -default ""]
}


ad_proc -public curriculum_central::uos::get_grade_descriptor_fields {
    {-package_id ""}
} {
    Gets a list of grade descriptor field IDs.

    @param package_id Instance ID of a package.

    @return Returns a list of lists where the first item of a list contains
    the grade type ID, and the second item is the field ID, which is just
    the grade type ID appended to the grade_descriptor_ prefix.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    set prefix "grade_descriptor_"

    return [db_list_of_lists fields {}]
}


ad_proc -public curriculum_central::uos::add_grade_descriptor_widgets {
    {-uos_id:required}
    {-form_name:required}
    {-package_id ""}
    {-prefix "grade_descriptor_"}
} {
    @param uos_id The ID of the Unit of Study for which we create grade
    descriptor widgets for.
    @param form_name The name of the form to add widgets to.
    @param package_id
    @param prefix
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    array set row [list]

    if { ![db_0or1row latest_grade_set {} -column_array row] } {
	set row(grade_set_id) ""
	set row(latest_revision_id) ""
    }

    set grade_set_id $row(grade_set_id)
    set latest_revision_id $row(latest_revision_id)

    ad_form -extend -name $form_name -form {
	{grade_set_id:integer(hidden),optional
	    {value $grade_set_id}
	}
	{grade_inform:text(inform)
	    {label "[_ curriculum-central.grade_descriptors]"}
	    {value "[_ curriculum-central.following_are_grade_descriptors]"}
	}
    }

    foreach grade_descriptors [db_list_of_lists latest_grade_descriptors {}] {
	set type_id [lindex $grade_descriptors 0]
	set description [lindex $grade_descriptors 1]

	ad_form -extend -name $form_name -form {
	    {${prefix}${type_id}:richtext(richtext)
		{label "[curriculum_central::uos::get_grade_descriptor_pretty_name -type_id $type_id]"}
		{html {cols 50 rows 4}}
		{mode display}
		{value $description}
		{htmlarea_p 0}
		{nospell}
		{help_text "[_ curriculum-central.help_enter_details_of_what_a_student_must_achieve_to_earn_this_grade]"}
	    }
	}
    }
}


ad_proc -public curriculum_central::uos::get_schedule_pretty_name {
    {-week_id:required}
    {-package_id ""}
} {
    Returns a pretty name for the schedule week that matches the given
    week_id.

    @param week_id The ID for a schedule week.
    @param package_id Instance ID of a package.

    @return Returns a pretty name for the schedule week that matches the
    given week_id.  Returns an empty string if there is no name for the
    given week_id.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    return [db_string pretty_name {} -default ""]
}


ad_proc -public curriculum_central::uos::get_schedule_fields {
    {-package_id ""}
} {
    Gets a list of schedule field IDs.

    @param package_id Instance ID of a package.

    @return Returns a list of lists where the first item of a list contains
    the schedule week ID, the second item is the field ID for course content,
    which is just the schedule week ID appended to the schedule_week_content_
    prefix.  Similarly, the third item is the field ID for assessment IDs,
    which is the schedule week ID appended to the schedule_week_assessment_
    prefix.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    set content_prefix "schedule_week_content_"
    set assessment_prefix "schedule_week_assessment_"

    return [db_list_of_lists fields {}]
}


ad_proc -public curriculum_central::uos::add_schedule_widgets {
    {-uos_id:required}
    {-form_name:required}
    {-section_name ""}
    {-package_id ""}
    {-content_prefix "schedule_week_content_"}
    {-assessment_prefix "schedule_week_assessment_"}
} {
    @param uos_id The ID of the Unit of Study for which we create
    schedule widgets for.
    @param form_name The name of the form to add widgets to.
    @param section_name If provided, a section will be added to the form
    with the given name.  Otherwise no section header will be added.
    @param package_id A package instance ID.  Otherwise the current
    package instance ID is used.
    @param content_prefix Prefix used to generate the form field for
    the course content for a scheduled week.
    @param assessment_prefix Prefix used to generate the form field for
    the assessment for a scheduled week.
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }

    # If the section name is provided, then add a section to the form
    # using the given section name.
    if { $section_name ne "" } {
	template::form::section $form_name $section_name
    }

    array set row [list]

    if { ![db_0or1row latest_schedule_set {} -column_array row] } {
	set row(schedule_set_id) ""
	set row(latest_revision_id) ""
    }

    set schedule_set_id $row(schedule_set_id)
    set latest_revision_id $row(latest_revision_id)

    ad_form -extend -name $form_name -form {
	{schedule_set_id:integer(hidden),optional
	    {value $schedule_set_id}
	}
    }

    foreach week [db_list_of_lists latest_schedule {}] {
	set week_id [lindex $week 0]
	set course_content [lindex $week 1]
	set assessment_ids [lindex $week 2]

	ad_form -extend -name $form_name -form {
	    {${content_prefix}${week_id}:richtext(richtext)
		{label "[curriculum_central::uos::get_schedule_pretty_name -week_id $week_id] [_ curriculum-central.course_content]"}
		{html {cols 50 rows 4}}
		{mode display}
		{htmlarea_p 0}
		{nospell}
		{value $course_content}
	    }
	    {${assessment_prefix}${week_id}:text(multiselect),multiple,optional
		{label "[curriculum_central::uos::get_schedule_pretty_name -week_id $week_id] [_ curriculum-central.assessment]"}
		{options [curriculum_central::uos::assess_method_get_options]}
		{html {size 5}}
		{mode display}
		{values $assessment_ids}
	    }
	}
    }
}
