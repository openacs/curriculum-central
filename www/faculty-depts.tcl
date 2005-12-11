ad_page_contract {
    

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    faculty_id
    faculty_name
}

set page_title $faculty_name
set context [list $page_title]
set package_id [ad_conn package_id]

# Check for streams.  If no streams, then display no-streams template.
if { ![curriculum_central::stream::streams_exist_p] } {
    ad_return_template "no-streams"
    return
}

# Get list of departments.
db_multirow -extend {dept_streams_url} depts depts {} {
    set dept_streams_url [export_vars -url -base dept-streams \
			     {department_id department_name}]
}

ad_return_template
