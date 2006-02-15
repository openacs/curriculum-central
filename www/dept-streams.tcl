ad_page_contract {
    

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    department_id:integer
    department_name
}

# Retrieve info about the faculty that the department belongs to for
# contextual navigation.
db_1row context_faculty {}

set page_title $department_name
set context [list [list [export_vars -url -base faculty-depts \
			     {faculty_id faculty_name}] $faculty_name] \
		 $page_title]
set package_id [ad_conn package_id]

# Check for streams.  If no streams, then display no-streams template.
if { ![curriculum_central::stream::streams_exist_p] } {
    ad_return_template "no-streams"
    return
}

set all_uos_view_url [export_vars -url -base all-uos-view {department_id}]

# Get list of streams.
db_multirow -extend {
    stream_map_url
    stream_view_url
} streams streams {} {
    set stream_map_url [export_vars -url -base stream-map {stream_id}]

    set stream_view_url [export_vars -url -base stream-view \
			     {stream_id}]
}

ad_return_template
