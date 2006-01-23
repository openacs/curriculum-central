ad_page_contract {
    Displays a list of streams that the stream coordinator is responsible
    for.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "stream_name,asc"}
}

set page_title "[_ curriculum-central.your_streams]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Only stream coordinators can develop a stream.
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_can_develop_a_stream] index
}

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base stream-map-ae { stream_id }]}
	link_html {title "#curriculum-central.map_uos_to_this_stream#"}
    }
    stream_name {
	label "#curriculum-central.stream_name#"
	link_url_eval {[export_vars -base stream-view { stream_id }]}
    }
    stream_code {
	label "#curriculum-central.stream_code#"
    }
    department {
	label "#curriculum-central.department#"
    }
}

template::list::create \
    -name streams \
    -multirow streams \
    -no_data "#curriculum-central.you_are_not_the_coordinator_for#" \
    -elements $elements \
    -orderby {
	stream_name {orderby {lower(stream_name)}}
	stream_code {orderby {lower(stream_code)}}
	department {orderby {department_id}}
    }

db_multirow streams get_streams {}

ad_return_template