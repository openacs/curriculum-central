ad_page_contract {
    Page for listing names of teaching and learning approaches.  Names
    include tutorial, lab, lecture, etc..

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-1-4
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.tl_names]"
set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base tl-name-ae { name_id }]}
	link_html {title "#curriculum-central.edit_tl_name#"}
    }
    name {
	label "#curriculum-central.name#"
    }
    general_description {
	label "#curriculum-central.general_description#"
    }
}

template::list::create \
    -name names \
    -actions [list "#curriculum-central.add_tl_name#" [export_vars -base tl-name-ae {}] "#curriculum-central.add_tl_name_to_list#"] \
    -multirow names \
    -no_data "#curriculum-central.no_tl_names_created#" \
    -elements $elements \
    -orderby {
	name {orderby {lower(name)}}
    }

db_multirow names get_tl_names {} {
    set general_description [template::util::richtext::get_property \
				 contents $general_description]
}

ad_return_template
