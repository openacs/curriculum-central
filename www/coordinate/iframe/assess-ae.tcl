ad_page_contract {
    Add/Edit an assessment method for a specific UoS.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer
    method_id:integer,optional
    {return_url "[export_vars -url -base assess-view {uos_id {edit_p 1}}]"}
}

auth::require_login

if { [info exists method_id] } {
    set page_title [_ curriculum-central.edit_assess_method]
} else {
    set page_title [_ curriculum-central.add_assess_method]
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set uos_code [db_string uos_code {} -default ""]

ad_form -name assess_method -cancel_url $return_url -form {
    {method_id:key(acs_object_id_seq)}
    {uos_id:text(hidden) {value $uos_id}}
    {return_url:text(hidden) {value $return_url}}
    {identifier:text(hidden) {value $uos_code}}
    {name:text
	{html {size 25}}
	{label "[_ curriculum-central.name]" }
	{help_text "[_ curriculum-central.help_enter_type_of_assess_method]"}
    }
    {weighting:integer
	{html {size 3}}
	{label "[_ curriculum-central.weighting]" }
	{help_text "[_ curriculum-central.help_enter_assess_weighting]"}
    }
    {description:text(textarea)
	{html {cols 40 rows 10}}
	{label "[_ curriculum-central.description]" }
	{help_text "[_ curriculum-central.help_enter_assess_description]"}
    }
} -select_query {
       SELECT name, weighting, description, identifier
	   FROM cc_uos_assess_method WHERE method_id = :method_id
} -new_data {

    db_transaction {
	set method_id [package_instantiate_object \
	    -var_list [list [list package_id $package_id] \
			   [list object_type cc_uos_assess_method] \
			   [list name $name] \
			   [list identifier $identifier] \
			   [list description $description] \
			   [list weighting $weighting]] \
	    -form_id assess_method cc_uos_assess_method]

	# Retrieve the latest assessment methods version.
	db_1row latest_am {}
	# Map the method_id to the latest assessment methods version.
	db_exec_plsql map_am_to_revision {}
    }

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml am_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
