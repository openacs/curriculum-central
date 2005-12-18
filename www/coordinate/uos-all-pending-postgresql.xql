<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.4</version></rdbms>

    <fullquery name="get_all_pending_uos">
      <querytext>
        SELECT u.uos_code, u.uos_name, u.uos_id, u.unit_coordinator_id,
	    s.short_name, s.pretty_name
        FROM cc_uos u,
	    workflow_cases c,
	    workflow_case_fsm f,
	    workflow_fsm_states s
	WHERE c.case_id = f.case_id
	AND s.state_id = f.current_state
	AND c.workflow_id = :workflow_id
	AND u.uos_id = c.object_id
	AND s.short_name != 'closed'
      </querytext>
    </fullquery>

</queryset>
