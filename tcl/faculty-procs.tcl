ad_library {

    Curriculum Central Faculty Library
    
    Procedures that deal with faculty data.

    @creation-date 2005-11-25
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$

}

namespace eval curriculum_central::faculty {}

ad_proc -public curriculum_central::faculty::faculties_exist_p {
    {-package_id ""}
} {
    Checks if at least one faculty has been created for an instance of
    Curriculum Central.

    @param package_id The mounted instance of Curriculum Central.  Note: the
    ad_conn package_id is used by default.
    @return Returns true 1 at least one faculty has been created, otherwise
    0 is returned.
} {
    if { $package_id eq "" } {
	set package_id [ad_conn package_id]
    }

    # Return 1 if at least one faculty has been created, otherwise 0.
    return [db_0or1row exist {}]
}
