ad_page_contract {
    Page for listing assessment methods for a specific UoS.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
    edit_p:integer,notnull
    {orderby "name,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.assess_methods]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

if { $edit_p } {
    set elements {
	edit {
	    sub_class narrow
	    display_template {
		<img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	    }
	    link_url_eval {[export_vars -url -base assess-ae { uos_id method_id }]}
	    link_html {title "#curriculum-central.edit_assess_method#"}
	}
	name {
	    label "#curriculum-central.name#"
	}
	weighting {
	    label "#curriculum-central.weighting#"
	}
	description {
	    label "#curriculum-central.description#"
	    html {width "100%"}
	}
	delete {
	    sub_class narrow
	    display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	    }
	    link_url_eval {[export_vars -base assess-del { uos_id method_id }]}
	    link_html {title "#curriculum-central.delete_assess_method#" onclick "return confirm(\'[_ curriculum-central.want_to_delete_assess_method]\');"}
	}
    }
    
    template::list::create \
	-name methods \
	-actions [list "#curriculum-central.add_assess_method#" [export_vars -base assess-ae { uos_id }] "#curriculum-central.add_assess_method_to_list#"] \
	-multirow methods \
	-no_data "#curriculum-central.no_assess_methods_created#" \
	-elements $elements \
	-orderby {
	    name {orderby {lower(a.name)}}
	} \
	-filters {uos_id {} edit_p {}} \
	-pass_properties {uos_id}
} else {
    set elements {
	name {
	    label "#curriculum-central.name#"
	}
	weighting {
	    label "#curriculum-central.weighting#"
	}
	description {
	    label "#curriculum-central.description#"
	    html {width "100%"}
	}
    }
    
    template::list::create \
	-name methods \
	-multirow methods \
	-no_data "#curriculum-central.no_assess_methods_created#" \
	-elements $elements \
	-orderby {
	    name {orderby {lower(a.name)}}
	} \
	-filters {uos_id {} edit_p {}} \
	-pass_properties {uos_id}
}

set latest_revision_id ""
db_0or1row latest_am {}

set total 0
db_multirow methods get_methods {} {
    set total [expr $total + $weighting]
}

ad_return_template
