ad_page_contract {
    Add/Edit a graduate attribute

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-04
    @cvs-id $Id$
} {
    gradattr_id:integer,optional
    {return_url "gradattrs"}
}

auth::require_login

if { [info exists gradattr_id] } {
    set page_title [_ curriculum-central.edit_graduate_attribute]
} else {
    set page_title [_ curriculum-central.add_graduate_attribute]
}

set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

ad_form -name gradattr -cancel_url $return_url -form {
    {gradattr_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name_id:integer(select)
	{options [curriculum_central::graduate_attribute_names_get_options] }
	{label "[_ curriculum-central.name]" }
	{help_text "[_ curriculum-central.help_enter_graduate_attribute_name]"}
    }
    {identifier:text
	{html {size 25}}
	{label "[_ curriculum-central.identifier]" }
	{help_text "[_ curriculum-central.help_enter_graduate_attribute_identifier]"}
    }
    {description:text(textarea)
	{html {cols 40 rows 10}}
	{label "[_ curriculum-central.description]" }
	{help_text "[_ curriculum-central.help_enter_graduate_attribute_description]"}
    }
    {level:integer(radio)
	{label "[_ curriculum-central.level]" }
	{help_text "[_ curriculum-central.help_enter_graduate_attribute_level]"}
	{options 
	    {{"[_ curriculum-central.very_low]" 1}
	     {"[_ curriculum-central.low]" 2}
	     {"[_ curriculum-central.moderate]" 3}
	     {"[_ curriculum-central.high]" 4}
	     {"[_ curriculum-central.very_high]" 5}}
	}
    }
} -select_query {
       SELECT name_id, identifier, description, level
	   FROM cc_uos_gradattr WHERE gradattr_id = :gradattr_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_gradattr] \
		        [list name_id $name_id] \
		        [list identifier $identifier] \
		        [list description $description] \
		        [list level $level]] \
	-form_id gradattr cc_uos_gradattr

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml gradattr_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
