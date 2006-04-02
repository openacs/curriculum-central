ad_library {

    Curriculum Central Stream Library
    
    Procedures that deal with staff

    @creation-date 2005-12-18
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$

}

namespace eval curriculum_central::staff {}

ad_proc -public curriculum_central::staff::pretty_name {
    staff_id
} {
    Returns the pretty name for the given staff ID.  The pretty name is
    the staff member's title followed by their first and last names.

    @param staff_id The ID of the staff member to retrieve the pretty name
    for.
    @return Returns the pretty name of the given staff member.
} {
    return [db_string get_pretty_name {} -default ""]
}


ad_proc -public curriculum_central::staff::stream_coordinator_p {
    user_id
} {
    Checks if the given user is a stream coordinator or not.

    @param user_id ID of a user.
    @return Returns 1 if the user is a stream coordinator, otherwise
    0 is returned.
} {

    # If the user is a stream coordinator for at least one
    # stream, then the user is a stream coordinator.
    return [db_0or1row is_stream_coordinator {}]
}


ad_proc -public curriculum_central::staff::staff_p {
    user_id
} {
    Checks if the given user is a member of staff or not.

    @param user_id ID of a user.
    @return Returns 1 if the user is a staff member, otherwise
    0 is returned.
} {

    return [db_0or1row staff_p {}]
}
