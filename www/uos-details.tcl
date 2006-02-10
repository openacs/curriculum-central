ad_page_contract {
    Page for displaying details for a specific Unit of Study.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    uos_id:integer
    stream_id
}

set package_id [ad_conn package_id]

# Retrieve context details.
db_1row context_details {}

set page_title "${uos_code} ${uos_name}"

set context [list \
    [list [export_vars -url -base faculty-depts {faculty_name faculty_id}] \
        $faculty_name] \
    [list [export_vars -url -base dept-streams \
	{department_name department_id}] $department_name] \
    [list [export_vars -url -base stream-map \
	{stream_name stream_id}] "$stream_name - [_ curriculum-central.map_view]"] \
    $page_title]

# Retrieve Unit of Study details.
db_1row uos_details {}

set session_names [join [db_list session_names {}] ", "]

ad_return_template
