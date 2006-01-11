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

# Registration required for all actions
auth::require_login

set return_url [export_vars -base [ad_conn url] [curriculum_central::get_export_variables {uos_id} ]]

set case_id [workflow::case::get_id \
		-object_id $uos_id \
		 -workflow_short_name \
		 [curriculum_central::uos::workflow_short_name]]

set workflow_id [curriculum_central::uos::get_instance_workflow_id]

# Action
set enabled_action_id [form get_action uos]
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

# Add UoS Details Section
template::form::section uos [_ curriculum-central.uos_details]

ad_form -extend -name uos -form {
    {uos_code:text
	{label "[_ curriculum-central.uos_code]"}
	{value $uos(uos_code)}
        {html {size 50}}
	{mode display}
    }
    {uos_name:text
	{label "[_ curriculum-central.uos_name]"}
	{value $uos(uos_name)}
        {html {size 50}}
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
    {credit_value:integer
	{label "[_ curriculum-central.credit_value]"}
	{value $uos(credit_value)}
        {html {size 3}}
	{mode display}
    }
    {semester:integer
	{label "[_ curriculum-central.semester_offering]"}
	{value $uos(semester)}
        {html {size 3}}
	{mode display}
    }
}


# Add teaching and learning section.
template::form::section uos [_ curriculum-central.tl_arrangements_and_requirements]

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
        {help_text "[_ curriculum-central.help_tl_approach_ids]"}
    }
}


# Retrieve graduate attribute info for Unit of Study.
curriculum_central::uos::get_graduate_attributes \
    -uos_id $uos_id \
    -array uos_gradattr

# Add widgets for Graduate Attributes
ad_form -extend -name uos -form {
    {gradattr_set_id:integer(hidden),optional
	{value $uos_gradattr(gradattr_set_id)}
    }
    {gradattr_ids:text(multiselect),multiple,optional
	{label "[_ curriculum-central.graduate_attributes]"}
	{options [curriculum_central::uos::graduate_attributes_get_options]}
	{html {size 5}}
	{values $uos_gradattr(gradattr_ids)}
	{mode display}
        {help_text "[_ curriculum-central.help_graduate_attributes]"}
    }
}


# Retrieve textbook info for Unit of Study.
curriculum_central::uos::get_textbooks \
    -uos_id $uos_id \
    -array uos_textbook

# Add widgets for textbook
ad_form -extend -name uos -form {
    {textbook_set_id:integer(hidden),optional
	{value $uos_textbook(textbook_set_id)}
    }
    {textbook_ids:text(multiselect),multiple,optional
	{label "[_ curriculum-central.textbooks]"}
	{options [curriculum_central::uos::textbook_get_options]}
	{html {size 5}}
	{values $uos_textbook(textbook_ids)}
	{mode display}
        {help_text "[_ curriculum-central.help_select_textbook_ids]"}
    }
}


# Retrieve workload info for Unit of Study.
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
    {assumed_concepts:text(textarea),optional
        {label "[_ curriculum-central.assumed_concepts]"}
	{html {cols 50 rows 4}}
	{value $uos_workload(assumed_concepts)}
	{mode display}
        {help_text "[_ curriculum-central.help_assumed_concepts]"}
    }
}


# Add assessment and section.
template::form::section uos [_ curriculum-central.assessment]

# Retrieve assessment info for Unit of Study.
curriculum_central::uos::get_assessment \
    -uos_id $uos_id \
    -array uos_assess

# Add widgets for Assessment
ad_form -extend -name uos -form {
    {assess_id:integer(hidden),optional
	{value $uos_assess(assess_id)}
    }
    {assess_method_ids:text(multiselect),multiple,optional
	{label "[_ curriculum-central.assessment_methods]"}
	{options [curriculum_central::uos::assess_method_get_options]}
	{html {size 5}}
	{values $uos_assess(assess_method_ids)}
	{mode display}
        {help_text "[_ curriculum-central.help_assess_method_ids]"}
    }
    {assess_total:text(inform)
	{label "[_ curriculum-central.current_assessment_total]"}
	{value "[curriculum_central::uos::get_assessment_total -assess_id $uos_assess(assess_id)]%"}
	{mode display}
    }
}


# Add the grade descriptor widgets.
curriculum_central::uos::add_grade_descriptor_widgets \
    -uos_id $uos_id \
    -form_name uos


# Add the schedule section and widgets.
curriculum_central::uos::add_schedule_widgets \
    -uos_id $uos_id \
    -form_name uos \
    -section_name [_ curriculum-central.schedule]


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

    # Retrieve some workflow information
    workflow::case::enabled_action_get \
	-enabled_action_id $enabled_action_id \
	-array enabled_action_info

    workflow::action::get \
	-action_id $enabled_action_info(action_id) \
	-array action_info

    # If the current action is edit_assessment, then set the
    # grade descriptor fields as editable.
    if { $action_info(short_name) eq "edit_assessment"} {
	foreach gd_field [curriculum_central::uos::get_grade_descriptor_fields] {
	    # Get the field name from the list of lists.
	    # type_id is the first item, and field_id is the second item.
	    # We are only interested in the second item.
	    set gd_field_name [lindex $gd_field 1]

	    element set_properties uos $gd_field_name -mode edit
	}
    }

    # If the current action is edit_schedule, then set the
    # schedule fields as editable.
    if { $action_info(short_name) eq "edit_schedule"} {
	foreach schedule_field [curriculum_central::uos::get_schedule_fields] {
	    # Get the field name from the list of lists.
	    # week_id is the first item, content field ID is the second item,
	    # and assessment field ID is the third item.
	    # We are only interested in the second item.
	    set schedule_content_field [lindex $schedule_field 1]
	    element set_properties uos $schedule_content_field -mode edit

	    set schedule_assessment_field [lindex $schedule_field 2]
	    element set_properties uos $schedule_assessment_field -mode edit
	}
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
    if { $action_info(short_name) eq "edit_tl"} {

	curriculum_central::uos::update_details \
	    -detail_id $detail_id \
	    -lecturer_id $lecturer_id \
	    -objectives $objectives \
	    -learning_outcomes $learning_outcomes \
	    -syllabus $syllabus \
	    -relevance $relevance \
	    -online_course_content $online_course_content

	curriculum_central::uos::update_tl \
	    -tl_id $tl_id \
	    -tl_approach_ids $tl_approach_ids

	curriculum_central::uos::update_textbooks \
	    -textbook_set_id $textbook_set_id \
	    -textbook_ids $textbook_ids

	curriculum_central::uos::update_graduate_attributes \
	    -gradattr_set_id $gradattr_set_id \
	    -gradattr_ids $gradattr_ids

	curriculum_central::uos::update_workload \
	    -workload_id $workload_id \
	    -formal_contact_hrs $formal_contact_hrs \
	    -informal_study_hrs $informal_study_hrs \
	    -student_commitment $student_commitment \
	    -expected_feedback $expected_feedback \
	    -student_feedback $student_feedback \
	    -assumed_concepts $assumed_concepts

    } elseif { $action_info(short_name) eq "edit_assessment" } {
	
	curriculum_central::uos::update_assess \
	    -assess_id $assess_id \
	    -assess_method_ids $assess_method_ids


	# For Grade Descriptor fields
	set grade_descriptors [list]

	if { $enabled_action_id ne "" } {
	    # Get the grade descriptors, and the information
	    # added for each one.
	    foreach descriptor_field \
		[curriculum_central::uos::get_grade_descriptor_fields] {
		    set type_id [lindex $descriptor_field 0]
		    set field_id [lindex $descriptor_field 1]
		    
		    # Append grade_type_id followed by the description.
		    lappend grade_descriptors \
			[list $type_id [element get_value uos $field_id]]
		}
	}

	curriculum_central::uos::update_grade_descriptors \
	    -grade_set_id $grade_set_id \
	    -grade_descriptors $grade_descriptors

    } elseif { $action_info(short_name) eq "edit_schedule" } {

	# For schedule fields
	set schedule_fields [list]

	if { $enabled_action_id ne "" } {
	    # Get the schedule fields, and the information
	    # added for each one.
	    foreach schedule_field \
		[curriculum_central::uos::get_schedule_fields] {
		    set week_id [lindex $schedule_field 0]
		    set content_field [lindex $schedule_field 1]
		    set assessment_field [lindex $schedule_field 2]

		    # Append week_id, content field and assessment field data.
		    lappend schedule_fields \
			[list $week_id [element get_value uos $content_field] \
			     [element get_values uos $assessment_field]]
		}
	}

	curriculum_central::uos::update_schedule \
	    -schedule_set_id $schedule_set_id \
	    -schedule_fields $schedule_fields
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
