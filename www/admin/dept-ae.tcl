ad_page_contract {
    Add/Edit a department.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    faculty_id:integer
    department_id:integer,optional
    return_url:optional
}

if { [info exists department_id] } {
    set page_title [_ curriculum-central.edit_dept]
} else {
    set page_title [_ curriculum-central.add_dept]
}

if { ![info exists return_url] } {
    set return_url [export_vars -base faculty-depts {faculty_id}]
}

set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -name dept -cancel_url $return_url -form {
    {department_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {faculty_id:integer(hidden) {value $faculty_id}}
    {department_name:text
	{html {size 50}}
	{label "#curriculum-central.dept_name#" }
    }
    {hod_id:integer(select)
	{label "#curriculum-central.hod#" }
	{options [curriculum_central::users_get_options] }
    }
} -select_query {
       SELECT hod_id, department_name
	   FROM cc_department WHERE department_id = :department_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_department] \
		        [list hod_id $hod_id] \
		        [list faculty_id $faculty_id]] \
	-form_id dept cc_department
} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml dept_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
