ad_page_contract {

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
}

set package_id [ad_conn package_id]

# Get live Textbooks revision ID.
set live_revision_id ""
db_0or1row live_textbooks {}
db_multirow textbooks get_textbooks {}

ad_return_template
