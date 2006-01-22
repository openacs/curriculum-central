ad_page_contract {
    Page for creating years.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

set page_title "[_ curriculum-central.years]"
set context [list [_ curriculum-central.years]]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base year-ae { year_id }]}
	link_html {title "#curriculum-central.edit_year_info#"}
    }
    name {
	label "#curriculum-central.name#"
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
    }
}

template::list::create \
    -name years \
    -actions [list "#curriculum-central.add_year#" [export_vars -base year-ae {}] "#curriculum-central.add_year_to_list#"] \
    -multirow years \
    -no_data "#curriculum-central.no_years_created#" \
    -elements $elements \
    -orderby {
        name {orderby {lower(name)}}
    }

db_multirow years get_years {}

ad_return_template