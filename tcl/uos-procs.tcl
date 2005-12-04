ad_library {

    Curriculum Central UoS Library
    
    Procedures that deal with a single Unit of Study (UoS).

    @creation-date 2005-11-08
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$

}

namespace eval curriculum_central::uos {}

namespace eval curriculum_central::uos::format_log_title {}

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
                    }
                }
                unit_coordinator {
                    pretty_name "#curriculum-central.unit_coordinator#"
                    callbacks {
                        workflow.Role_PickList_CurrentAssignees
                        workflow.Role_AssigneeSubquery_RegisteredUsers
                    }
                }
		lecturer {
		    pretty_name "#curriculum-central.lecturer#"
		}
            }
            states {
                open {
                    pretty_name "#curriculum-central.open#"
                    hide_fields { resolution fixed_in_version }
                }
                completed {
                    pretty_name "#curriculum-central.completed#"
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
                edit {
                    pretty_name "#curriculum-central.edit#"
                    pretty_past_tense "#curriculum-central.edited#"
                    allowed_roles {
			stream_coordinator
			unit_coordinator
			lecturer
		    }
                    privileges { write }
                    always_enabled_p t
                    edit_fields { 
                        component_id 
                        summary 
                        found_in_version
                        role_resolver
                        fix_for_version
                        resolution 
                        fixed_in_version 
                    }
                }
                reassign {
                    pretty_name "#curriculum-central.reassign#"
                    pretty_past_tense "#curriculum-central.reassigned#"
                    allowed_roles {
			stream_coordinator
			unit_coordinator
		    }
                    privileges { write }
                    enabled_states { completed }
                    assigned_states { open }
                    edit_fields { role_resolver }
                }
                complete {
                    pretty_name "#curriculum-central.complete#"
                    pretty_past_tense "#curriculum-central.completed#"
                    assigned_role unit_coordinator
                    enabled_states { completed }
                    assigned_states { open }
                    new_state completed
                    privileges { write }
                    edit_fields { resolution fixed_in_version }
                }
                close {
                    pretty_name "#curriculum-central.close#"
                    pretty_past_tense "#curriculum-central.closed#"
                    assigned_role stream_coordinator
                    assigned_states { completed }
                    new_state closed
                    privileges { write }
                }
                reopen {
                    pretty_name "#curriculum-central.reopen#"
                    pretty_past_tense "#curriculum-central.reopened#"
                    allowed_roles { stream_coordinator unit_coordinator }
                    enabled_states { completed closed }
                    new_state open
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

ad_proc -public curriculum_central::uos::new {
    -uos_id:required
    -package_id:required
    -uos_code:required
    -uos_name:required
    -credit_value:required
    -semester:required
    -online_course_content
    -unit_coordinator_id:required
    -contact_hours:required
    -assessments:required
    -core_uos_for
    -recommended_uos_for
    -prerequisites:required
    -objectives:required
    -outcomes:required
    -syllabus:required
    -syllabus_format:required
    {-user_id ""}
} {
    Create a new Unit of Study, then send out notifications, starts
    workflow, etc.

    @return uos_id The same uos_id passed in, for convenience.
} {
    db_transaction {
	if { $user_id eq ""} {
	    set user_id [ad_conn user_id]
	}

	set uos_id [package_instantiate_object \
	    -var_list [list [list uos_id $uos_id] \
	         [list package_id $package_id] \
		 [list user_id $user_id] \
		 [list uos_code $uos_code] \
		 [list uos_name $uos_name] \
		 [list credit_value $credit_value] \
		 [list semester $semester] \
		 [list online_course_content $online_course_content] \
		 [list unit_coordinator_id $unit_coordinator_id] \
		 [list contact_hours $contact_hours] \
		 [list assessments $assessments] \
		 [list core_uos_for $core_uos_for] \
		 [list recommended_uos_for $recommended_uos_for] \
		 [list prerequisites $prerequisites] \
	       	 [list objectives $objectives] \
	         [list outcomes $outcomes] \
     	         [list syllabus $syllabus] \
		 [list syllabus_format $syllabus_format]] \
	     -package_name "cc_uos" \
	     "cc_uos"]

	array set assign_array [list unit_coordinator $unit_coordinator_id]

	# Create a new workflow case for the given UoS.
	set case_id [workflow::case::new \
			 -workflow_id [workflow::get_id \
					   -object_id $package_id \
					   -short_name [workflow_short_name]] \
			 -object_id $uos_id \
			 -comment $syllabus \
			 -comment_mime_type $syllabus_format \
			 -user_id $user_id \
			 -assignment [array get assign_array]]

	return $uos_id
    }
}


#####
#
# Format log title
#
#####

ad_proc -private curriculum_central::uos::format_log_title::pretty_name {} {
    return "[_ curriculum-central.res_code_to_log_title]"
}

ad_proc -private curriculum_central::uos::format_log_title::format_log_title {
    case_id
    object_id
    action_id
    entry_id
    data_arraylist
} {
    array set data $data_arraylist

    if { [info exists data(resolution)] } {
        return [curriculum_central::resolution_pretty $data(resolution)]
    } else {
        return {}
    }
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
