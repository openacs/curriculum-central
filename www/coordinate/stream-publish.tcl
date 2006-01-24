ad_page_contract {
    This page takes a list of modified stream-to-uos maps, identified
    by the corresponding map_ids.  Each mapping instance is updated
    so that the latest revision becomes the live revision.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    stream_id:integer
    modified_list
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Only stream coordinators can develop a stream.
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_can_develop_a_stream] index
}

foreach map_id $modified_list {
    db_dml publish {}
}

ad_returnredirect -message [_ curriculum-central.stream_overview_has_been_published] [export_vars -base stream-view {stream_id}]
