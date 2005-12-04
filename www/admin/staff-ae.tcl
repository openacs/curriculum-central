ad_page_contract {
    Add/Edit a staff member.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-20
    @cvs-id $Id$
} {
    staff_id:integer,optional
    {return_url "staff"}
}

if { [info exists staff_id] } {
    # Edit mode.
    set page_title [_ curriculum-central.edit_staff_details]

    # Create form with user's name.
    ad_form -name staff -cancel_url $return_url -form {
	{staff_id:key,integer(hidden) {value $staff_id} }
	{staff_name:string(inform)
	    {label "#curriculum-central.staff_name#"}
	    {value "[person::name -person_id $staff_id]" }
	}
    }
} else {
    # Add mode.
    set page_title [_ curriculum-central.add_staff_details]

    # Create form with drop-down list of users.
    ad_form -name staff -cancel_url $return_url -form {
	{staff_id:key,integer(select)
	    {label "#curriculum-central.staff_name#" }
	    {options [curriculum_central::non_staff_get_options] }
	    {help_text "[_ curriculum-central.help_select_staff_member]"}
	}
    }

}

set context [list $page_title]
set package_id [ad_conn package_id]


ad_form -extend -name staff -form {
    {return_url:text(hidden) {value $return_url}}
    {title:text
	{html {size 50}}
	{label "#curriculum-central.staff_title#" }
	{help_text "[_ curriculum-central.help_enter_staff_title]"}
    }
    {position:text
	{html {size 50}}
	{label "#curriculum-central.staff_position#" }
	{help_text "[_ curriculum-central.help_enter_staff_position]"}
    }
    {department_id:integer(select)
	{label "#curriculum-central.department#" }
	{options [curriculum_central::departments_get_options] }
	{help_text "[_ curriculum-central.help_select_staff_member_department]"}
    }
    {address_line_1:text,optional
	{html {size 50}}
	{label "#curriculum-central.address_line_1#"}
	{help_text "[_ curriculum-central.help_enter_address_line_1]"}
    }
    {address_line_2:text,optional
	{html {size 50}}
	{label "#curriculum-central.address_line_2#"}
	{help_text "[_ curriculum-central.help_enter_address_line_2]"}
    }
    {address_suburb:text,optional
	{html {size 50}}
	{label "#curriculum-central.suburb#"}
	{help_text "[_ curriculum-central.help_enter_suburb]"}
    }
    {address_state:text,optional
	{html {size 50}}
	{label "#curriculum-central.state#"}
	{help_text "[_ curriculum-central.help_enter_state]"}
    }
    {address_postcode:text,optional
	{html {size 50}}
	{label "#curriculum-central.postcode#"}
	{help_text "[_ curriculum-central.help_enter_postcode]"}
    }
    {address_country:text,optional
	{html {size 50}}
	{label "#curriculum-central.country#"}
	{help_text "[_ curriculum-central.help_enter_country]"}
    }
    {phone:text,optional
	{html {size 50}}
	{label "#curriculum-central.phone#"}
	{help_text "[_ curriculum-central.help_enter_phone]"}
    }
    {fax:text,optional
	{html {size 50}}
	{label "#curriculum-central.fax#"}
	{help_text "[_ curriculum-central.help_enter_fax]"}
    }
    {homepage_url:text,optional
	{html {size 50}}
	{label "#curriculum-central.homepage_url#"}
	{help_text "[_ curriculum-central.help_enter_homepage_url]"}
    }
} -select_query {
       SELECT title, position, department_id, address_line_1,
           address_line_2, address_suburb, address_state, address_postcode,
           address_country, phone, fax, homepage_url
	   FROM cc_staff WHERE staff_id = :staff_id
} -new_data {
    package_instantiate_object \
	-var_list [list [list staff_id $staff_id] \
		        [list title $title] \
		        [list position $position] \
		        [list department_id $department_id] \
  		        [list address_line_1 $address_line_1] \
  		        [list address_line_2 $address_line_2] \
  		        [list address_suburb $address_suburb] \
  		        [list address_state $address_state] \
  		        [list address_postcode $address_postcode] \
  		        [list address_country $address_country] \
		        [list phone $phone] \
		        [list fax $fax] \
 		        [list homepage_url $homepage_url]] \
	-form_id staff cc_staff
} -edit_data {
    db_dml staff_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
