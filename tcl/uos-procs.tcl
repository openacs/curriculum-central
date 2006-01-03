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


# TODO: Complete workflow
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
                    privileges { read write }
                    always_enabled_p t
                }
                reassign {
                    pretty_name "#curriculum-central.reassign#"
                    pretty_past_tense "#curriculum-central.reassigned#"
                    allowed_roles {
			stream_coordinator
		    }
                    privileges { write }
                    assigned_states { open }
                    edit_fields { role_unit_coordinator }
                }
                edit_details {
                    pretty_name "#curriculum-central.edit_details#"
                    pretty_past_tense "#curriculum-central.edited_details#"
                    allowed_roles {
			stream_coordinator
			unit_coordinator
			lecturer
		    }
                    privileges { write }
		    assigned_states { open }
                    edit_fields { 
			lecturer_id
			objectives
			learning_outcomes
			syllabus
			relevance
			online_course_content
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
			tl_approach_ids
		    }
		    assigned_states { open }
                }
                submit {
                    pretty_name "#curriculum-central.submit#"
                    pretty_past_tense "#curriculum-central.submitted#"
                    assigned_role { unit_coordinator }
                    assigned_states { open }
                    new_state { submitted }
                    privileges { write }
                }
                close {
                    pretty_name "#curriculum-central.close#"
                    pretty_past_tense "#curriculum-central.closed#"
                    assigned_role { stream_coordinator }
                    assigned_states { submitted }
                    new_state closed
                    privileges { write }
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
    -uos_code:required
    -uos_name:required
    -credit_value:required
    -semester:required
    -unit_coordinator_id:required
    -activity_log:required
    -activity_log_format:required
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
			-uos_code $uos_code \
			-uos_name $uos_name \
			-credit_value $credit_value \
			-semester $semester \
			-unit_coordinator_id $unit_coordinator_id \
			-activity_log $activity_log \
			-activity_log_format $activity_log_format ]

	array set assign_array [list unit_coordinator $unit_coordinator_id]

	set workflow_id [workflow::get_id \
			     -object_id $package_id \
			     -short_name [workflow_short_name]]

	# Create a new workflow case for the given UoS.
	set case_id [workflow::case::new \
			 -workflow_id $workflow_id \
			 -object_id $uos_id \
			 -comment $activity_log \
			 -comment_mime_type $activity_log_format \
			 -user_id $user_id \
			 -assignment [array get assign_array]]


	# Get the role_id for the stream coordinator role.
	set role_id [workflow::role::get_id -workflow_id $workflow_id \
			 -short_name stream_coordinator]

	# Get a list of stream coordinator IDs.
	# All stream coordinators are assigned the role of stream coordinator
	# for all Units of Study.
	set stream_coordinator_ids [db_list get_stream_coordinator_ids {}]
    
	# Assign the stream coordinators
	workflow::case::role::assignee_insert -case_id $case_id \
	    -role_id $role_id -party_ids $stream_coordinator_ids -replace

	return $uos_id
    }
}


ad_proc -public curriculum_central::uos::insert {
    -uos_id:required
    -package_id:required
    -uos_code:required
    -uos_name:required
    -credit_value:required
    -semester:required
    -unit_coordinator_id:required
    -activity_log:required
    -activity_log_format:required
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
		       [list uos_code $uos_code] \
		       [list uos_name $uos_name] \
		       [list credit_value $credit_value] \
		       [list semester $semester] \
		       [list unit_coordinator_id $unit_coordinator_id] \
		       [list activity_log $activity_log] \
		       [list activity_log_format $activity_log_format] \
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

    return $uos_id
}


ad_proc -public curriculum_central::uos::edit {
    -uos_id:required
    -enabled_action_id:required
    -activity_log:required
    -activity_log_format:required
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
	    -comment_mime_type $activity_log_format \
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
    {-lecturer_id ""}
    {-objectives ""}
    {-learning_outcomes ""}
    {-syllabus ""}
    {-relevance ""}
    {-online_course_content ""}
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the details for a Unit of Study.  This update proc creates
    a new details revision of the given Unit of Study.

    @param uos_id The ID of the Unit of Study to update.
    @param lecturer_id The ID of the selected lecturer.
    @param objectives Unit of Study objectives.
    @param learning_outcomes Unit of Study learning outcomes.
    @param syllabus Unit of Study syllabus.
    @param relevance Unit of Study relevance.
    @param online_course_content URL of the online course content for the
    associated Unit of Study.
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
    -tl_approach_ids
    {-user_id ""}
    {-creation_ip ""}
} {
    Updates the teaching and learning component for a Unit of Study.
    This update proc creates a new teaching and learning revision..

    @param tl_id The ID of the teaching and learning object to update.
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
	set revision_id [db_exec_plsql update_tl {}]

	# Foreach tl_approach_id map to the newly created revision_id
	# retrieved above.
	foreach tl_approach_id $tl_approach_ids {
	    ns_log Warning "Map revision_id <$revision_id> to tl_approach_id <$tl_approach_id>"
	    db_exec_plsql map_tl_to_revision {}
	}
    }

    return $revision_id
}


ad_proc -public curriculum_central::uos::get_details {
    {-uos_id:required}
    {-array:required}
} {
    Get the details fields for a Unit of Study.

    @param uos_id The ID of the Unit of Study for which we return
    detail fields for.
    @param array A predefined array for returning fields in.  Values include
    detail_id, lecturer_id, objectives, learning_outcomes, syllabus,
    relevance, online_course_content.

    @return Array containing all valid fields for the cc_uos_detail table.
} {
    # Select the info into the upvar'ed Tcl array
    upvar $array row

    if { ![db_0or1row latest_details {} -column_array row] } {
	# Set default values
	set row(detail_id) ""
	set row(lecturer_id) ""
	set row(objectives) ""
	set row(learning_outcomes) ""
	set row(syllabus) ""
	set row(relevance) ""
	set row(online_course_content) ""
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


ad_proc curriculum_central::uos::tl_method_get_options {
    {-package_id ""}
} {
    Returns a two-column list of registered teaching and learning methods.

    @return Returns a two-column list of registered teaching and
    learning methods.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    set method_list [db_list_of_lists tl_methods {}]

    return $method_list
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

# TODO: Finish off this proc properly.
ad_proc -private curriculum_central::uos::notification_info::get_notification_info {
    case_id
    object_id
} {
    # TODO: Fix URL
    # set url "[ad_url][apm_package_url_from_id $bug(project_id)]bug?
    # [export_vars { { bug_number $bug(bug_number) } }]"
    set url "[ad_url]"

    set one_line "UoS"

    set details_list [list]
    lappend details_list "label" "value"

    set notification_subject_tag "Notification Subject Tag"

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

    # Do the same for cc_uos_detail
    db_1row get_latest_detail_revision {}
    content::item::set_live_revision -revision_id $latest_detail_revision
    db_dml set_live_detail_revision {}

    # Do the same for cc_uos_tl
    db_1row get_latest_tl_revision {}
    content::item::set_live_revision -revision_id $latest_tl_revision
    db_dml set_live_tl_revision {}
}
