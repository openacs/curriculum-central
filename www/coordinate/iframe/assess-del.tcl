ad_page_contract {
    Deletes an assessment method.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    method_id:integer
    uos_id:integer
    {return_url "[export_vars -url -base assess-view {uos_id {edit_p 1}}]"}
}

set package_id [ad_conn package_id]

db_transaction {
    db_dml am_map_update {}
    db_exec_plsql am_delete {}
}

ad_returnredirect $return_url
ad_script_abort
