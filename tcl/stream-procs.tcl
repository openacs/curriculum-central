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
    set empty_option [list [list [list [_ curriculum-central.none]] 0]]
    set year_list [db_list_of_lists years {}]

    return [concat $empty_option $year_list]
}


ad_proc curriculum_central::stream::semesters_get_options {
    {-package_id ""}
} {
    Returns a two-column list of years that a stream runs for.

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
	set year_name [db_string year_name {} -default ""]
	lappend year_list "[list $year_name] $year_id"
    }

    return $year_list
}


ad_proc curriculum_central::stream::semesters_in_a_year_get_options {
    {-package_id ""}
    {-stream_id:required}
} {
    Returns a two-column list of years that a stream runs for.

    @param package_id ID of the current package instance.
    @param stream_id Stream ID to retrieve valid semesters for.

    @return Returns a two-column list of registered semesters.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    # Create an empty option that the user can select.  The value of
    # which is an empty string.
    set semester_list [list [list [list [_ curriculum-central.none]] 0]]

    set semester_ids [db_string semester_ids {} -default ""]

    foreach semester_id $semester_ids {
	set semester_name [db_string semester_name {} -default ""]
	lappend semester_list "[list $semester_name] $semester_id"
    }

    return $semester_list
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


ad_proc curriculum_central::stream::all_stream_uos {
    {-package_id ""}
} {
    Returns a two-column list of the names of all UoS and
    corresponding UoS ID for the given Stream ID.

    @param stream_id Stream ID.
    @param package_id ID of the current package instance.

    @return Returns a two-column list of all UoS that have been mapped to
    the given Stream ID.
} {
    if { $package_id eq ""} {
	set package_id [ad_conn package_id]
    }

    return [db_list_of_lists all_stream_uos {}]
}


ad_proc curriculum_central::stream::stream_uos_relation_get_options {} {
    Returns a two-column list of UoS to Stream relations.  The list
    contains hard coded values for Core, Recommended and Elective, with
    values of 0, 1, and 2 respectively.

    @return Returns a two-column list of UoS to Stream relations.
} {
    set relations [list]
    lappend relations "[_ curriculum-central.core] 0"
    lappend relations "[_ curriculum-central.recommended] 1"
    lappend relations "[_ curriculum-central.elective] 2"

    return $relations
}


ad_proc curriculum_central::stream::stream_uos_relation_name {
    {-id:required}
} {
    Returns the pretty name for the given relation_id.

    @param id The ID that corresponds to either "Core", "Recommended",
    or "Elective".

    @see curriculum_central::stream::stream_uos_relation_get_options
} {
    if { $id eq 0 } {
	return [_ curriculum-central.core]
    } elseif { $id eq 1} {
	return [_ curriculum-central.recommended]
    } else {
	return [_ curriculum-central.elective]
    }
}