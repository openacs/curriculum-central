#
# Set basic attributes and provide the logical defaults for variables that
# aren't provided by the slave page.
#
# $Id$
#

# fall back on defaults

if { [template::util::is_nil doc_type] } { 
    set doc_type {<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">}
}

if { [template::util::is_nil title] } { 
    set title [ad_conn instance_name]  
}

if { ![info exists header_stuff] } {
    set header_stuff {} 
}
