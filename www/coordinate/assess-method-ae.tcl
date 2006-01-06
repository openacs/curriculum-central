ad_page_contract {
    Add/Edit an assessment method.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-04
    @cvs-id $Id$
} {
    method_id:integer,optional
    {return_url "assess-methods"}
}

auth::require_login

if { [info exists method_id] } {
    set page_title [_ curriculum-central.edit_assess_method]
} else {
    set page_title [_ curriculum-central.add_assess_method]
}

set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -name assess_method -cancel_url $return_url -form {
    {method_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 25}}
	{label "[_ curriculum-central.name]" }
	{help_text "[_ curriculum-central.help_enter_type_of_assess_method]"}
    }
    {identifier:text
	{html {size 25}}
	{label "[_ curriculum-central.identifier]" }
	{help_text "[_ curriculum-central.help_enter_assess_identifier]"}
    }
    {description:text(textarea)
	{html {cols 40 rows 10}}
	{label "[_ curriculum-central.description]" }
	{help_text "[_ curriculum-central.help_enter_assess_description]"}
    }
    {weighting:integer
	{html {size 3}}
	{label "[_ curriculum-central.weighting]" }
	{help_text "[_ curriculum-central.help_enter_assess_weighting]"}
    }
} -select_query {
       SELECT name, identifier, description, weighting
	   FROM cc_uos_assess_method WHERE method_id = :method_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_assess_method] \
		        [list name $name] \
		        [list identifier $identifier] \
		        [list description $description] \
  		        [list weighting $weighting]] \
	-form_id assess_method cc_uos_assess_method

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml assess_method_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
