ad_page_contract {
    Index page for displaying all pending Units of Study.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

auth::require_login

set page_title [_ curriculum-central.all_pending_units_of_study]
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set user_id [ad_conn user_id]
set workflow_id [curriculum_central::uos::get_instance_workflow_id]


# If the user is a Unit Coordinator, then display list of pending Units
# of Study that they are responsible for.
set elements {
    edit {
	sub_class narrow
	display_template {
	    <img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	}
	link_url_eval {[export_vars -base uos-edit { uos_id }]}
	link_html {title "#curriculum-central.edit_uos#"}
    }
    uos_code {
	sub_class narrow
	label "#curriculum-central.uos_code#"
    }
    uos_name {
	label "#curriculum-central.uos_name#"
    }
    unit_coordinator {
	label "#curriculum-central.unit_coordinator#"
    }
    pretty_name {
	label "#curriculum-central.current_state#"
    }
}

template::list::create \
    -name all_pending_uos \
    -multirow all_pending_uos \
    -no_data "#curriculum-central.none_pending#" \
    -elements $elements

db_multirow -extend {unit_coordinator} all_pending_uos get_all_pending_uos {} {
    set unit_coordinator [curriculum_central::staff::pretty_name $unit_coordinator_id]
}


ad_return_template
