ad_page_contract {
    Add/Edit a semester.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    semester_id:integer,optional
    {return_url "semesters"}
}

if { [info exists semester_id] } {
    set page_title [_ curriculum-central.edit_semester]
} else {
    set page_title [_ curriculum-central.add_semester]
}

set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

ad_form -name semester -cancel_url $return_url -form {
    {semester_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 50}}
	{label "#curriculum-central.name#" }
	{help_text "[_ curriculum-central.help_enter_semester_name]"}
    }
    {start_date:date,to_sql(sql_date),to_html(display_date)
	{label "#curriculum-central.start_date#" }
	{help_text "[_ curriculum-central.help_enter_start_date]"}
	{format "[lc_get formbuilder_date_format]"}
    }
    {end_date:date,to_sql(sql_date),to_html(display_date)
	{label "#curriculum-central.end_date#"}
	{help_text "[_ curriculum-central.help_enter_end_date]"}
	{format "[lc_get formbuilder_date_format]"}
    }
} -select_query {
       SELECT name, start_date, end_date
	   FROM cc_semester WHERE semester_id = :semester_id
} -validate {
    {start_date
        { [template::util::date::compare $start_date $end_date] <= 0 }
        "#curriculum-central.start_date_must_be_set_before_end_date#"
    }
} -new_data {
ns_log Warning "NC: start_date: $start_date end_date $end_date"

    # Can't use package_instantiate_object because the underlying
    # db_exec_plsql can't know that the contents of the start_date and
    # end_date contain functions and not variables
    db_exec_plsql object_new {}

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml semester_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
