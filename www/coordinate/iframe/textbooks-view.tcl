ad_page_contract {
    Page for listing textbooks for a specific UoS.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
    edit_p:integer,notnull
    {orderby "title,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.textbooks]"
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
	    link_url_eval {[export_vars -url -base textbook-ae { uos_id textbook_id }]}
	    link_html {title "#curriculum-central.edit_textbook#"}
	}
	title {
	    label "#curriculum-central.title#"
	}
	author {
	    label "#curriculum-central.author#"
	}
	publisher {
	    label "#curriculum-central.publisher#"
	}
	isbn {
	    label "#curriculum-central.isbn#"
	}
	delete {
	    sub_class narrow
	    display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	    }
	    link_url_eval {[export_vars -base textbook-del { uos_id textbook_id }]}
	    link_html {title "#curriculum-central.delete_textbook#" onclick "return confirm(\'[_ curriculum-central.want_to_delete_textbook]\');"}
	}
    }
    
    template::list::create \
	-name textbooks \
	-actions [list "#curriculum-central.add_textbook#" [export_vars -base textbook-ae { uos_id }] "#curriculum-central.add_textbook_to_list#"] \
	-multirow textbooks \
	-no_data "#curriculum-central.no_textbooks_created#" \
	-elements $elements \
	-orderby {
	    title {orderby {lower(t.title)}}
	} \
	-filters {uos_id {} edit_p {}} \
	-pass_properties {uos_id}
} else {
    set elements {
	title {
	    label "#curriculum-central.title#"
	}
	author {
	    label "#curriculum-central.author#"
	}
	publisher {
	    label "#curriculum-central.publisher#"
	}
	isbn {
	    label "#curriculum-central.isbn#"
	}
    }
    
    template::list::create \
	-name textbooks \
	-multirow textbooks \
	-no_data "#curriculum-central.no_textbooks_created#" \
	-elements $elements \
	-orderby {
	    title {orderby {lower(t.title)}}
	} \
	-filters {uos_id {} edit_p {}} \
	-pass_properties {uos_id}
}

set latest_revision_id ""
db_0or1row latest_textbooks {}

db_multirow textbooks get_textbooks {}

ad_return_template
