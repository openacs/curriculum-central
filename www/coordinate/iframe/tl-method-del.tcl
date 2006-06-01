ad_page_contract {
    Deletes a Teaching and Learning method.

    @param method_id The ID of the Teaching and Learning method to remove.
    @param return_url Optional url to redirect to when the delete operation
    is complete.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-12-04
    @cvs-id $Id$
} {
    method_id:integer
    uos_id:integer
    {return_url "[export_vars -url -base tl-methods-view {uos_id {edit_p 1}}]"}
}

set package_id [ad_conn package_id]

db_transaction {
    db_dml tl_method_map_update {}
    db_exec_plsql tl_method_delete {}
}

ad_returnredirect $return_url
ad_script_abort
