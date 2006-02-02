ad_page_contract {
    Displays a list of Unit of Study names.  This is used to create a
    set of Units of Study that may or may not exist.  If they exist
    then the stream coordinator will add details to the UoS using
    uos-add and uos-edit.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
} {
    {orderby "uos_code,asc"}
}

set page_title "[_ curriculum-central.uos_names]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# Only stream coordinators can create UoS names..
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_can_create_uos_names] index
}

set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base uos-name-ae { name_id }]}
	link_html {title "#curriculum-central.edit_uos_name#"}
    }
    uos_code {
	label "#curriculum-central.uos_code#"
    }
    uos_name {
	label "#curriculum-central.uos_name#"
    }
}

template::list::create \
    -name uos_names \
    -multirow uos_names \
    -actions [list "#curriculum-central.add_uos_name#" [export_vars -base uos-name-ae {}] "#curriculum-central.add_uos_name_to_list#"] \
    -no_data "#curriculum-central.no_uos_names_have_been_created#" \
    -elements $elements \
    -orderby {
	uos_code {orderby {lower(uos_code)}}
	uos_name {orderby {lower(uos_name)}}
    }

db_multirow uos_names get_uos_names {}

ad_return_template