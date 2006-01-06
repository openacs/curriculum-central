ad_page_contract {
    Page for listing assessment methods.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-04
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.assess_methods]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base assess-method-ae { method_id }]}
	link_html {title "#curriculum-central.edit_assess_method#"}
    }
    name {
	label "#curriculum-central.name#"
    }
    identifier {
	label "#curriculum-central.identifier#"
    }
    description {
	label "#curriculum-central.description#"
    }
    weighting {
	label "#curriculum-central.weighting#"
    }
}

template::list::create \
    -name methods \
    -actions [list "#curriculum-central.add_assess_method#" [export_vars -base assess-method-ae {}] "#curriculum-central.add_assess_method_to_list#"] \
    -multirow methods \
    -no_data "#curriculum-central.no_assess_methods_created#" \
    -elements $elements \
    -orderby {
	name {orderby {lower(name)}}
	identifier {orderby {lower(identifier)}}
    }

db_multirow methods get_methods {}

ad_return_template
