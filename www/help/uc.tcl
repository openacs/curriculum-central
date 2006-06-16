ad_page_contract {

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

auth::require_login

set page_title [_ curriculum-central.manual_for_unit_coordinators]
set context [list [list index [_ curriculum-central.help]] [_ curriculum-central.manual]]

ad_return_template