ad_page_contract {
    Page for developing streams.

    Displays a form for mapping a Unit of Study to the given stream_id.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-01-13
    @cvs-id $Id$
} {
    stream_id:integer
    uos_id:integer,optional
    map_id:integer,optional
    {return_url "streams"}
}

auth::require_login
set user_id [ad_conn user_id]

# Only stream coordinators can develop a stream.
if { ![curriculum_central::staff::stream_coordinator_p $user_id] } {
    ad_returnredirect -message [_ curriculum-central.only_stream_coordinators_can_develop_a_stream] index
}

set stream_name [db_string stream_name {} -default ""]
set package_id [ad_conn package_id]

# If uos_id exists, then we are editing, otherwise we are creating a new
# mapping between UoS and Stream.
if { [info exists uos_id] } {
    set page_title "[_ curriculum-central.edit_uos_to_stream_mapping]: $stream_name"

    set requisite_uos_options \
	[curriculum_central::stream::all_uos_except_get_options \
	     -empty_option -except_uos_id $uos_id]

    # Create form for mapping a Unit of Study to the given stream_id.
    ad_form -name stream_map -cancel_url $return_url -form {
	{map_id:key}
	{stream_id:integer(hidden) {value $stream_id}}
	{return_url:text(hidden) {value $return_url}}
	{uos_id:integer(hidden) {value $uos_id}}
	{uos_name:text(inform)
	    {label "[_ curriculum-central.uos]"}
	    {value "[curriculum_central::uos::get_pretty_name -uos_id $uos_id]"}
	}
	{year_id:text(select)
	    {label "[_ curriculum-central.years]"}
	    {options "[curriculum_central::stream::years_for_uos_get_options -stream_id $stream_id]"}
	    {help_text "[_ curriculum-central.help_select_years_that_uos_is_offered]"}
	}
	{semester_ids:text(multiselect),multiple
	    {label "[_ curriculum-central.semesters]"}
	    {options "[curriculum_central::stream::semesters_in_a_year_get_options -stream_id $stream_id]"}
	    {html {size 5}}
	    {help_text "[_ curriculum-central.help_select_semesters_that_uos_is_offered]"}
	}
	{prerequisite_ids:text(multiselect),multiple
	    {label "[_ curriculum-central.prerequisites]"}
	    {options $requisite_uos_options}
	    {html {size 5}}
	    {help_text "[_ curriculum-central.help_select_prerequisites_for_uos]"}
	}
	{assumed_knowledge_ids:text(multiselect),multiple
	    {label "[_ curriculum-central.assumed_knowledge]"}
	    {options $requisite_uos_options}
	    {html {size 5}}
	    {help_text "[_ curriculum-central.help_select_assumed_knowledge_for_uos]"}
	}
	{corequisite_ids:text(multiselect),multiple
	    {label "[_ curriculum-central.corequisites]"}
	    {options $requisite_uos_options}
	    {html {size 5}}
	    {help_text "[_ curriculum-central.help_select_corequisites_for_uos]"}
	}
	{prohibition_ids:text(multiselect),multiple
	    {label "[_ curriculum-central.prohibitions]"}
	    {options $requisite_uos_options}
	    {html {size 5}}
	    {help_text "[_ curriculum-central.help_select_prohibitions_for_uos]"}
	}
	{no_longer_offered_ids:text(multiselect),multiple
	    {label "[_ curriculum-central.no_longer_offered]"}
	    {options $requisite_uos_options}
	    {html {size 5}}
	    {help_text "[_ curriculum-central.help_select_uos_no_longer_offered]"}
	}
    } -select_query_name {form_info} -new_data {
	# Create new CR object
	set map_id [package_instantiate_object \
	    -var_list [list \
	        [list package_id $package_id] \
		[list stream_id $stream_id] \
		[list uos_id $uos_id] \
		[list year_id $year_id] \
		[list semester_ids $semester_ids] \
		[list prerequisite_ids $prerequisite_ids] \
		[list assumed_knowledge_ids $assumed_knowledge_ids] \
		[list corequisite_ids $corequisite_ids] \
		[list prohibition_ids $prohibition_ids] \
		[list no_longer_offered_ids $no_longer_offered_ids] \
		[list object_type "cc_stream_uos_map"]] \
			       "cc_stream_uos_map"]

	# Set the latest revision as the live revision.
	db_1row get_latest_revision {}
	content::item::set_live_revision -revision_id $latest_revision_id
	db_dml set_live_revision {}
	
    } -edit_data {
	
	set modifying_user [ad_conn user_id]
	set modifying_ip [ad_conn peeraddr]
	
	# Create new revision
	set latest_revision_id [db_exec_plsql new_revision {}]
	
	# Make the new revision the live revision
	content::item::set_live_revision -revision_id $latest_revision_id
	db_dml set_live_revision {}
	
    } -after_submit {
	ad_returnredirect $return_url
	ad_script_abort
    }
    
} else {
    # Adding a new mapping, so we want to select a value for UoS.
    set page_title "[_ curriculum-central.map_uos_to_stream]: $stream_name"

    ad_form -name stream_map -cancel_url $return_url -form {
	{map_id:key}
	{stream_id:integer(hidden) {value $stream_id}}
	{return_url:text(hidden) {value $return_url}}
	{uos_id:integer(select)
	    {label "[_ curriculum-central.uos]"}
	    {options "[curriculum_central::stream::all_stream_uos]"}
	    {help_text "[_ curriculum-central.help_select_uos_to_map]"}
	    {mode edit}
	}
    } -after_submit {
	ad_returnredirect [export_vars \
			       -base stream-map-ae {stream_id uos_id map_id}]
	ad_script_abort
    }
}

set context [list [list . [_ curriculum-central.coordinate]] \
		 [list streams [_ curriculum-central.your_streams]] \
		 $page_title]

ad_return_template
