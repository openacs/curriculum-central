ad_page_contract {
    Page for displaying details for a specific Unit of Study.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    uos_id:integer
    stream_id:optional
    {base_return_url "stream-map"}
    department_id:integer
}

set package_id [ad_conn package_id]

if { $base_return_url eq "stream-view" || $base_return_url eq "all-uos-view" } {
    set return_view_type "[_ curriculum-central.overview]"
} elseif { $base_return_url eq "stream-ga-map" || $base_return_url eq "all-uos-ga-map"} {
    set return_view_type "[_ curriculum-central.graduate_attribute_map_view]"
} else {
    set return_view_type "[_ curriculum-central.map_view]"
}

if { [info exists stream_id] } {
    # Retrieve context details.
    db_1row context_details {}

    set page_title "${uos_code} ${uos_name}"

    set context [list \
		     [list [export_vars -url -base faculty-depts \
				{faculty_name faculty_id}] \
			  $faculty_name] \
		     [list [export_vars -url -base dept-streams \
				{department_name department_id}] \
			  $department_name] \
		     [list [export_vars -url -base $base_return_url \
				{stream_name stream_id}] \
			  "$stream_name - $return_view_type"] \
		     $page_title]
} else {
    db_1row context_details_no_stream {}

    set page_title "${uos_code} ${uos_name}"

    set context [list \
		     [list [export_vars -url -base faculty-depts \
				{faculty_name faculty_id}] \
			  $faculty_name] \
		     [list [export_vars -url -base dept-streams \
				{department_name department_id}] \
			  $department_name] \
		     [list [export_vars -url -base $base_return_url \
				{department_id}] \
			  "[_ curriculum-central.all_uos] - $return_view_type"] \
		     $page_title]
}

# Retrieve Unit of Study details.
db_1row uos_details {}

# Create a multirow containing all the UoS details.
template::multirow create details label value

template::multirow append details [_ curriculum-central.unit_coordinator] \
    $unit_coordinator_pretty_name

template::multirow append details [_ curriculum-central.lecturers] \
    "[curriculum_central::staff::pretty_names $lecturer_ids]"

template::multirow append details [_ curriculum-central.tutors] \
    "[curriculum_central::staff::pretty_names $tutor_ids]"

template::multirow append details [_ curriculum-central.credit_value] \
    $credit_value

template::multirow append details [_ curriculum-central.sessions] \
    [join [db_list session_names {}] ", "]

template::multirow append details \
    [_ curriculum-central.online_course_content] $online_course_content

template::multirow append details [_ curriculum-central.aims_and_objectives] \
    [template::util::richtext::get_property html_value $objectives]

template::multirow append details [_ curriculum-central.learning_outcomes] \
    [template::util::richtext::get_property html_value $learning_outcomes]

template::multirow append details [_ curriculum-central.syllabus] \
    [template::util::richtext::get_property html_value $syllabus]

template::multirow append details [_ curriculum-central.relevance] \
    [template::util::richtext::get_property html_value $relevance]

template::multirow append details [_ curriculum-central.contact_hours] \
    [template::util::richtext::get_property html_value $formal_contact_hrs]

template::multirow append details [_ curriculum-central.informal_study_hrs] \
    [template::util::richtext::get_property html_value $informal_study_hrs]

template::multirow append details [_ curriculum-central.student_commitment] \
    [template::util::richtext::get_property html_value $student_commitment]

template::multirow append details [_ curriculum-central.expected_feedback] \
    [template::util::richtext::get_property html_value $expected_feedback]

template::multirow append details [_ curriculum-central.student_feedback] \
    [template::util::richtext::get_property html_value $student_feedback]

template::multirow append details [_ curriculum-central.assumed_concepts] \
    [template::util::richtext::get_property html_value $assumed_concepts]

template::multirow append details [_ curriculum-central.assessments] \
    [join [db_list assessment_names {}] ", "]

template::multirow append details [_ curriculum-central.prerequisites] \
    [join [db_list prerequisites {}] ", "]

template::multirow append details [_ curriculum-central.assumed_knowledge] \
    [join [db_list assumed_knowledge {}] ", "]

template::multirow append details [_ curriculum-central.corequisites] \
    [join [db_list corequisites {}] ", "]

template::multirow append details [_ curriculum-central.prohibitions] \
    [join [db_list prohibitions {}] ", "]

template::multirow append details [_ curriculum-central.no_longer_offered] \
    [join [db_list no_longer_offered {}] ", "]

template::multirow append details [_ curriculum-central.note] \
    [template::util::richtext::get_property html_value $note]    

ad_return_template
