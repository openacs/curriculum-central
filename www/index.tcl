ad_page_contract {
    Stream listing page.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

set page_title [ad_conn instance_name]
set context [list]
set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]

# Check for streams.  If no streams, then display no-streams template.
if { 1 } {
    ad_return_template "no-streams"
    return
}

# Otherwise display list of streams.

ad_return_template
