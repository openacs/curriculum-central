ad_page_contract {
    Index page for coordinating a curriculum.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

auth::require_login

set page_title [_ curriculum-central.coordinate]
set context [list $page_title]
set user_id [ad_conn user_id]

set stream_coordinator_p \
    [curriculum_central::staff::stream_coordinator_p $user_id]

set workflow_id [curriculum_central::uos::get_instance_workflow_id]

set num_users_pending [curriculum_central::uos::num_pending \
			  -workflow_id $workflow_id \
			  -user_id $user_id]

set num_all_pending [curriculum_central::uos::num_pending \
			 -workflow_id $workflow_id]

ad_return_template
