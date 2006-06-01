ad_page_contract {
    Add/Edit a teaching and learning method for a specific UoS.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    uos_id:integer
    method_id:integer,optional
    {return_url "[export_vars -url -base tl-methods-view {uos_id {edit_p 1}}]"}
}

auth::require_login

if { [info exists method_id] } {
    set page_title [_ curriculum-central.edit_tl_method]
} else {
    set page_title [_ curriculum-central.add_tl_method]
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set uos_code [db_string uos_code {} -default ""]

ad_form -name tl_method -cancel_url $return_url -form {
    {method_id:key(acs_object_id_seq)}
    {uos_id:text(hidden) {value $uos_id}}
    {return_url:text(hidden) {value $return_url}}
    {identifier:text(hidden) {value $uos_code}}
    {name_id:integer(select)
	{options [curriculum_central::tl_names_get_options]}
	{label "[_ curriculum-central.name]" }
	{help_text "[_ curriculum-central.help_enter_type_of_tl_method]"}
    }
    {description:text(textarea)
	{html {cols 40 rows 10}}
	{label "[_ curriculum-central.description]" }
	{help_text "[_ curriculum-central.help_enter_description]"}
    }
} -select_query {
       SELECT name_id, identifier, description
	   FROM cc_uos_tl_method WHERE method_id = :method_id
} -new_data {

    db_transaction {
	set method_id [package_instantiate_object \
			   -var_list [list [list package_id $package_id] \
					  [list object_type cc_uos_tl_method] \
					  [list name_id $name_id] \
					  [list identifier $identifier] \
					  [list description $description]] \
			   -form_id tl_method cc_uos_tl_method]

	# Retrieve the latest TL version.
	db_1row latest_tl {}
	# Map the method_id to the latest TL version.
	db_exec_plsql map_tl_to_revision {}
    }

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml tl_method_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
