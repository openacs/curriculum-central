ad_page_contract {
    This has been deprecated in favour of iframe/tl-method-ae.

    Add/Edit a teaching and learning method.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    method_id:integer,optional
    {return_url "tl-methods"}
}

auth::require_login

if { [info exists method_id] } {
    set page_title [_ curriculum-central.edit_tl_method]
} else {
    set page_title [_ curriculum-central.add_tl_method]
}

set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

ad_form -name tl_method -cancel_url $return_url -form {
    {method_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 25}}
	{label "[_ curriculum-central.name]" }
	{help_text "[_ curriculum-central.help_enter_type_of_tl_method]"}
    }
    {identifier:text
	{html {size 25}}
	{label "[_ curriculum-central.identifier]" }
	{help_text "[_ curriculum-central.help_enter_identifier]"}
    }
    {description:text(textarea)
	{html {cols 40 rows 10}}
	{label "[_ curriculum-central.description]" }
	{help_text "[_ curriculum-central.help_enter_description]"}
    }
} -select_query {
       SELECT name, identifier, description
	   FROM cc_uos_tl_method WHERE method_id = :method_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_tl_method] \
		        [list name $name] \
		        [list identifier $identifier] \
		        [list description $description]] \
	-form_id tl_method cc_uos_tl_method

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml tl_method_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
