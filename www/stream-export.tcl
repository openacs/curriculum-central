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

set export_p [parameter::get -package_id $package_id -parameter ExportStreamAsXML -default 0]

if { !$export_p } {
    ad_returnredirect -message [_ curriculum-central.export_feature_has_been_disabled] index
}

# Retrieve info about the faculty, department and stream.
db_1row faculty_info {}

# Create the root node.
set doc [dom createDocument degree]
set root [$doc documentElement]

set faculty_node [$root appendChild [$doc createElement faculty]]
$faculty_node appendChild [$doc createTextNode $faculty_name]

set dept_node [$root appendChild [$doc createElement department]]
$dept_node appendChild [$doc createTextNode $department_name]

set stream_node [$root appendChild [$doc createElement stream]]
$stream_node appendChild [$doc createTextNode $stream_name]

# Retrieve a list of Units of Study.
set units_of_study [db_list_of_lists units_of_study {}]

foreach uos $units_of_study {
    set map_id [lindex $uos 0]
    set uos_code [lindex $uos 1]
    set uos_name [lindex $uos 2]
    set uos_id [lindex $uos 3]
    set year_id [lindex $uos 4]
    set year_name [lang::util::localize [lindex $uos 5]]
    set core_id [lindex $uos 6]
    set live_revision_id [lindex $uos 7]
    set session_ids [lindex $uos 8]
    set uos_name_id [lindex $uos 9]
    set rel_name [lang::util::localize [lindex $uos 10]]
    set outcomes [lindex $uos 11]
    set objectives [lindex $uos 12]
    set syllabus [lindex $uos 13]
    set lecturer_ids [lindex $uos 14]

    foreach session_id $session_ids {

	# Get name of session_id
	set session_name [lang::util::localize [db_string session_name {} -default ""]]
    
	# Root UoS node
	set uos_node [$root appendChild [$doc createElement uos]]
	$uos_node setAttribute requirement $rel_name
	$uos_node setAttribute year $year_name
	$uos_node setAttribute session $session_name

	# UoS Name
	set uos_name_node [$uos_node appendChild [$doc createElement name]]
	$uos_name_node appendChild [$doc createTextNode $uos_name]

	# UoS Code
	set uos_code_node [$uos_node appendChild [$doc createElement code]]
	$uos_code_node appendChild [$doc createTextNode $uos_code]

	# UoS Lecturers
	set lecturers_list [list]
	foreach lecturer_id [split $lecturer_ids { }] {
	    set lecturer_name [curriculum_central::staff::pretty_name $lecturer_id]
	    lappend lecturers_list $lecturer_name
	}
	set uos_lecturers [join $lecturers_list {, }]
	set uos_lecturer_node [$uos_node appendChild [$doc createElement lecturer]]
	$uos_lecturer_node appendChild [$doc createTextNode $uos_lecturers]

	# Objectives
	set objectives_node [$uos_node appendChild \
				 [$doc createElement objectives]]
	set objectives [template::util::richtext::get_property text \
			    $objectives]
	$objectives_node appendChild [$doc createTextNode $objectives]

	# Outcomes
	set outcomes_node [$uos_node appendChild \
				 [$doc createElement outcomes]]
	set outcomes [template::util::richtext::get_property text \
			    $outcomes]
	$outcomes_node appendChild [$doc createTextNode $outcomes]

	# Syllabus
	set syllabus_node [$uos_node appendChild \
				 [$doc createElement syllabus]]
	set syllabus [template::util::richtext::get_property text \
			    $syllabus]
	$syllabus_node appendChild [$doc createTextNode $syllabus]

	set gas_node [$uos_node appendChild \
			  [$doc createElement graduateAttributes]]
	db_foreach graduate_attributes {} {
	    set attribute_node [$gas_node appendChild \
			     [$doc createElement attribute]]

	    set ga_name_node [$attribute_node appendChild \
				  [$doc createElement name]]
	    set ga_name [lang::util::localize $name]
	    $ga_name_node appendChild [$doc createTextNode $ga_name]

	    set ga_level_node [$attribute_node appendChild \
				   [$doc createElement level]]
	    $ga_level_node appendChild [$doc createTextNode $level]
	    
	    set ga_desc_node [$attribute_node appendChild \
				   [$doc createElement description]]
	    $ga_desc_node appendChild [$doc createTextNode $description]
	}
    }
}

# render xml and return
ns_return 200 text/xml [$doc asXML]
