ad_page_contract {
    Page for listing graduate attributes for a specific UoS.

    @author Nick Carroll (nick.c@rroll.net)
    @creation-date 2006-06-01
    @cvs-id $Id$
} {
    uos_id:integer,notnull
    edit_p:integer,notnull
    {orderby "name,asc"}
}

auth::require_login

set page_title "[_ curriculum-central.graduate_attributes]"
set context [list [list . [_ curriculum-central.coordinate]] $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

if { $edit_p } {
    set elements {
	edit {
	    sub_class narrow
	    display_template {
		<img src="/shared/images/Edit16.gif" height="16" width="16" border="0">
	    }
	    link_url_eval {[export_vars -url -base ga-ae { uos_id gradattr_id }]}
	    link_html {title "#curriculum-central.edit_graduate_attribute#"}
	}
	name {
	    label "#curriculum-central.name#"
	}
	level {
	    display_template {
		<switch @gradattrs.level@>
	        <case value="1">
		#curriculum-central.very_low#
	        </case>
	        <case value="2">
		#curriculum-central.low#
	        </case>
	        <case value="3">
		#curriculum-central.moderate#
	        </case>
	        <case value="4">
		#curriculum-central.high#
	        </case>
	        <case value="5">
		#curriculum-central.very_high#
	        </case>
		</switch>
	    }
	    label "#curriculum-central.level#"
	}
	description {
	    label "#curriculum-central.description#"
	    html {width "100%"}
	}
	delete {
	    sub_class narrow
	    display_template {
	    <img src="/shared/images/Delete16.gif" height="16" width="16" border="0">
	    }
	    link_url_eval {[export_vars -base ga-del { uos_id gradattr_id }]}
	    link_html {title "#curriculum-central.delete_gradattr#" onclick "return confirm(\'[_ curriculum-central.want_to_delete_gradattr]\');"}
	}
    }
    
    template::list::create \
	-name gradattrs \
	-actions [list "#curriculum-central.add_graduate_attribute#" [export_vars -base ga-ae { uos_id }] "#curriculum-central.add_graduate_attribute_to_list#"] \
	-multirow gradattrs \
	-no_data "#curriculum-central.no_graduate_attributes_created#" \
	-elements $elements \
	-orderby {
	    name {orderby {lower(n.name)}}
	} \
	-filters {uos_id {} edit_p {}} \
	-pass_properties {uos_id}
} else {
    set elements {
	name {
	    label "#curriculum-central.name#"
	}
	level {
	    display_template {
		<switch @gradattrs.level@>
	        <case value="1">
		#curriculum-central.very_low#
	        </case>
	        <case value="2">
		#curriculum-central.low#
	        </case>
	        <case value="3">
		#curriculum-central.moderate#
	        </case>
	        <case value="4">
		#curriculum-central.high#
	        </case>
	        <case value="5">
		#curriculum-central.very_high#
	        </case>
		</switch>
	    }
	    label "#curriculum-central.level#"
	}
	description {
	    label "#curriculum-central.description#"
	    html {width "100%"}
	}
    }
    
    template::list::create \
	-name gradattrs \
	-multirow gradattrs \
	-no_data "#curriculum-central.no_graduate_attributes_created#" \
	-elements $elements \
	-orderby {
	    name {orderby {lower(n.name)}}
	} \
	-filters {uos_id {} edit_p {}} \
	-pass_properties {uos_id}
}

set latest_revision_id ""
db_0or1row latest_ga {}

db_multirow gradattrs get_gradattrs {}

ad_return_template
