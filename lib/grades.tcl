ad_page_contract {

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
}

set package_id [ad_conn package_id]

# Get live Grade Descritors revision ID.
set live_revision_id ""
db_0or1row live_grades {}
db_multirow -extend { label } grades get_grades {} {
    set label [curriculum_central::uos::get_grade_descriptor_pretty_name -type_id $type_id]

    set description [template::util::richtext::get_property \
			 html_value $description]
}

ad_return_template
