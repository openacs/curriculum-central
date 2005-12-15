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

set page_title "Edit UoS"
set context [list [list . "Coordinate"] "Edit UoS"]

set case_id [workflow::case::get_id \
		-object_id $uos_id \
		 -workflow_short_name \
		 [curriculum_central::uos::workflow_short_name]]

set workflow_id [curriculum_central::uos::get_instance_workflow_id]

# Action
set enabled_action_id [form get_action uos]

# Registration required for all actions
set action_id ""

if { ![empty_string_p $enabled_action_id] } {
    auth::require_login
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

# Retrieve infor for Unit of Study.
curriculum_central::uos::get \
    -uos_id $uos_id \
    -array uos \
    -enabled_action_id $enabled_action_id

# Create the form
# Create widgets for displaying UoS information that should already
# have been entered by the Stream Coordinator when the UoS was
# initially created.
ad_form -name uos -cancel_url $return_url -mode display -has_edit 1 -actions $actions -form {
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
    {core_uos_for:text(inform)
	{label "[_ curriculum-central.core_uos_for]"}
	{value $uos(core_uos_for)}
	{mode display}
    }
    {recommended_uos_for:text(inform)
	{label "[_ curriculum-central.recommended_uos_for]"}
	{value $uos(recommended_uos_for)}
	{mode display}
    }
    {prerequisites:text(inform)
	{label "[_ curriculum-central.prerequisites]"}
	{value $uos(prerequisites)}
	{mode display}
    }
}

# Add widgets for fields that the Unit Coordinator must enter data into.
ad_form -extend -name uos -form {
    {contact_hours:text
        {label "[_ curriculum-central.contact_hours]"}
        {html {size 50}}
	{mode display}
    }
    {assessments:text
        {label "[_ curriculum-central.assessments]"}
        {html {size 50}}
	{mode display}
    }
    {online_course_content:text,optional
        {label "[_ curriculum-central.online_course_content]"}
        {html {size 50}}
	{mode display}
    }
    {objectives:text
        {label "[_ curriculum-central.aims_and_objectives]"}
        {html {size 50}}
	{mode display}
    }
    {outcomes:text
        {label "[_ curriculum-central.learning_outcomes]"}
        {html {size 50}}
	{mode display}
    }
    {activity_log:richtext(richtext)
	{label "#curriculum-central.activity_log#"}
	{html {cols 50 rows 13}}
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

    if { ![empty_string_p $enabled_action_id] } {
        foreach field [workflow::action::get_element \
			   -action_id $action_id -element edit_fields] {
            set row($field) [element get_value uos $field]
        }
    }

    set activity_log [element get_value uos activity_log]

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

    # Hide elements that should be hidden depending on the bug status
    foreach element $uos(hide_fields) {
        element set_properties uos $element -widget hidden
    }

    # Get values for the role assignment widgets
    workflow::case::role::set_assignee_values -case_id $case_id -form_name uos

    # Set values for description field
    element set_properties uos activity_log \
	-before_html [workflow::case::get_activity_html -case_id $case_id \
			  -action_id $action_id]
}