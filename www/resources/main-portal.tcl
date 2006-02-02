ad_page_contract {

    Simple portal page featuring a main portlet.

    @author  Nick Carroll (nick.c@rroll.net)
    @creation-date 2005-03-24
    @cvs-id  $Id$
} {

}


if { ![info exists title] } {
    set title {}
}

if { ![info exists context] } {
    set context {}
}

if { ![info exists header_stuff] } {
    set header_stuff {}
}

if { ![info exists admin_options] } {
    set admin_options {}
}

if { ![info exists staff_options] } {
    set staff_options {}
}

set user_id [ad_conn user_id]

set package_id [ad_conn package_id]

set admin_p [permission::permission_p -object_id $package_id -privilege admin]

set staff_p [curriculum_central::staff::staff_p $user_id]

set curriculum_central_css [parameter::get_from_package_key \
				-parameter "CurriculumCentralCSS" \
				-package_key "curriculum-central"]

ad_return_template