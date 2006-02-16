ad_page_contract {
    Add/Edit a stream to UoS relation.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    stream_uos_rel_id:integer,optional
    {return_url "stream-rels"}
}

if { [info exists stream_uos_rel_id] } {
    set page_title [_ curriculum-central.edit_stream_uos_rel]
} else {
    set page_title [_ curriculum-central.add_stream_uos_rel]
}

set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]

ad_form -name stream_rel -cancel_url $return_url -form {
    {stream_uos_rel_id:key(acs_object_id_seq)}
    {return_url:text(hidden) {value $return_url}}
    {name:text
	{html {size 50}}
	{label "#curriculum-central.name#" }
	{help_text "[_ curriculum-central.help_enter_stream_rel_name]"}
    }
} -select_query {
    SELECT name FROM cc_stream_uos_rel
        WHERE stream_uos_rel_id = :stream_uos_rel_id
} -new_data {

    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		        [list name $name]] \
	-form_id stream_rel cc_stream_uos_rel

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml rel_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
