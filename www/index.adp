<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="admin_options">[<a href="admin/">#curriculum-central.admin#</a>]</property>
<property name="staff_options">[<a href="coordinate/">#curriculum-central.coordinate#</a>] [<a href="help">#curriculum-central.manuals#</a>]</property>

#curriculum-central.view_curriculum_for#
<ul>
<multiple name="faculties">
<li><a href="@faculties.faculty_dept_url@">@faculties.faculty_name@</a></li>
</multiple>
</ul>
