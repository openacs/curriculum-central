ad_page_contract {
    Page for viewing faculties.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "faculty_name,asc"}
}

set page_title "[_ curriculum-central.faculties]"
set context [list [_ curriculum-central.faculties]]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base faculty-ae { faculty_id }]}
	link_html {title "#curriculum-central.edit_faculty_info#"}
    }
    faculty_name {
	label "#curriculum-central.faculty_name#"
	link_url_eval {[export_vars -base faculty-depts {faculty_id}]}
	link_html {title "#curriculum-central.view_faculty_depts#"}
    }
    dean {
	label "#curriculum-central.dean#"
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
    }
}

template::list::create \
    -name faculties \
    -multirow faculties \
    -no_data "#curriculum-central.no_faculties_created#" \
    -elements $elements \
    -actions [list "#curriculum-central.add_faculty#" [export_vars -base faculty-ae {}] "#curriculum-central.add_faculty_to_list#"] \
    -orderby {
	faculty_name {orderby {lower(faculty_name)}}
	dean {orderby {lower(dean)}}
    }

db_multirow faculties get_faculties {}

ad_return_template
