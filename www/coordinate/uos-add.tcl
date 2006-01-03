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

# User needs to be logged in here
auth::require_login
set user_id [ad_conn user_id]

# Only stream coordinators can create a unit of study.
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_may_create_uos] index
}

# Set some common variables
set package_id [ad_conn package_id]
set package_key [ad_conn package_key]
set workflow_id [curriculum_central::uos::get_instance_workflow_id]

set page_title "[_ curriculum-central.add_unit_of_study]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]

# Create the form.
# TODO: Fix up form.  Can use drop-down boxes for some of the fields.
ad_form -name uos -cancel_url $return_url -form {
    {uos_id:key(acs_object_id_seq)}

    {uos_code:text
	{label "#curriculum-central.uos_code#"}
	{html {size 50}}
    }
    {uos_name:text
	{label "#curriculum-central.uos_name#"}
	{html {size 50}}
    }
    {credit_value:integer
	{label "#curriculum-central.credit_value#"}
	{html {size 50}}	
    }
    {semester:integer
	{label "#curriculum-central.semester_offering#"}
	{html {size 50}}
    }
    {unit_coordinator_id:integer(select)
	{label "#curriculum-central.unit_coordinator#"}
	{options [curriculum_central::staff_get_options] }
        {help_text "[_ curriculum-central.help_select_unit_coordinator]"}
    }
    {activity_log:richtext(richtext)
	{label "#curriculum-central.activity_log#"}
	{html {cols 50 rows 13}}
    }
    {return_url:text(hidden)
	{value $return_url}
    }
} -new_data {

    # Instantiate a new Unit of Study.
    curriculum_central::uos::new \
	-uos_id $uos_id \
	-package_id $package_id \
	-user_id $user_id \
	-uos_code $uos_code \
	-uos_name $uos_name \
	-credit_value $credit_value \
	-semester $semester \
	-unit_coordinator_id $unit_coordinator_id \
	-activity_log [template::util::richtext::get_property contents $activity_log] \
	-activity_log_format [template::util::richtext::get_property format $activity_log]

} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template
