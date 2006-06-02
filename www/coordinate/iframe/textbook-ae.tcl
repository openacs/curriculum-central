ad_page_contract {
    Add/Edit a textbook for a specific UoS.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer
    textbook_id:integer,optional
    {return_url "[export_vars -url -base textbooks-view {uos_id {edit_p 1}}]"}
}

auth::require_login

if { [info exists textbook_id] } {
    set page_title [_ curriculum-central.edit_textbook]
} else {
    set page_title [_ curriculum-central.add_textbook]
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set uos_code [db_string uos_code {} -default ""]

ad_form -name textbook -cancel_url $return_url -form {
    {textbook_id:key(acs_object_id_seq)}
    {uos_id:text(hidden) {value $uos_id}}
    {return_url:text(hidden) {value $return_url}}
    {title:text
	{html {size 50}}
	{label "[_ curriculum-central.title]" }
	{help_text "[_ curriculum-central.help_enter_textbook_title]"}
    }
    {author:text,optional
	{html {size 50}}
	{label "[_ curriculum-central.author]" }
	{help_text "[_ curriculum-central.help_enter_textbook_author]"}
    }
    {publisher:text,optional
	{html {size 50}}
	{label "[_ curriculum-central.publisher]" }
	{help_text "[_ curriculum-central.help_enter_textbook_publisher]"}
    }
    {isbn:text,optional
	{html {size 15}}
	{label "[_ curriculum-central.isbn]" }
	{help_text "[_ curriculum-central.help_enter_textbook_isbn]"}
    }
} -select_query {
       SELECT title, author, publisher, isbn
	   FROM cc_uos_textbook WHERE textbook_id = :textbook_id
} -new_data {

    db_transaction {
	set textbook_id [package_instantiate_object \
	    -var_list [list [list package_id $package_id] \
			   [list object_type cc_uos_textbook] \
			   [list title $title] \
			   [list author $author] \
			   [list publisher $publisher] \
			   [list isbn $isbn]] \
	    -form_id textbook cc_uos_textbook]

	# Retrieve the latest textbook version.
	db_1row latest_textbook {}
	# Map the textbook_id to the latest textbook version.
	db_exec_plsql map_textbook_to_revision {}
    }

} -edit_data {
    set modifying_user [ad_conn user_id]
    set modifying_ip [ad_conn peeraddr]

    db_dml textbook_update {}
    db_dml object_update {}
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
