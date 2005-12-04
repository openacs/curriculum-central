ad_page_contract {
    Page for displaying a list of staff members for each faculty.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
}

set page_title "[_ curriculum-central.staff]"
set context [list [_ curriculum-central.staff]]

# Check if any faculties have been created, otherwise redirect if there
# are none.
if { ![curriculum_central::faculty::faculties_exist_p] } {
    ad_return_template "no-faculties"
    return
}

db_multirow staff staff {}

ad_return_template
