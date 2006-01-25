ad_page_contract {
    This page deletes a stream to uos map.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    stream_id:integer
    return_url
    map_id:integer
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Only stream coordinators can develop a stream.
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_can_develop_a_stream] index
}

# Delete map_id.
db_exec_plsql delete_map {}

ad_returnredirect -message [_ curriculum-central.stream_mapping_has_been_deleted] [export_vars -base stream-view {stream_id}]
