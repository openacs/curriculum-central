ad_page_contract {
    Displays the UoS map for the specified stream ID.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    stream_id:integer
    requisites_id:integer,optional
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

set selected_uos_id ""
if { [info exists requisites_id] } {
    set selected_uos_id $requisites_id

    # Query for UoS requisites for the selected UoS.
    db_1row requisites {}
}

template::multirow create stream map_id year_id year_name \
    session_id session_name core_or_not uos_id uos_code uos_name \
    year_session_group uos_details_url uos_requisites_url float_class

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
    set uos_name_id [lindex $uos 9]

    foreach session_id $session_ids {

	# Get name of session_id
	set session_name [db_string session_name {} -default ""]
    
	set year_session_group "${year_id}${session_id}"

	set base_return_url "stream-map"
	set uos_details_url [export_vars -url -base uos-details {uos_id stream_id base_return_url department_id}]

	# Determine style of requisites for the selected UoS, if one was
	# selected.
	set float_class "float"
	if { $selected_uos_id ne "" } {
	    if { $selected_uos_id == $uos_id} {
		set float_class "float selected"
	    } elseif { [lsearch -exact $prerequisite_ids $uos_name_id] != -1 } {
		set float_class "float prerequisite"
	    } elseif { [lsearch -exact $assumed_knowledge_ids $uos_name_id] != -1 } {
		set float_class "float assumed-knowledge"
	    } elseif { [lsearch -exact $corequisite_ids $uos_name_id] != -1 } {
		set float_class "float corequisite"
	    } elseif { [lsearch -exact $prohibition_ids $uos_name_id] != -1 } {
		set float_class "float prohibition"
	    } elseif { [lsearch -exact $no_longer_offered_ids $uos_name_id] != -1 } {
		set float_class "float no-longer-offered"
	    }
	}

	set requisites_id $uos_id
	set uos_requisites_url [export_vars -url -base stream-map {requisites_id department_id stream_id}]

	template::multirow append stream $map_id $year_id $year_name \
	    $session_id $session_name $core_id $uos_id $uos_code $uos_name \
	    $year_session_group $uos_details_url $uos_requisites_url \
	    $float_class
    
    }
}

# Sort stream info by increasing year and session.
template::multirow sort stream -increasing year_id session_id uos_code

ad_return_template
