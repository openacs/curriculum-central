<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

#curriculum-central.view_uos_offered_by#
<ul>
<multiple name="depts">
<li><a href="@depts.dept_streams_url@">@depts.department_name@</a></li>
</multiple>
</ul>
