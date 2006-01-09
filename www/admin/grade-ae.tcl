ad_page_contract {
    Add/Edit a grade type.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-08
    @cvs-id $Id$
} {
    type_id:integer,optional
    {return_url "grades"}
}

if { [info exists type_id] } {
    set page_title [_ curriculum-central.edit_grade_type]
} else {
    set page_title [_ curriculum-central.add_grade_type]
}

set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -name grade -cancel_url $return_url -form {
    {type_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 50}}
	{label "#curriculum-central.name#" }
	{help_text "[_ curriculum-central.help_enter_name_of_grade_type]"}
    }
    {lower_bound:integer
	{html {size 3}}
	{label "#curriculum-central.lower_bound#" }
	{help_text "[_ curriculum-central.help_enter_lower_bound]"}
    }
    {upper_bound:integer
	{html {size 3}}
	{label "#curriculum-central.upper_bound#" }
	{help_text "[_ curriculum-central.help_enter_upper_bound]"}
    }
} -select_query {
       SELECT name, lower_bound, upper_bound
	   FROM cc_uos_grade_type
           WHERE type_id = :type_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_grade_type] \
		        [list type_id $type_id] \
		        [list name $name] \
		        [list lower_bound $lower_bound] \
		        [list upper_bound $upper_bound]] \
	-form_id grade cc_uos_grade_type

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml grade_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
