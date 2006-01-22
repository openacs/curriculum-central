ad_page_contract {
    Add/Edit a year.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    year_id:integer,optional
    {return_url "years"}
}

if { [info exists year_id] } {
    set page_title [_ curriculum-central.edit_year]
} else {
    set page_title [_ curriculum-central.add_year]
}

set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

ad_form -name year -cancel_url $return_url -form {
    {year_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 50}}
	{label "#curriculum-central.name#" }
	{help_text "[_ curriculum-central.help_enter_year_name]"}
    }
} -select_query {
       SELECT name FROM cc_year WHERE year_id = :year_id
} -new_data {

    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list name $name]] \
	-form_id year cc_year

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml year_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
