ad_page_contract {
    Add/Edit a graduate attribute

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-04
    @cvs-id $Id$
} {
    name_id:integer,optional
    {return_url "gradattrs"}
}

auth::require_login

if { [info exists name_id] } {
    set page_title [_ curriculum-central.edit_graduate_attribute]
} else {
    set page_title [_ curriculum-central.add_graduate_attribute]
}

set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

ad_form -name gradattr -cancel_url $return_url -form {
    {name_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 25}}
	{label "[_ curriculum-central.name]" }
	{help_text "[_ curriculum-central.help_enter_graduate_attribute_name]"}
    }
    {general_description:richtext(richtext),optional
        {label "[_ curriculum-central.general_description]"}
	{html {cols 50 rows 4}}
	{htmlarea_p 0}
	{nospell}
        {help_text "[_ curriculum-central.help_enter_ga_general_description]"}
    }
} -select_query {
    SELECT name, general_description
    FROM cc_uos_gradattr_name WHERE name_id = :name_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_uos_gradattr_name] \
		        [list name $name] \
  		        [list general_description $general_description]] \
	-form_id gradattr cc_uos_gradattr_name

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml gradattr_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
