ad_page_contract {
    Page for listing graduate attributes.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-1-4
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.graduate_attributes]"
set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base gradattr-ae { name_id }]}
	link_html {title "#curriculum-central.edit_graduate_attribute#"}
    }
    name {
	label "#curriculum-central.name#"
    }
    general_description {
	label "#curriculum-central.general_description#"
    }
}

template::list::create \
    -name gradattrs \
    -actions [list "#curriculum-central.add_graduate_attribute#" [export_vars -base gradattr-ae {}] "#curriculum-central.add_graduate_attribute_to_list#"] \
    -multirow gradattrs \
    -no_data "#curriculum-central.no_graduate_attributes_created#" \
    -elements $elements \
    -orderby {
	name {orderby {lower(name)}}
	identifier {orderby {lower(identifier)}}
	level {orderby level}
    }

db_multirow gradattrs get_gradattrs {} {
    set general_description [template::util::richtext::get_property \
				 contents $general_description]
}

ad_return_template
