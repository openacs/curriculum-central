ad_page_contract {


    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
}

set package_id [ad_conn package_id]

# Get live GA revision ID.
set live_revision_id ""
db_0or1row live_ga {}
db_multirow methods get_attributes {} {
    set level \
	[curriculum_central::uos::get_graduate_attribute_level_name $level]
}

ad_return_template
