ad_page_contract {
    Add/Edit a UoS.

    Only a stream coordinator, unit coordinator and lecturer can access
    this page, if they are involved in a particular Unit of Study.

    This page implements the UI for the UoS workflow.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$

} [curriculum_central::get_page_variables {
    uos_id:integer,notnull
}]

auth::require_login

set return_url [export_vars -base [ad_conn url] [curriculum_central::get_export_variables {uos_id} ]]

set case_id [workflow::case::get_id \
		-object_id $uos_id \
		 -workflow_short_name \
		 [curriculum_central::uos::workflow_short_name]]

set workflow_id [curriculum_central::uos::get_instance_workflow_id]

# Action
set enabled_action_id [form get_action uos]

# Registration required for all actions
set action_id ""

if { $enabled_action_id ne "" } {
    workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action
    set action_id $enabled_action(action_id)
}

# Buttons
set actions [list]
if { $enabled_action_id eq "" } {
    foreach available_enabled_action_id [workflow::case::get_available_enabled_action_ids -case_id $case_id] {
	workflow::case::enabled_action_get -enabled_action_id $available_enabled_action_id -array enabled_action
        workflow::action::get -action_id $enabled_action(action_id) -array available_action
        lappend actions [list "     [lang::util::localize $available_action(pretty_name)]     " $available_enabled_action_id]
    }
}


# Retrieve info for Unit of Study.
curriculum_central::uos::get \
    -uos_id $uos_id \
    -array uos \
    -enabled_action_id $enabled_action_id

set page_title "$uos(uos_code) $uos(uos_name)"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]

# Create the form
# Create widgets for displaying UoS information that should already
# have been entered by the Stream Coordinator when the UoS was
# initially created.
ad_form -name uos -cancel_url $return_url \
    -mode display -has_edit 1 -actions $actions 

# Add UoS Section
template::form::section uos [_ curriculum-central.uos]

ad_form -extend -name uos -form {
    {uos_code:text(inform)
	{label "[_ curriculum-central.uos_code]"}
	{value $uos(uos_code)}
	{mode display}
    }
    {uos_name:text(inform)
	{label "[_ curriculum-central.uos_name]"}
	{value $uos(uos_name)}
	{mode display}
    }
}

# Only display workflow assignee widget for unit coordinators.
workflow::case::role::add_assignee_widgets \
    -case_id $case_id \
    -form_name uos \
    -role_ids [workflow::role::get_id -workflow_id $workflow_id \
		   -short_name unit_coordinator]

ad_form -extend -name uos -form {
    {credit_value:integer(inform)
	{label "[_ curriculum-central.credit_value]"}
	{value $uos(credit_value)}
	{mode display}	
    }
    {semester:integer(inform)
	{label "[_ curriculum-central.semester_offering]"}
	{value $uos(semester)}
	{mode display}
    }
}

# Add UoS Details Section
template::form::section uos [_ curriculum-central.uos_details]

# Retrieve Details info for Unit of Study.
curriculum_central::uos::get_details \
    -uos_id $uos_id \
    -array uos_details

ad_form -extend -name uos -form {
    {detail_id:integer(hidden),optional
	{value $uos_details(detail_id)}
    }
    {lecturer_id:integer(select),optional
        {label "[_ curriculum-central.lecturer]"}
	{options [curriculum_central::staff_get_options] }
	{value $uos_details(lecturer_id)}
	{mode display}
        {help_text "[_ curriculum-central.help_lecturer_id]"}
    }
    {objectives:text(textarea),optional
        {label "[_ curriculum-central.aims_and_objectives]"}
	{html {cols 50 rows 4}}
	{value $uos_details(objectives)}
	{mode display}
        {help_text "[_ curriculum-central.help_objectives]"}
    }
    {learning_outcomes:text(textarea),optional
        {label "[_ curriculum-central.learning_outcomes]"}
	{html {cols 50 rows 4}}
	{value $uos_details(learning_outcomes)}
	{mode display}
        {help_text "[_ curriculum-central.help_learning_outcomes]"}
    }
    {syllabus:text(textarea),optional
        {label "[_ curriculum-central.syllabus]"}
	{html {cols 50 rows 4}}
	{value $uos_details(syllabus)}
	{mode display}
        {help_text "[_ curriculum-central.help_syllabus]"}
    }
    {relevance:text(textarea),optional
        {label "[_ curriculum-central.relevance]"}
	{html {cols 50 rows 4}}
	{value $uos_details(relevance)}
	{mode display}
        {help_text "[_ curriculum-central.help_relevance]"}
    }
    {online_course_content:text,optional
        {label "[_ curriculum-central.online_course_content]"}
        {html {size 50}}
	{value $uos_details(online_course_content)}
	{mode display}
        {help_text "[_ curriculum-central.help_online_course_content]"}
    }
}

# Add teaching and learning section.
template::form::section uos [_ curriculum-central.tl_arrangements_and_requirements]

# Retrieve teaching and learning info for Unit of Study.
curriculum_central::uos::get_tl \
    -uos_id $uos_id \
    -array uos_tl

# Add widgets for Teaching and Learning.
ad_form -extend -name uos -form {
    {tl_id:integer(hidden),optional
	{value $uos_tl(tl_id)}
    }
    {tl_approach_ids:text(multiselect),multiple,optional
	{label "[_ curriculum-central.teaching_and_learning_approach]"}
	{options [curriculum_central::uos::tl_method_get_options]}
	{html {size 5}}
	{values $uos_tl(tl_approach_ids)}
	{mode display}
	{after_html "<a href=\"tl-methods\">[_ curriculum-central.view_all]</a>"}
        {help_text "[_ curriculum-central.help_tl_approach_ids]"}
    }
}

# Retrieve workflow info for Unit of Study.
curriculum_central::uos::get_workload \
    -uos_id $uos_id \
    -array uos_workload

# Add widgets for workload.
ad_form -extend -name uos -form {
    {workload_id:integer(hidden),optional
	{value $uos_workload(workload_id)}
    }
    {formal_contact_hrs:text(textarea),optional
        {label "[_ curriculum-central.formal_contact_hrs]"}
	{html {cols 50 rows 4}}
	{value $uos_workload(formal_contact_hrs)}
	{mode display}
        {help_text "[_ curriculum-central.help_formal_contact_hrs]"}
    }
    {informal_study_hrs:text(textarea),optional
        {label "[_ curriculum-central.informal_study_hrs]"}
	{html {cols 50 rows 4}}
	{value $uos_workload(informal_study_hrs)}
	{mode display}
        {help_text "[_ curriculum-central.help_informal_study_hrs]"}
    }
    {student_commitment:text(textarea),optional
        {label "[_ curriculum-central.student_commitment]"}
	{html {cols 50 rows 4}}
	{value $uos_workload(student_commitment)}
	{mode display}
        {help_text "[_ curriculum-central.help_student_commitment]"}
    }
    {expected_feedback:text(textarea),optional
        {label "[_ curriculum-central.expected_feedback]"}
	{html {cols 50 rows 4}}
	{value $uos_workload(expected_feedback)}
	{mode display}
        {help_text "[_ curriculum-central.help_expected_feedback]"}
    }
    {student_feedback:text(textarea),optional
        {label "[_ curriculum-central.student_feedback]"}
	{html {cols 50 rows 4}}
	{value $uos_workload(student_feedback)}
	{mode display}
        {help_text "[_ curriculum-central.help_student_feedback]"}
    }
}


# Add history section
template::form::section uos [_ curriculum-central.history]

# Add widgets for fields that the Unit Coordinator must enter data into.
ad_form -extend -name uos -form {
    {activity_log:richtext(richtext)
	{label "#curriculum-central.activity_log#"}
	{html {cols 50 rows 13}}
        {help_text "[_ curriculum-central.help_activity_log]"}
    }
    {return_url:text(hidden)
        {value $return_url}
    }
    {uos_id:key}
    {entry_id:integer(hidden),optional}
}


# Export filters
set filters [list]
foreach name [curriculum_central::get_export_variables] {
    if { [info exists $name] } {
        lappend filters [list "${name}:text(hidden),optional" [list value [set $name]]]
    }
}
ad_form -extend -name uos -form $filters

# Set editable fields
if { $enabled_action_id ne "" } {
    foreach field [workflow::action::get_element -action_id $action_id -element edit_fields] {
	element set_properties uos $field -mode edit
    }
}


# on_submit block
ad_form -extend -name uos -on_submit {
    array set row [list]

    if { $enabled_action_id ne "" } {
        foreach field [workflow::action::get_element \
			   -action_id $action_id -element edit_fields] {
            set row($field) [element get_value uos $field]
        }
    }

    set activity_log [element get_value uos activity_log]

    # Retrieve some workflow information
    workflow::case::enabled_action_get \
	-enabled_action_id $enabled_action_id \
	-array enabled_action_info

    workflow::action::get \
	-action_id $enabled_action_info(action_id) \
	-array action_info

    # Do edits specific to a workflow action.
    # If action is edit_details, then update edit_details.
    if { $action_info(short_name) eq "edit_details" } {

	curriculum_central::uos::update_details \
	    -detail_id $detail_id \
	    -lecturer_id $lecturer_id \
	    -objectives $objectives \
	    -learning_outcomes $learning_outcomes \
	    -syllabus $syllabus \
	    -relevance $relevance \
	    -online_course_content $online_course_content

    } elseif { $action_info(short_name) eq "edit_tl"} {

	curriculum_central::uos::update_tl \
	    -tl_id $tl_id \
	    -tl_approach_ids $tl_approach_ids

	curriculum_central::uos::update_workload \
	    -workload_id $workload_id \
	    -formal_contact_hrs $formal_contact_hrs \
	    -informal_study_hrs $informal_study_hrs \
	    -student_commitment $student_commitment \
	    -expected_feedback $expected_feedback \
	    -student_feedback $student_feedback
    }

    # Do a general edit update.
    curriculum_central::uos::edit \
	-uos_id $uos(uos_id) \
	-enabled_action_id $enabled_action_id \
	-activity_log \
	    [template::util::richtext::get_property contents $activity_log] \
	-activity_log_format \
  	    [template::util::richtext::get_property format $activity_log] \
	-array row \
	-entry_id [element get_value uos entry_id]

    ad_returnredirect $return_url
    ad_script_abort

} -edit_request {
    # Dummy block.  Required for uos_id:key, otherwise ad_form complains.
}

# Not-valid block (request or submit error)
# Block that executes whenever the form is displayed, whether initially
# or because of a validation error.
if { ![form is_valid uos] } {
    # Get the UoS data
    curriculum_central::uos::get \
	-uos_id $uos_id \
	-array uos \
	-enabled_action_id $enabled_action_id

    # Hide elements that should be hidden depending on the workflow status
    foreach element $uos(hide_fields) {
        element set_properties uos $element -widget hidden
    }

    # Get values for the role assignment widgets
    workflow::case::role::set_assignee_values -case_id $case_id -form_name uos

    # Set values for description field
    element set_properties uos activity_log \
	-before_html [workflow::case::get_activity_html \
			  -case_id $case_id \
			  -action_id $action_id \
			  -max_n_actions [parameter::get \
			       -parameter LastNumActivityLogEntries \
			       -default 3]]
}
