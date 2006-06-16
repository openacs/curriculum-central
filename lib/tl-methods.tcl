ad_page_contract {

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    uos_id:integer
}

set package_id [ad_conn package_id]

# Get live TL revision ID.
set latest_revision_id ""
db_0or1row live_tl {}
db_multirow methods get_methods {}

ad_return_template
