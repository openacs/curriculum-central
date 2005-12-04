ad_page_contract {
    Page for displaying a list of staff members for each faculty.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    {orderby "faculty_name,asc"}
}

set page_title "[_ curriculum-central.staff_admin]"
set context [list [_ curriculum-central.staff_admin]]
set package_id [ad_conn package_id]

# Check if any faculties have been created, otherwise redirect if there
# are none.
if { ![curriculum_central::faculty::faculties_exist_p] } {
    ad_return_template "no-faculties"
    return
}

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base staff-ae { staff_id }]}
	link_html {title "#curriculum-central.edit_staff_info#"}
    }
    staff_name {
	label "#curriculum-central.name#"
    }
    department_name {
	label "#curriculum-central.department#"
    }
    faculty_name {
	label "#curriculum-central.faculty#"
	link_url_eval {[export_vars -base faculty-depts { faculty_id }]}
	link_html {title "#curriculum-central.view_faculty_depts#"}
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base staff-del { staff_id }]}
	link_html {title "#curriculum-central.delete_staff#" onclick "return confirm(\'[_ curriculum-central.want_to_delete_staff]\');"}
    }
}

template::list::create \
    -name staff \
    -multirow staff \
    -no_data "#curriculum-central.no_staff#" \
    -elements $elements \
    -actions [list "#curriculum-central.add_staff_member#" [export_vars -base staff-ae {}] "#curriculum-central.add_staff_to_list#"] \
    -orderby {
        staff_name {orderby {lower(last_name)}}
	department_name {orderby {lower(department_name)}}
	faculty_name {orderby {faculty_id}}
    }

db_multirow staff staff {}

ad_return_template
