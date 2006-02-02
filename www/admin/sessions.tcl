ad_page_contract {
    Page for creating sessions.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

set page_title "[_ curriculum-central.sessions]"
set context [list [_ curriculum-central.sessions]]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base session-ae { session_id }]}
	link_html {title "#curriculum-central.edit_session_info#"}
    }
    name {
	label "#curriculum-central.name#"
    }
    start_date {
	label "#curriculum-central.start_date#"
	display_eval { [lc_time_fmt $start_date %d/%m/%y] }
    }
    end_date {
	label "#curriculum-central.end_date#"
	display_eval { [lc_time_fmt $end_date %d/%m/%y] }
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
    }
}

template::list::create \
    -name sessions \
    -actions [list "#curriculum-central.add_session#" [export_vars -base session-ae {}] "#curriculum-central.add_session_to_list#"] \
    -multirow sessions \
    -no_data "#curriculum-central.no_sessions_created#" \
    -elements $elements \
    -orderby {
        name {orderby {lower(name)}}
	start_date {orderby {start_date}}
	end_date {orderby {end_date}}
    }

db_multirow sessions get_sessions {}

ad_return_template