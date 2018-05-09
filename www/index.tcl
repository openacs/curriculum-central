ad_page_contract {
    Stream listing page.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

set page_title [ad_conn instance_name]
set context [list]
set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# Check for streams.  If no streams, then display no-streams template.
if { ![curriculum_central::stream::streams_exist_p] } {
    ad_return_template "no-streams"
    return
}

# Get list of faculties.
db_multirow -extend {faculty_dept_url} faculties faculties {} {
    set faculty_dept_url [export_vars -url -base faculty-depts \
			      {faculty_id faculty_name}]
}

ad_return_template
