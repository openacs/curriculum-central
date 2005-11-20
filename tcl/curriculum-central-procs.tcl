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


ad_proc curriculum_central::users_get_options {} {
    Returns a two-column list of users.  The first column contains the
    pretty name of a user, and the second contains the corresponding user_id.
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



#####
#
# Resolution
#
#####

ad_proc curriculum_central::resolution_get_options {} {
    return \
        [list \
             [list [_ curriculum-central.fixed] fixed ] \
             [list [_ curriculum-central.wont_fix] wontfix ] \
             [list [_ curriculum-central.postponed] postponed ] \
             [list [_ curriculum-central.need_info] needinfo ] \
            ]

}

ad_proc curriculum_central::resolution_pretty {
    resolution
} {
    array set resolution_codes {
        fixed curriculum-central.fixed
        wontfix curriculum-central.wont_fix
        postponed curriculum-central.postponed
        needinfo curriculum-central.need_info
    }
    if { [info exists resolution_codes($resolution)] } {
        return [_ $resolution_codes($resolution)]
    } else {
        return ""
    }
}
