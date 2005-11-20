ad_page_contract {
    Page for creating streams.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "stream_name,asc"}
}

set page_title "[_ curriculum-central.streams_admin]"
set context [list [_ curriculum-central.streams_admin]]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base stream-ae { stream_id }]}
	link_html {title "#curriculum-central.edit_stream_info#"}
    }
    stream_name {
	label "#curriculum-central.stream_name#"
    }
    stream_code {
	label "#curriculum-central.stream_code#"
    }
    department {
	label "#curriculum-central.department#"
    }
    stream_coordinator {
	label "#curriculum-central.coordinator#"
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
    }
}

template::list::create \
    -name streams \
    -actions [list "#curriculum-central.add_stream#" [export_vars -base stream-ae {}] "#curriculum-central.add_stream_to_list#"] \
    -multirow streams \
    -no_data "#curriculum-central.no_streams_created#" \
    -elements $elements \
    -orderby {
	stream_name {orderby {lower(stream_name)}}
	stream_code {orderby {lower(stream_code)}}
	department {orderby {lower(department)}}
	stream_coordinator {orderby {lower(stream_coordinator)}}
    }

db_multirow streams get_streams {}

ad_return_template