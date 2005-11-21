ad_page_contract {
    Deletes a department and redirects back to listing of faculty
    departments.  Able to specify a return_url if the default is
    not suitable.

    @param faculty_id The ID of the faculty that the department belongs to.
    @param department_id The ID of the department to delete.
    @param return_url Optional url to redirect to when the delete operation
    is complete.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    faculty_id:integer
    department_id:integer
    return_url:optional
}

if { ![info exists return_url] } {
    set return_url [export_vars -base faculty-depts {faculty_id}]
}

set package_id [ad_conn package_id]

db_transaction {
    db_exec_plsql dept_delete {}
}

ad_returnredirect $return_url
ad_script_abort

