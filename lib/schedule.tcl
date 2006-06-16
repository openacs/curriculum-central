ad_page_contract {

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
}

set package_id [ad_conn package_id]

# Get live Schedule revision ID.
set live_revision_id ""
db_0or1row live_schedule {}
db_multirow -extend { content_label assess_label assessments } schedule get_schedule {} {
    set content_label "[curriculum_central::uos::get_schedule_pretty_name -week_id $week_id] [_ curriculum-central.course_content]"

    set course_content [template::util::richtext::get_property \
			    html_value $course_content]

    set assess_label "[curriculum_central::uos::get_schedule_pretty_name -week_id $week_id] [_ curriculum-central.assessment]"

    set assess_list [list]
    if { $assessment_ids != 0} {
	foreach assess_id $assessment_ids {
	    lappend assess_list [db_string assess_name {} -default ""]
	}
    }
    set assessments [join $assess_list ,]
}

ad_return_template
