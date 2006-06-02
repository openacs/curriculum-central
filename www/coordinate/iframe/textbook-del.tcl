ad_page_contract {
    Deletes a textbook.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    textbook_id:integer
    uos_id:integer
    {return_url "[export_vars -url -base textbooks-view {uos_id {edit_p 1}}]"}
}

set package_id [ad_conn package_id]

db_transaction {
    db_dml textbook_map_update {}
    db_exec_plsql textbook_delete {}
}

ad_returnredirect $return_url
ad_script_abort
