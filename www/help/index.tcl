ad_page_contract {
    Stream listing page.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

auth::require_login

set page_title [_ curriculum-central.user_manual]
set context [_ curriculum-central.help]

ad_return_template