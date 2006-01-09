ad_page_contract {
    Page for creating grade types.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-08
    @cvs-id $Id$
} {
    {orderby "upper_bound,desc"}
}

set page_title "[_ curriculum-central.uos_grade_types]"
set context [list [_ curriculum-central.uos_grade_types]]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base grade-ae { type_id }]}
	link_html {title "#curriculum-central.edit_grade_type#"}
    }
    name {
	label "#curriculum-central.grade_type#"
    }
    lower_bound {
	label "#curriculum-central.lower_bound#"
    }
    upper_bound {
	label "#curriculum-central.upper_bound#"
    }
}

template::list::create \
    -name grades \
    -actions [list "#curriculum-central.add_grade_type#" [export_vars -base grade-ae {}] "#curriculum-central.add_grade_type_to_list#"] \
    -multirow grades \
    -no_data "#curriculum-central.no_grade_types_created#" \
    -elements $elements \
    -orderby {
	upper_bound {orderby {upper_bound}}
    }

db_multirow grades get_grades {}

ad_return_template
