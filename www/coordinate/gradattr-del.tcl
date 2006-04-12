ad_page_contract {
    Delete a Graduate Attribtue.

    @param method_id The ID of the GA that needs to be removed.
    @param return_url Optional url to redirect to when the delete operation
    is complete.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-12-04
    @cvs-id $Id$
} {
    gradattr_id:integer
    return_url:optional
}

if { ![info exists return_url] } {
    set return_url "gradattrs"
}

set package_id [ad_conn package_id]

db_transaction {
    db_dml gradattr_map_update {}
    db_exec_plsql gradattr_delete {}
}

ad_returnredirect $return_url
ad_script_abort
