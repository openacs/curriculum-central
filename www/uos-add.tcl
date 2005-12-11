ad_page_contract {
    Add a new UoS.

    This page can only be accessed by a stream coordinator.  Stream
    coordinators are the only users that can initiate the workflow
    for creating Units of Study.  The stream coordinator creates the
    Unit of Study, and assigns it to a unit coordinator to fill in the
    unit outline.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {return_url ""}
}

if { [empty_string_p $return_url] } {
    set return_url "."
}

ad_require_permission [ad_conn package_id] create

# User needs to be logged in here
auth::require_login

# Set some common variables
set package_id [ad_conn package_id]
set package_key [ad_conn package_key]
set workflow_id [curriculum_central::uos::get_instance_workflow_id]
set user_id [ad_conn user_id]

set page_title "[_ curriculum-central.add_unit_of_study]"
set context [list $page_title]

# Create the form.
# TODO: Fix up form.  Can use drop-down boxes for some of the fields.
ad_form -name uos -cancel_url $return_url -form {
    {uos_id:key(acs_object_id_seq)}

    {uos_code:text
	{label "UoS Code"}
	{html {size 50}}
    }
    {uos_name:text
	{label "UoS Name"}
	{html {size 50}}
    }
    {credit_value:integer
	{label "Credit Value"}
	{html {size 50}}	
    }
    {semester:integer
	{label "Semester Offering"}
	{html {size 50}}
    }
    {online_course_content:text,optional
	{label "Online Course Content"}
	{html {size 50}}
    }
    {unit_coordinator_id:integer(select)
	{label "Unit Coordinator"}
	{options [curriculum_central::staff_get_options] }
        {help_text "[_ curriculum-central.help_select_unit_coordinator]"}
    }
    {contact_hours:text
	{label "Contact Hours"}
	{html {size 50}}
    }
    {assessments:text
	{label "Assessments"}
	{html {size 50}}
    }
    {core_uos_for:text,optional
	{label "Core UoS for"}
	{html {size 50}}
    }
    {recommended_uos_for:text,optional
	{label "Recommended UoS for"}
	{html {size 50}}
    }
    {prerequisites:text,optional
	{label "Prerequisites"}
	{html {size 50}}
    }
    {objectives:text
	{label "Aims and Objectives"}
	{html {size 50}}
    }
    {outcomes:text
	{label "Learning Outcomes"}
	{html {size 50}}
    }
    {syllabus:richtext(richtext)
	{label "Syllabus"}
	{html {cols 60 rows 13}}
    }
    {return_url:text(hidden)
	{value $return_url}
    }
} -new_data {
    # TODO: Implement this proc.
    curriculum_central::uos::new \
	-uos_id $uos_id \
	-package_id $package_id \
	-user_id $user_id \
	-uos_code $uos_code \
	-uos_name $uos_name \
	-credit_value $credit_value \
	-semester $semester \
	-online_course_content $online_course_content \
	-unit_coordinator_id $unit_coordinator_id \
	-contact_hours $contact_hours \
	-assessments $assessments \
	-core_uos_for $core_uos_for \
	-recommended_uos_for $recommended_uos_for \
	-prerequisites $prerequisites \
	-objectives $objectives \
	-outcomes $outcomes \
	-syllabus [template::util::richtext::get_property contents $syllabus] \
	-syllabus_format [template::util::richtext::get_property format $syllabus]

} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template
