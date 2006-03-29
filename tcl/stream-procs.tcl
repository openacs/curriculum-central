ad_library {

    Curriculum Central Stream Library
    
    Procedures that deal with streams.

    @creation-date 2005-11-25
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$

}

namespace eval curriculum_central::stream {}

ad_proc -public curriculum_central::stream::streams_exist_p {
    {-package_id ""}
} {
    Checks if at least one stream has been created for an instance of
    Curriculum Central.

    @param package_id The mounted instance of Curriculum Central.  Note: the
    ad_conn package_id is used by default.
    @return Returns true 1 at least one stream has been created, otherwise
    0 is returned.
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }

    # Return 1 if at least one stream has been created, otherwise 0.
    return [db_0or1row streams_exist {}]
}


ad_proc curriculum_central::stream::years_get_options {
    {-package_id ""}
} {
    Returns a two-column list of years that a stream runs for.

    @param package_id ID of the current package instance.

    @return Returns a two-column list of registered school years.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    # Create an empty option that the user can select.  The value of
    # which is an empty string.
    set year_list [list [list [_ curriculum-central.none] 0]]
    db_foreach years {} {
        set year_name [lang::util::localize $name]

        lappend year_list [list $year_name $year_id]
    }

    return $year_list
}


ad_proc curriculum_central::stream::semesters_get_options {
    {-package_id ""}
} {
    Returns a two-column list of semesters that a stream runs for.

    @param package_id ID of the current package instance.

    @return Returns a two-column list of registered semesters.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    # Create an empty option that the user can select.  The value of
    # which is an empty string.
    set empty_option [list [list [list [_ curriculum-central.none]] 0]]
    set semester_list [db_list_of_lists semesters {}]

    return [concat $empty_option $semester_list]
}


ad_proc curriculum_central::stream::years_for_uos_get_options {
    {-package_id ""}
    {-stream_id:required}
} {
    Returns a two-column list of years that a Unit of Study can be assigned to.

    @param package_id ID of the current package instance.
    @param stream_id Stream ID to retrieve valid years for.

    @return Returns a two-column list of registered school years.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    # Create an empty option that the user can select.  The value of
    # which is an empty string.
    set year_list [list [list [list [_ curriculum-central.none]] 0]]

    set year_ids [db_string year_ids {} -default ""]

    foreach year_id $year_ids {
	set year_name [lang::util::localize [db_string year_name {} -default ""]]
	lappend year_list "[list $year_name] $year_id"
    }

    return $year_list
}


ad_proc curriculum_central::stream::sessions_get_options {
    {-package_id ""}
} {
    Returns a two-column list of all available sessions.

    @param package_id ID of the current package instance.

    @return Returns a two-column list of registered sessions.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    # Create an empty option that the user can select.  The value of
    # which is an empty string.
    set session_list [list [list [list [_ curriculum-central.none]] 0]]

    #set session_ids [db_string session_ids {} -default ""]

    db_foreach session_ids {} {
	set session_name [db_string session_name {} -default ""]
	lappend session_list "[list $session_name] $session_id"
    }

    return $session_list
}


ad_proc curriculum_central::stream::all_uos_except_get_options {
    {-except_uos_id:required}
    {-package_id ""}
    {-empty_option:boolean}
} {
    Returns a two-column list of the names of all UoS and their
    corresponding UoS ID.

    @param package_id ID of the current package instance.
    @param empty_option If empty_option flag is set to true, then an empty
    option with name set to None, and the corresponding value set to 0 will
    be added to the options list.  This is useful for lists that allow a 
    none value to be selected.

    @return Returns a two-column list of all UoS.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    set uos_list [db_list_of_lists all_uos {}]

    # Create an empty option that the user can select..
    if {$empty_option_p} {
	set empty [list [list [list [_ curriculum-central.none]] 0]]
	return [concat $empty $uos_list]
    } else {
	return $uos_list
    }
}


ad_proc curriculum_central::stream::all_uos_get_options {
    {-package_id ""}
} {
    Returns a two-column list of the names of all UoS and
    corresponding UoS ID from a package_id.

    @param package_id ID of the current package instance.

    @return Returns a two-column list of all UoS.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    return [db_list_of_lists all_uos {}]
}


ad_proc curriculum_central::stream::all_uos_names_get_options {
    {-package_id ""}
} {
    Returns a two-column list of the names of all UoS names and
    corresponding UoS name ID from a package_id.

    @param package_id ID of the current package instance.

    @return Returns a two-column list of all UoS names.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    set empty [list [list [list [_ curriculum-central.none]] 0]]

    return [concat $empty [db_list_of_lists all_uos_names {}]]
}


ad_proc curriculum_central::stream::stream_uos_relation_get_options {} {
    Returns a two-column list of UoS to Stream relations.

    @return Returns a two-column list of UoS to Stream relations.
} {
    set package_id [ad_conn package_id]

    set rels_list [list]
    db_foreach stream_uos_rels {} {
	set rel_name [lang::util::localize $name]

	lappend rels_list [list $rel_name $stream_uos_rel_id]
    }

    return $rels_list
}


ad_proc curriculum_central::stream::stream_uos_relation_name {
    {-id:required}
} {
    Returns the pretty name for the given relation_id.

    @param id The ID that corresponds to a defined stream to UoS relation
    name.

    @see curriculum_central::stream::stream_uos_relation_get_options
} {
    set package_id [ad_conn package_id]

    return [db_string get_name {} -default ""]
}
