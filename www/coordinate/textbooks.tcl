ad_page_contract {
    Page for listing textbooks.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-1-4
    @cvs-id $Id$
} {
    {orderby "title,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.textbooks]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base textbook-ae { textbook_id }]}
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
}

template::list::create \
    -name textbooks \
    -actions [list "#curriculum-central.add_textbook#" [export_vars -base textbook-ae {}] "#curriculum-central.add_textbook_to_list#"] \
    -multirow textbooks \
    -no_data "#curriculum-central.no_textbooks_created#" \
    -elements $elements \
    -orderby {
	title {orderby {lower(t.title)}}
	author {orderby {lower(author)}}
        publisher {orderby {lower(publisher)}}
	isbn {orderby isbn}
    }

db_multirow textbooks get_textbooks {}

ad_return_template
