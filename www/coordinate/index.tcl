ad_page_contract {
    Index page for coordinating a curriculum.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-11-15
    @cvs-id $Id$
}

auth::require_login

set page_title [_ curriculum-central.coordinate]
set context [list $page_title]

ad_return_template
