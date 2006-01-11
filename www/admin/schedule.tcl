ad_page_contract {
    Page for creating schedule weeks.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-08
    @cvs-id $Id$
} {
    {orderby "week_id,asc"}
}

set page_title "[_ curriculum-central.uos_schedule]"
set context [list $page_title]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base schedule-week-ae { week_id }]}
	link_html {title "#curriculum-central.edit_schedule_week#"}
    }
    name {
	label "#curriculum-central.schedule_week#"
    }
}

template::list::create \
    -name schedule \
    -actions [list "#curriculum-central.add_schedule_week#" [export_vars -base schedule-week-ae {}] "#curriculum-central.add_week_to_list#"] \
    -multirow schedule \
    -no_data "#curriculum-central.no_schedule_weeks_created#" \
    -elements $elements \
    -orderby {
	week_id {orderby {week_id}}
    }

db_multirow schedule get_schedule {}

ad_return_template
