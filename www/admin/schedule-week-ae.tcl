ad_page_contract {
    Add/Edit a schedule week.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-08
    @cvs-id $Id$
} {
    week_id:integer,optional
    {return_url "schedule"}
}

if { [info exists week_id] } {
    set page_title [_ curriculum-central.edit_schedule_week]
} else {
    set page_title [_ curriculum-central.add_schedule_week]
}

set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -name week -cancel_url $return_url -form {
    {week_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 50}}
	{label "#curriculum-central.name#" }
	{help_text "[_ curriculum-central.help_enter_name_of_schedule_week]"}
    }
} -select_query {
       SELECT name FROM cc_uos_schedule_week
           WHERE week_id = :week_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_schedule_week] \
		        [list week_id $week_id] \
		        [list name $name]] \
	-form_id week cc_uos_schedule_week

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml week_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
