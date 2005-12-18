ad_library {

    Curriculum Central Install library
    
    Procedures that deal with installing, instantiating, mounting.

    @creation-date 2005-11-08
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$
}


namespace eval curriculum_central::install {}

ad_proc -private curriculum_central::install::package_install {} {
    Package installation callback proc
} {
    db_transaction {
        curriculum_central::install::register_implementations
        #bug_tracker::search::register_implementations
	curriculum_central::install::roles_create
        curriculum_central::uos::workflow_create
    }
}


ad_proc -private curriculum_central::install::package_uninstall {} {
    Package un-installation callback proc
} {
    db_transaction {
        curriculum_central::uos::workflow_delete
        curriculum_central::install::roles_delete
        curriculum_central::install::unregister_implementations
        #bug_tracker::search::unregister_implementations
    }
}


ad_proc -private curriculum_central::install::package_instantiate {
    {-package_id:required}
} {
    Package instantiation callback proc
} {
    # Create the new curriculum
    curriculum_central::curriculum_new $package_id

    # Create the UoS workflow
    curriculum_central::uos::instance_workflow_create -package_id $package_id
}


ad_proc -private curriculum_central::install::package_uninstantiate {
    {-package_id:required}
} {
    Package un-instantiation callback proc
} {
    # Delete the curriculum.
    curriculum_central::curriculum_delete $package_id

    # Delete the corresponding workflow instance.
    curriculum_central::uos::instance_workflow_delete -package_id $package_id

}


#####
#
# Service contract implementations
#
#####

ad_proc -private curriculum_central::install::register_implementations {} {
    db_transaction {
	# Unit Coordinator SC implementations
	curriculum_central::install::register_unit_coordinator_default_assignees_impl
	curriculum_central::install::register_unit_coordinator_assignee_pick_list_impl
	curriculum_central::install::register_unit_coordinator_assignee_subquery_impl

	# Stream Coordinator SC implementations
	curriculum_central::install::register_stream_coordinator_default_assignees_impl
	curriculum_central::install::register_stream_coordinator_assignee_pick_list_impl
	curriculum_central::install::register_stream_coordinator_assignee_subquery_impl

	# Other SC implementations
        curriculum_central::install::register_format_log_title_impl
        curriculum_central::install::register_uos_notification_info_impl
	curriculum_central::install::register_uos_go_live_impl
    }
}


ad_proc -private curriculum_central::install::unregister_implementations {} {
    db_transaction {

	# Delete Unit Coordinator SC implementations
        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::role_assignee_subquery] \
	    -impl_name "UnitCoordinator_Assignee_SubQuery"

        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::role_assignee_pick_list] \
	    -impl_name "UnitCoordinator_Assignee_PickList"

        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::role_default_assignees]  \
	    -impl_name "UnitCoordinator_Default_Assignees"

	# Delete Stream Coordinator SC implementations
        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::role_assignee_subquery] \
	    -impl_name "StreamCoordinator_Assignee_SubQuery"

        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::role_assignee_pick_list] \
	    -impl_name "StreamCoordinator_Assignee_PickList"

        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::role_default_assignees] \
	    -impl_name "StreamCoordinator_Default_Assignees"


	# Delete other SC implementations
        acs_sc::impl::delete \
	    -contract_name \
	    [workflow::service_contract::activity_log_format_title] \
	    -impl_name "FormatLogTitle"

        acs_sc::impl::delete \
	    -contract_name [workflow::service_contract::notification_info] \
	    -impl_name "UoSNotificationInfo"

        acs_sc::impl::delete \
	    -contract_name [workflow::service_contract::action_side_effect] \
	    -impl_name "UoSGoLive"
    }
}


ad_proc -private curriculum_central::install::register_format_log_title_impl {} {

    set spec {
        name "FormatLogTitle"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::format_log_title::pretty_name
            GetTitle      curriculum_central::uos::format_log_title::format_log_title
        }
    }
    
    lappend spec contract_name \
	[workflow::service_contract::activity_log_format_title]

    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_uos_notification_info_impl {} {

    set spec {
        name "UoSNotificationInfo"
        aliases {
            GetObjectType       curriculum_central::uos::object_type
            GetPrettyName       curriculum_central::uos::notification_info::pretty_name
            GetNotificationInfo curriculum_central::uos::notification_info::get_notification_info
        }
    }
    
    lappend spec contract_name [workflow::service_contract::notification_info]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_unit_coordinator_default_assignees_impl {} {

    set spec {
        name "UnitCoordinator_Default_Assignees"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::get_unit_coordinator::pretty_name
            GetAssignees  curriculum_central::uos::get_unit_coordinator::get_assignees
        }
    }
    
    lappend spec contract_name [workflow::service_contract::role_default_assignees]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_unit_coordinator_assignee_pick_list_impl {} {

    set spec {
        name "UnitCoordinator_Assignee_PickList"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::get_unit_coordinator::pretty_name
            GetPickList  curriculum_central::uos::get_unit_coordinator::get_assignees
        }
    }
    
    lappend spec contract_name [workflow::service_contract::role_assignee_pick_list]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_unit_coordinator_assignee_subquery_impl {} {

    set spec {
        name "UnitCoordinator_Assignee_SubQuery"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::get_unit_coordinator::pretty_name
            GetSubquery  curriculum_central::uos::get_unit_coordinator::get_subquery
        }
    }
    
    lappend spec contract_name [workflow::service_contract::role_assignee_subquery]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_stream_coordinator_default_assignees_impl {} {

    set spec {
        name "StreamCoordinator_Default_Assignees"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::get_stream_coordinator::pretty_name
            GetAssignees  curriculum_central::uos::get_stream_coordinator::get_assignees
        }
    }
    
    lappend spec contract_name [workflow::service_contract::role_default_assignees]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_stream_coordinator_assignee_pick_list_impl {} {

    set spec {
        name "StreamCoordinator_Assignee_PickList"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::get_stream_coordinator::pretty_name
            GetPickList  curriculum_central::uos::get_stream_coordinator::get_pick_list
        }
    }
    
    lappend spec contract_name [workflow::service_contract::role_assignee_pick_list]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_stream_coordinator_assignee_subquery_impl {} {

    set spec {
        name "StreamCoordinator_Assignee_SubQuery"
        aliases {
            GetObjectType curriculum_central::uos::object_type
            GetPrettyName curriculum_central::uos::get_stream_coordinator::pretty_name
            GetSubquery  curriculum_central::uos::get_stream_coordinator::get_subquery
        }
    }
    
    lappend spec contract_name [workflow::service_contract::role_assignee_subquery]
    lappend spec owner [curriculum_central::package_key]
    
    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::register_uos_go_live_impl {} {
    Registers a service contract implementation for UoSGoLive.
} {
    set spec {
	name "UoSGoLive"
	aliases {
	    GetObjectType curriculum_central::uos::object_type
	    GetPrettyName curriculum_central::uos::go_live::pretty_name
	    DoSideEffect  curriculum_central::uos::go_live::do_side_effect
	}
    }

    lappend spec contract_name [workflow::service_contract::action_side_effect]

    lappend spec owner [curriculum_central::package_key]

    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private curriculum_central::install::roles_create {} {
    Creates the Stream Coordinator, Unit Coordinator and Lecturer roles.
} {
    # Create the Stream Coordinator role
    rel_types::create_role \
	-pretty_name "[_ curriculum-central.stream_coordinator]" \
	-pretty_plural "[_ curriculum-central.stream_coordinators]" \
	-role "stream_coordinator"

    # Create the Unit Coordinator role
    rel_types::create_role \
	-pretty_name "[_ curriculum-central.unit_coordinator]" \
	-pretty_plural "[_ curriculum-central.unit_coordinators]" \
	-role "unit_coordinator"

    # Create the Lecturer role
    rel_types::create_role \
	-pretty_name "[_ curriculum-central.lecturer]" \
	-pretty_plural "[_ curriculum-central.lecturers]" \
	-role "lecturer"

}


ad_proc -private curriculum_central::install::roles_delete {} {
    Deletes the Stream Coordinator, Unit Coordinator and Lecturer roles.
} {
    # Delete the Stream Coordinator role
    rel_types::delete_role -role "stream_coordinator"

    # Delete the Unit Coordinator role
    rel_types::delete_role -role "unit_coordinator"

    # Delete the Lecturer role
    rel_types::delete_role -role "lecturer"

}
