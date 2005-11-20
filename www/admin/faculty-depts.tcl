ad_page_contract {
    Page for viewing faculty departments.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    faculty_id:integer,notnull
}

if { [db_0or1row get_faculty_name {}] } {
    set page_title [_ curriculum-central.faculty_name_depts]
} else {
    # Specify a default page title.  Note that we shouldn't need to
    # resort to this as faculty_id must not be null, and faculty
    # info should be available.
    set page_title [_ curriculum-central.faculty_depts]
}

set context [list $page_title]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base dept-ae { department_id }]}
	link_html {title "#curriculum-central.edit_dept_info#"}
    }
    department_name {
	label "#curriculum-central.dept_name#"
	link_url_eval {[export_vars -base dept {department_id}]}
    }
    hod {
	label "#curriculum-central.hod#"
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
    }
}

template::list::create \
    -name depts \
    -multirow depts \
    -no_data "#curriculum-central.no_depts_created#" \
    -elements $elements \
    -actions [list "#curriculum-central.add_dept#" \
		  [export_vars -base dept-ae {}] \
		  "#curriculum-central.add_dept_to_list#"] \
    -orderby {
	department_name {orderby {lower(department_name)}}
	hod {orderby {lower(hod)}}
    }

db_multirow depts get_depts {}

ad_return_template
