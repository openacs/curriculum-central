ad_page_contract {
    Displays a list of streams that the stream coordinator is responsible
    for.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    stream_id:integer
}

set stream_name [db_string stream_name {} -default ""]

set page_title "[_ curriculum-central.stream_overview]: $stream_name"
set context [list [list . [_ curriculum-central.coordinate]] \
		 [_ curriculum-central.stream_overview]]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Only stream coordinators can develop a stream.
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_can_develop_a_stream] index
}

set units_of_study [db_list_of_lists units_of_study {}]

template::multirow create stream map_id year_id year_name \
    semester_id semester_name core_or_not uos_id uos_code uos_name \
    group edit_url delete_url

# Set the modified state to 0 by default.  This means the stream
# overview has been published.  The state will be toggled below when
# we find a UoS mapping that has been modified.
set modified_p 0
set modified_list [list]

foreach uos $units_of_study {
    set map_id [lindex $uos 0]
    set uos_code [lindex $uos 1]
    set uos_name [lindex $uos 2]
    set uos_id [lindex $uos 3]
    set year_id [lindex $uos 4]
    set year_name [lindex $uos 5]
    set semester_ids [lindex $uos 6]
    set core_id [lindex $uos 7]
    set live_revision_id [lindex $uos 8]
    set latest_revision_id [lindex $uos 9]

    set core_or_not [curriculum_central::stream::stream_uos_relation_name \
			 -id $core_id]

    # If there is no live revision or that the live revision and
    # latest revision IDs are different, then set modified flag to 1.
    if { $live_revision_id eq "" || \
	     $live_revision_id ne $latest_revision_id } {
	set modified_p "1"
	lappend modified_list $map_id
    }

    foreach semester_id $semester_ids {
	# Get name for semester_id
	set semester_name [db_string semester_name {} -default ""]
	
	# Create a "derived column" called group that is the amalgamation
	# of the year_id and semester_id.  It is used as a workaround for
	# bug 428 (http://openacs.org/bugtracker/openacs/bug?bug%5fnumber=428),
	# when using the <group> tag in the template.
	set group "$year_id$semester_id"

	set return_url [export_vars -base stream-view {stream_id}]
	set edit_url [export_vars -base stream-map-ae \
			  {stream_id uos_id map_id return_url}]
	set delete_url [export_vars -base stream-map-del \
			    {stream_id map_id return_url}]

	template::multirow append stream $map_id $year_id $year_name \
	    $semester_id $semester_name $core_or_not $uos_id $uos_code \
	    $uos_name $group $edit_url $delete_url
    }
}

set publish_url [export_vars -base stream-publish {stream_id modified_list}]

# Sort stream info by increasing year and semester.
template::multirow sort stream -increasing year_id semester_id

# Get all UoS that are no longer offered.  These are UoS that were
# previously mapped, but now have a year_id that is set to 0.
db_multirow -extend {edit_url} not_offered not_offered {} {
    set return_url [export_vars -base stream-view {stream_id}]
    set edit_url [export_vars -base stream-map-ae {stream_id uos_id map_id return_url}]
}

ad_return_template
