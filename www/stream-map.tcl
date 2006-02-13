ad_page_contract {
    Displays the UoS map for the specified stream ID.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    stream_id:integer
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Retrieve info about the faculty, department and stream.
db_1row context {}

set page_title "$stream_name - [_ curriculum-central.map_view]"
set context [list \
    [list [export_vars -url -base faculty-depts {faculty_name faculty_id}] \
        $faculty_name] \
    [list [export_vars -url -base dept-streams \
	{department_name department_id}] $department_name] \
    $page_title]

# Retrieve a list of Units of Study.
set units_of_study [db_list_of_lists units_of_study {}]

template::multirow create stream map_id year_id year_name \
    session_id session_name core_or_not uos_id uos_code uos_name \
    year_session_group uos_details_url

foreach uos $units_of_study {
    set map_id [lindex $uos 0]
    set uos_code [lindex $uos 1]
    set uos_name [lindex $uos 2]
    set uos_id [lindex $uos 3]
    set year_id [lindex $uos 4]
    set year_name [lindex $uos 5]
    set core_id [lindex $uos 6]
    set live_revision_id [lindex $uos 7]
    set session_ids [lindex $uos 8]

    foreach session_id $session_ids {
	
	# Get name of session_id
	set session_name [db_string session_name {} -default ""]
    
	set year_session_group "${year_id}${session_id}"

	set base_return_url "stream-map"
	set uos_details_url [export_vars -url -base uos-details {uos_id stream_id base_return_url}]

	template::multirow append stream $map_id $year_id $year_name \
	    $session_id $session_name $core_id $uos_id $uos_code $uos_name \
	    $year_session_group $uos_details_url
    
    }
}

# Sort stream info by increasing year and session.
template::multirow sort stream -increasing year_id session_id

ad_return_template
