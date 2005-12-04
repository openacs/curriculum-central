ad_page_contract {
    Page for displaying details for a specific staff member.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    staff_id:integer
}

# Set optional fields to the empty string by default.
set address {}
set phone {}
set fax {}
set homepage_url {}

db_1row staff_details {}

set page_title $name
set context [list [list staff [_ curriculum-central.staff]] $page_title]

ad_return_template