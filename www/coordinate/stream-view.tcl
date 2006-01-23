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

# Get stream years.
# Get semesters in a year.
# Get mapped revisions

set units_of_study [db_list_of_lists units_of_study {}]

template::multirow create stream map_id year_id year_name \
    semester_id semester_name uos_id uos_code uos_name

foreach uos $units_of_study {
    set map_id [lindex $uos 0]
    set uos_code [lindex $uos 1]
    set uos_name [lindex $uos 2]
    set uos_id [lindex $uos 3]
    set year_id [lindex $uos 4]
    set year_name [lindex $uos 5]
    set semester_ids [lindex $uos 6]

    foreach semester_id $semester_ids {
	# Get name for semester_id
	set semester_name [db_string semester_name {} -default ""]
	
	template::multirow append stream $map_id $year_id $year_name \
	    $semester_id $semester_name $uos_id $uos_code $uos_name
    }
}

# Sort stream info by increasing year and semester.
template::multirow sort stream -increasing year_id semester_id

ad_return_template
