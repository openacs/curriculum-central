ad_library {

    Curriculum Central Admin Library
    
    Procedures that deal with the admin pages.

    @creation-date 2006-02-22
    @author Nick Carroll <ncarroll@ee.usyd.edu.au>
    @cvs-id $Id$

}

namespace eval curriculum_central::admin {}
namespace eval curriculum_central::admin::default_values {}

ad_proc -private curriculum_central::admin::default_values::insert {
    {-package_id:required}
} {
    Inserts default admin values.

    @param package_id Package ID of Curriculum Central that we want to
    insert default values for.
} {
    # Insert default values for stream rels.
    curriculum_central::admin::default_values::insert_stream_rels \
	-package_id $package_id

    curriculum_central::admin::default_values::insert_years \
	-package_id $package_id

    curriculum_central::admin::default_values::insert_grade_types \
	-package_id $package_id

    curriculum_central::admin::default_values::insert_graduate_attributes \
	-package_id $package_id

    curriculum_central::admin::default_values::insert_schedule_weeks \
	-package_id $package_id
}


ad_proc -private curriculum_central::admin::default_values::insert_stream_rels {
    {-package_id:required}
} {
    Inserts default admin values for stream rels.

    @param package_id Package ID of Curriculum Central that we want to
    insert default values for.
} {
    set names "#curriculum-central.core#"
    lappend names "#curriculum-central.elective#"
    lappend names "#curriculum-central.recommended#"

    # Insert default values for stream rels.
    foreach name $names {
	package_instantiate_object \
	    -var_list [list [list package_id $package_id] \
			   [list name $name]] \
	    cc_stream_uos_rel
    }
}


ad_proc -private curriculum_central::admin::default_values::insert_years {
    {-package_id:required}
} {
    Inserts default admin values for years.

    @param package_id Package ID of Curriculum Central that we want to
    insert default values for.
} {
    set limit [parameter::get -parameter "DefaultNumDegreeStreamYears" \
		   -default 5]
    
    set names {}
    
    set x 1
    while { $x <= $limit } {
	lappend names "#curriculum-central.year# $x"
	incr x
    }

    # Insert default values for degree stream years.
    foreach name $names {
	package_instantiate_object \
	    -var_list [list [list package_id $package_id] \
			   [list name $name]] \
	    cc_year
    }
}


ad_proc -private curriculum_central::admin::default_values::insert_grade_types {
    {-package_id:required}
} {
    Inserts default admin values for grade types.

    @param package_id Package ID of Curriculum Central that we want to
    insert default values for.
} {

    # Insert default values for grade types.
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		       [list object_type cc_uos_grade_type] \
		       [list name [_ curriculum-central.high_distinction]] \
		       [list lower_bound 85] \
		       [list upper_bound 100]] \
	cc_uos_grade_type
    
    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		       [list object_type cc_uos_grade_type] \
		       [list name [_ curriculum-central.distinction]] \
		       [list lower_bound 75] \
		       [list upper_bound 84]] \
	cc_uos_grade_type

    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		       [list object_type cc_uos_grade_type] \
		       [list name [_ curriculum-central.credit]] \
		       [list lower_bound 65] \
		       [list upper_bound 74]] \
	cc_uos_grade_type

    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		       [list object_type cc_uos_grade_type] \
		       [list name [_ curriculum-central.pass]] \
		       [list lower_bound 50] \
		       [list upper_bound 64]] \
	cc_uos_grade_type

    package_instantiate_object \
	-var_list [list [list package_id $package_id] \
		       [list object_type cc_uos_grade_type] \
		       [list name [_ curriculum-central.fail]] \
		       [list lower_bound 0] \
		       [list upper_bound 49]] \
	cc_uos_grade_type
}


ad_proc -private curriculum_central::admin::default_values::insert_graduate_attributes {
    {-package_id:required}
} {
    Inserts default admin values for graduate attribute types.

    @param package_id Package ID of Curriculum Central that we want to
    insert default values for.
} {
    set attribute_names {}
    lappend attribute_names \
	"#curriculum-central.research_and_inquiry#"

    lappend attribute_names \
	"#curriculum-central.information_literacy#"

    lappend attribute_names \
	"#curriculum-central.personal_and_intellectual_autonomy#"

    lappend attribute_names \
	"#curriculum-central.ethical_social_and_professional_understanding#"

    lappend attribute_names \
	"#curriculum-central.communication#"

    # Insert default values for stream rels.
    foreach name $attribute_names {
	package_instantiate_object \
	    -var_list [list [list package_id $package_id] \
			   [list object_type cc_uos_gradattr_name] \
			   [list name $name]] \
	    cc_uos_gradattr_name
    }
}


ad_proc -private curriculum_central::admin::default_values::insert_schedule_weeks {
    {-package_id:required}
} {
    Inserts default admin values for schedule weeks

    @param package_id Package ID of Curriculum Central that we want to
    insert default values for.
} {
    set limit [parameter::get -parameter "DefaultNumScheduleWeeks" \
		   -default 13]
    
    set names {}
    
    set x 1
    while { $x <= $limit } {
	lappend names "#curriculum-central.week# $x"
	incr x
    }

    # Insert default values for scheduled weeks.
    foreach name $names {
	package_instantiate_object \
	    -var_list [list [list package_id $package_id] \
			   [list object_type cc_uos_schedule_week] \
			   [list name $name]] \
	    cc_uos_schedule_week
    }
}
