ad_page_contract {
    Add/Edit a staff member.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    staff_id:integer,optional
    {return_url "staff"}
}

if { [info exists staff_id] } {
    # Edit mode.
    set page_title [_ curriculum-central.edit_staff_details]

    # Create form with user's name.
    ad_form -name staff -cancel_url $return_url -form {
	{staff_id:key,integer(hidden) {value $staff_id} }
	{staff_name:string(inform)
	    {label "#curriculum-central.staff_name#"}
	    {value "[person::name -person_id $staff_id]" }
	}
    }
} else {
    # Add mode.
    set page_title [_ curriculum-central.add_staff_details]

    # Create form with drop-down list of users.
    ad_form -name staff -cancel_url $return_url -form {
	{staff_id:key,integer(select)
	    {label "#curriculum-central.staff_name#" }
	    {options [curriculum_central::users_get_options] }
	    {help_text "[_ curriculum-central.help_select_staff_member]"}
	}
    }

}

set context [list $page_title]
set package_id [ad_conn package_id]


ad_form -extend -name staff -form {
    {return_url:text(hidden) {value $return_url}}
    {title:text
	{html {size 50}}
	{label "#curriculum-central.staff_title#" }
	{help_text "[_ curriculum-central.help_enter_staff_title]"}
    }
    {position:text
	{html {size 50}}
	{label "#curriculum-central.staff_position#" }
	{help_text "[_ curriculum-central.help_enter_staff_position]"}
    }
    {department_id:integer(select)
	{label "#curriculum-central.department#" }
	{options [curriculum_central::departments_get_options] }
	{help_text "[_ curriculum-central.help_select_staff_member_department]"}
    }
} -select_query {
       SELECT title, position, department_id
	   FROM cc_staff WHERE staff_id = :staff_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list staff_id $staff_id] \
		        [list title $title] \
		        [list position $position] \
		        [list department_id $department_id]] \
	-form_id staff cc_staff
} -edit_data {
    db_dml staff_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
