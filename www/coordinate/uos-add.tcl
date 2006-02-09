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

set requisite_uos_options \
    [curriculum_central::stream::all_uos_names_get_options]


# Create the form.
ad_form -name uos -cancel_url $return_url -form {
    {uos_id:key(acs_object_id_seq)}

    {uos_name_id:integer(select)
	{label "#curriculum-central.uos_name#"}
	{options [curriculum_central::uos::uos_available_name_get_options]}
	{help_text "[_ curriculum-central.help_select_uos_name]"}
    }
    {credit_value:integer
	{label "#curriculum-central.credit_value#"}
	{html {size 3}}
	{help_text "[_ curriculum-central.help_enter_credit_value]"}
    }
    {department_id:integer(select)
	{label "#curriculum-central.department#" }
	{options [curriculum_central::departments_get_options] }
	{help_text "[_ curriculum-central.help_select_a_dept]"}
    }
    {unit_coordinator_id:integer(select)
	{label "#curriculum-central.unit_coordinator#"}
	{options [curriculum_central::staff_get_options] }
        {help_text "[_ curriculum-central.help_select_unit_coordinator]"}
    }
    {session_ids:text(multiselect),multiple
	{label "[_ curriculum-central.sessions]"}
	{options "[curriculum_central::stream::sessions_get_options]"}
	{html {size 5}}
	{help_text "[_ curriculum-central.help_select_sessions_that_uos_is_offered]"}
    }
    {prerequisite_ids:text(multiselect),multiple
	{label "[_ curriculum-central.prerequisites]"}
	{options $requisite_uos_options}
	{html {size 5}}
	{help_text "[_ curriculum-central.help_select_prerequisites_for_uos]"}
    }
    {assumed_knowledge_ids:text(multiselect),multiple
	{label "[_ curriculum-central.assumed_knowledge]"}
	{options $requisite_uos_options}
	{html {size 5}}
	{help_text "[_ curriculum-central.help_select_assumed_knowledge_for_uos]"}
    }
    {corequisite_ids:text(multiselect),multiple
	{label "[_ curriculum-central.corequisites]"}
	{options $requisite_uos_options}
	{html {size 5}}
	{help_text "[_ curriculum-central.help_select_corequisites_for_uos]"}
    }
    {prohibition_ids:text(multiselect),multiple
	{label "[_ curriculum-central.prohibitions]"}
	{options $requisite_uos_options}
	{html {size 5}}
	{help_text "[_ curriculum-central.help_select_prohibitions_for_uos]"}
    }
    {no_longer_offered_ids:text(multiselect),multiple
	{label "[_ curriculum-central.no_longer_offered]"}
	{options $requisite_uos_options}
	{html {size 5}}
	{help_text "[_ curriculum-central.help_select_uos_no_longer_offered]"}
    }
    {activity_log:text(textarea)
	{label "#curriculum-central.activity_log#"}
	{html {cols 50 rows 4}}
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
	-activity_log $activity_log

} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template
