ad_library {

    Curriculum Central Library

    @creation-date 2005-11-08
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id bug-tracker-procs.tcl,v 1.13.2.7 2003/03/05 18:13:39 lars Exp

}

namespace eval curriculum_central {}

ad_proc curriculum_central::package_key {} {
    return "curriculum-central"
}


ad_proc curriculum_central::curriculum_new { curriculum_id } {
    Create a new curriculum.  Each curriculum is given its own content
    folder.  The content folder will contain content items for each Unit
    of Study that belongs to the curriculum.

    @param curriculum_id The package ID for a new curriculum instance.
} {
    if { ![db_0or1row already_there {}] } {
	if { [db_0or1row instance_info { *SQL* }] } {
	    # create new folder for UoS items
	    set folder_id [content::folder::new \
	        -name "curriculum_central_$curriculum_id" \
		-package_id $curriculum_id]
	    
	    # register content types
	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_revision" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_tl_revision" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_detail_revision" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_workload_revision" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_gradattr_set_rev" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_assess_revision" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_textbook_set_rev" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_grade_set_rev" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_uos_schedule_set_rev" \
		-include_subtypes "t"

	    content::folder::register_content_type \
		-folder_id $folder_id \
		-content_type "cc_stream_uos_map_rev" \
		-include_subtypes "t"

	    set keyword_id [content::keyword::new -heading "$instance_name"]

	    # Inserts into cc_curriculum
	    db_dml cc_curriculum_insert {}
	}
    }
}


ad_proc curriculum_central::curriculum_delete { curriculum_id } {
    Delete a curriculum and all containing UoS items.

    @param curriculum_id The ID for the curriculum to delete.
} {
    # TODO: Delete all UoS items for the curriculum.
    #while { [set uos_id [db_string min_uos_id {}]] > 0 } {
    #	curriculum_central::uos::delete $uos_id
    #}

    db_exec_plsql delete_curriculum {}
}


ad_proc curriculum_central::staff_get_options {} {
    Returns a two-column list of users that are considered to be staff.
    The first column contains the pretty name of a user, and the second
    contains their user_id.
} {
    set staff_list [db_list_of_lists staff {}]

    return $staff_list
}


ad_proc curriculum_central::non_staff_get_options {} {
    Returns a two-column list of users that aren't considered to be staff.
    The first column contains the pretty name of a user, and the second
    contains the corresponding user_id.
} {
    set non_staff_list [db_list_of_lists non_staff {}]

    return $non_staff_list
}


ad_proc curriculum_central::users_get_options {} {
    Returns a two-column list of users that have accounts on the system.
    The first column contains the pretty name of a user, and the second
    contains the corresponding user_id.
} {
    set users_list [db_list_of_lists users {}]

    return $users_list
}


ad_proc curriculum_central::departments_get_options {
    {-package_id {}}
} {
    Returns a two-column list of departments.  The first column contains the
    pretty name of a department, and the second contains the corresponding
    department_id.

    @param package_id The package ID for an instance of Curriculum Central.
    @return Returns a list of departments.
} {
    if { [empty_string_p $package_id] } {
        set package_id [ad_conn package_id]
    }

    set departments_list [db_list_of_lists departments {}]

    return $departments_list    
}


ad_proc curriculum_central::graduate_attribute_names_get_options {
    {-package_id {}}
} {
    Returns a two-column list of valid graduate attribute names that have
    been defined by the package administrator.  The first column contains the
    pretty name of a graduate attribute, and the second contains the
    corresponding name_id.

    @param package_id The package ID for an instance of Curriculum Central.
    @return Returns a list of graduate attribute names.
} {
    if { [empty_string_p $package_id] } {
        set package_id [ad_conn package_id]
    }

    set ga_names_list [db_list_of_lists ga_names {}]

    return $ga_names_list
}


#####
#
# Procs for page variables and filters for UoS edit form.
#
#####

ad_proc -public curriculum_central::get_page_variables {
    {extra_spec ""}
} {
    Adds the UoS listing filter variables for use in the page contract.

    Usage: ad_page_contract { doc } [curriculum_central::get_page_variables { foo:integer {bar ""} }]

    @param extra_spec Filter vars to be added to the page variables, along
    with the filter vars obtained from the current workflow instance.

    @return Returns a list of filter variables for a page contract.
} {
    foreach action_id [workflow::get_actions -workflow_id [curriculum_central::uos::get_instance_workflow_id]] {
	lappend filter_vars "f_action_$action_id:optional"
    }

    return [concat $filter_vars $extra_spec]
}


ad_proc curriculum_central::get_export_variables {
    {extra_vars ""}
} {
    Gets a list of variables to export for the UoS list.
} {
    foreach action_id [workflow::get_actions -workflow_id [curriculum_central::uos::get_instance_workflow_id]] {
        lappend export_vars "f_action_$action_id"
    }

    return [concat $export_vars $extra_vars]
}


ad_proc curriculum_central::join_sessions {
    {-session_ids:required}
    {-separator ", "}
} {
    Retrieve the names that match each session ID, and join the names
    using the given separator.

    @param session_ids A list of session IDs.
    @param separator Specify a separator that will be used to join the
    session names together.  Uses a comma by default.
} {
    set package_id [ad_conn package_id]
    set session_names [list]

    foreach session_id $session_ids {
	lappend session_names [db_string session_name {} -default ""]
    }

    return [join $session_names $separator]
}


ad_proc curriculum_central::join_staff {
    {-staff_ids:required}
    {-separator ", "}
} {
    Retrieve the names that match each staff ID, and join the names
    using the given separator.

    @param staff_ids A list of staff IDs.
    @param separator Specify a separator that will be used to join the
    staff names together.  Uses a comma by default.
} {
    set package_id [ad_conn package_id]
    set staff_names [list]

    foreach staff_id $staff_ids {
	lappend staff_names \
	    [curriculum_central::staff::pretty_name $staff_id]
    }

    return [join $staff_names $separator]
}


ad_proc curriculum_central::join_graduate_attributes {
    {-uos_id:required}
    {-separator ", "}
} {
    Retrieve the graduate attribute names for the given UoS ID, and join
    the names using the given separator.

    @param uos_id UoS ID to retrieve graduate attributes for.
    @param separator Specify a separator that will be used to join the
    graduate_attribute names together.  Uses a comma by default.
} {
    set package_id [ad_conn package_id]
    set ga_names [list]

    db_foreach ga_name {} {
	lappend ga_names $name
	    
    }

    return [join $ga_names $separator]
}
