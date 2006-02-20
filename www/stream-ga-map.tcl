ad_page_contract {
    Displays the UoS map for the specified stream ID.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    stream_id:integer
    gradattr_id:integer,optional
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Retrieve info about the faculty, department and stream.
db_1row context {}

set page_title "$stream_name - [_ curriculum-central.graduate_attribute_map_view]"
set context [list \
    [list [export_vars -url -base faculty-depts {faculty_name faculty_id}] \
        $faculty_name] \
    [list [export_vars -url -base dept-streams \
	{department_name department_id}] $department_name] \
    $page_title]

set requisites_map_url [export_vars -url -base stream-map {stream_id}]

template::multirow create ga_names name name_id selected_p url
db_foreach ga_name {} {
    set selected_p 0
    if { [info exists gradattr_id] } {
	if { $gradattr_id == $name_id } {
	    set selected_p 1
	}
    }
    
    set url [export_vars -url -base stream-ga-map -override {{gradattr_id $name_id}} {stream_id gradattr_id}]

    template::multirow append ga_names $name $name_id $selected_p $url
}

# If gradattr_id doesn't exist, then use the first Graduate Attribute
# from the drop down list as the default value.
if { ![info exists gradattr_id] } {
    if { [template::multirow size ga_names] > 0 } {
	set gradattr_id [template::multirow get ga_names 1 name_id]
    }
}

# Retrieve a list of Units of Study.
set units_of_study [db_list_of_lists units_of_study {}]

template::multirow create stream map_id year_id year_name \
    session_id session_name core_or_not uos_id uos_code uos_name \
    year_session_group uos_details_url float_class

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
	if { [info exists gradattr_id] } {
	    if { [db_0or1row ga_level {}] } {
		if { $level == 5} {
		    set float_class "float ga-very-high"
		} elseif { $level == 4 } {
		    set float_class "float ga-high"
		} elseif { $level == 3 } {
		    set float_class "float ga-moderate"
		} elseif { $level == 2 } {
		    set float_class "float ga-low"
		} elseif { $level == 1 } {
		    set float_class "float ga-very-low"
		}
	    }
	}

	template::multirow append stream $map_id $year_id $year_name \
	    $session_id $session_name $core_id $uos_id $uos_code $uos_name \
	    $year_session_group $uos_details_url $float_class
    
    }
}

# Sort stream info by increasing year and session.
template::multirow sort stream -increasing year_id session_id uos_code

ad_return_template
