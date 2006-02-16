ad_page_contract {
    Page for creating degree stream relations.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "name,asc"}
}

set page_title "[_ curriculum-central.stream_to_uos_relations]"
set context [list $page_title]
set package_id [ad_conn package_id]

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base stream-rel-ae { stream_uos_rel_id }]}
	link_html {title "#curriculum-central.edit_stream_rel_info#"}
    }
    name {
	label "#curriculum-central.name#"
    }
    delete {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	}
    }
}

template::list::create \
    -name stream_rels \
    -actions [list "#curriculum-central.add_rel#" [export_vars -base stream-rel-ae {}] "#curriculum-central.add_rel_to_list#"] \
    -multirow stream_rels \
    -no_data "#curriculum-central.no_rels_created#" \
    -elements $elements \
    -orderby {
        name {orderby {lower(name)}}
    }

db_multirow stream_rels get_rels {}

ad_return_template