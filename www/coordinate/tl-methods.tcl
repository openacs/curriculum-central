ad_page_contract {
    Page for listing Teaching and Learning Approaches.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

set page_title "[_ curriculum-central.tl_approaches]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base tl-method-ae { method_id }]}
	link_html {title "#curriculum-central.edit_tl_approach#"}
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
}

template::list::create \
    -name methods \
    -actions [list "#curriculum-central.add_tl_approach#" [export_vars -base tl-method-ae {}] "#curriculum-central.add_tl_approach_to_list#"] \
    -multirow methods \
    -no_data "#curriculum-central.no_tl_approaches_created#" \
    -elements $elements \
    -orderby {
	name {orderby {lower(name)}}
	identifier {orderby {lower(identifier)}}
    }

db_multirow methods get_methods {}

ad_return_template
