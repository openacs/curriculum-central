ad_page_contract {
    Add/Edit a stream.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    stream_id:integer,optional
    {return_url "streams"}
}

if { [info exists stream_id] } {
    set page_title [_ curriculum-central.edit_stream]
} else {
    set page_title [_ curriculum-central.add_stream]
}

set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -name stream -cancel_url $return_url -form {
    {stream_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {stream_name:text
	{html {size 50}}
	{label "#curriculum-central.stream_name#" }
    }
    {stream_code:text
	{html {size 25}}
	{label "#curriculum-central.stream_code#" }
    }
    {department_id:integer(select)
	{label "#curriculum-central.department#" }
	{options [curriculum_central::departments_get_options] }
    }
    {coordinator_id:integer(select)
	{label "#curriculum-central.stream_coordinator#" }
	{options [curriculum_central::users_get_options] }
    }
} -select_query {
       SELECT coordinator_id, stream_name, stream_code,
           department_id
	   FROM cc_stream WHERE stream_id = :stream_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list object_type cc_stream] \
		        [list coordinator_id $coordinator_id]] \
	-form_id stream cc_stream

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml stream_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
