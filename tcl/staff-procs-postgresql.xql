<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.4</version></rdbms>

    <fullquery name="curriculum_central::staff::pretty_name.get_pretty_name">
      <querytext>
        SELECT s.title || ' ' || u.first_names || ' ' || u.last_name
	    AS pretty_name
	FROM cc_staff s, cc_users u
	WHERE s.staff_id = u.user_id
	AND s.staff_id = :staff_id
      </querytext>
    </fullquery>
</queryset>
