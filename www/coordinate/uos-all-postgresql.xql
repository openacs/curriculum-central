<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.4</version></rdbms>

    <fullquery name="get_all_uos">
      <querytext>
        SELECT n.uos_code, n.uos_name, u.uos_id, u.unit_coordinator_id,
	    s.short_name, s.pretty_name
        FROM cc_uos u,
	    cc_uos_name n,
	    workflow_cases c,
	    workflow_case_fsm f,
	    workflow_fsm_states s
	WHERE c.case_id = f.case_id
	AND s.state_id = f.current_state
	AND c.workflow_id = :workflow_id
	AND u.uos_id = c.object_id
	AND n.name_id = u.uos_name_id
      </querytext>
    </fullquery>

    <fullquery name="get_all_uc_uos">
      <querytext>
        SELECT n.uos_code, n.uos_name, u.uos_id, u.unit_coordinator_id,
	    s.short_name, s.pretty_name
        FROM cc_uos u,
	    cc_uos_name n,
	    workflow_cases c,
	    workflow_case_fsm f,
	    workflow_fsm_states s
	WHERE c.case_id = f.case_id
	AND s.state_id = f.current_state
	AND c.workflow_id = :workflow_id
	AND u.uos_id = c.object_id
	AND u.unit_coordinator_id = :user_id
	AND n.name_id = u.uos_name_id
      </querytext>
    </fullquery>

</queryset>
