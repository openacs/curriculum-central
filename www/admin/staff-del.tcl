ad_page_contract {
    Deletes a user from the staff group and redirects back to listing of
    staff.  Able to specify a return_url if the default is not suitable.

    @param staff_id The ID of the user that needs to be removed from the
    staff list.
    @param return_url Optional url to redirect to when the delete operation
    is complete.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-12-04
    @cvs-id $Id$
} {
    staff_id:integer
    return_url:optional
}

if { ![info exists return_url] } {
    set return_url "staff"
}

set package_id [ad_conn package_id]

db_transaction {
    db_exec_plsql staff_delete {}
}

ad_returnredirect $return_url
ad_script_abort
