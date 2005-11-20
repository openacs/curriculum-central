ad_page_contract {
    Add/Edit a faculty.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    faculty_id:integer,optional
    {return_url "faculties"}
}

if { [info exists faculty_id] } {
    set page_title [_ curriculum-central.edit_faculty]
} else {
    set page_title [_ curriculum-central.add_faculty]
}

set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -name faculty -cancel_url $return_url -form {
    {faculty_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {faculty_name:text
	{html {size 50}}
	{label "#curriculum-central.faculty_name#" }
    }
    {dean_id:search
	{result_datatype integer}
	{label "#curriculum-central.dean#" }
	{options [curriculum_central::users_get_options] }
	{search_query {}}
    }
} -select_query {
       SELECT dean_id, faculty_name
	   FROM cc_faculty WHERE faculty_id = :faculty_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_faculty] \
		        [list dean_id $dean_id]] \
	-form_id faculty cc_faculty
} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml faculty_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
