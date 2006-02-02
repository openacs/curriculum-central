ad_page_contract {
    Add/Edit a UoS name.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-04
    @cvs-id $Id$
} {
    name_id:integer,optional
    {return_url "uos-names"}
}

auth::require_login

if { [info exists name_id] } {
    set page_title [_ curriculum-central.edit_uos_name]
} else {
    set page_title [_ curriculum-central.add_uos_name]
}

set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

ad_form -name uos_name -cancel_url $return_url -form {
    {name_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {uos_code:text
	{html {size 50}}
	{label "[_ curriculum-central.uos_code]" }
	{help_text "[_ curriculum-central.help_enter_uos_code]"}
    }
    {uos_name:text
	{html {size 50}}
	{label "[_ curriculum-central.uos_name]" }
	{help_text "[_ curriculum-central.help_enter_uos_name]"}
    }
} -select_query {
       SELECT uos_code, uos_name
	   FROM cc_uos_name WHERE name_id = :name_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_name] \
		        [list uos_code $uos_code] \
		       [list uos_name $uos_name]] \
	-form_id uos_name cc_uos_name

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml uos_name_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
