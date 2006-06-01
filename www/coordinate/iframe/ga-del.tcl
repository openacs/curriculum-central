ad_page_contract {
    Deletes a Graduate Attribute.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    gradattr_id:integer
    uos_id:integer
    {return_url "[export_vars -url -base ga-view {uos_id {edit_p 1}}]"}
}

set package_id [ad_conn package_id]

db_transaction {
    db_dml ga_map_update {}
    db_exec_plsql ga_delete {}
}

ad_returnredirect $return_url
ad_script_abort
