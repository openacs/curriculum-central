<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @admin_p@>[<a href="admin">admin</a>]</if>

<ul>
<li><a href="coordinate/">#curriculum-central.coordinate#</a></li>
</ul>

#curriculum-central.view_curriculum_for#
<ul>
<multiple name="faculties">
<li><a href="@faculties.faculty_dept_url@">@faculties.faculty_name@</a></li>
</multiple>
</ul>

<h3>Things To Do</h3>
<ul>
<li>View Unit Coordinators</li>
<li>View Catalog of Units of Study</li>
<li>View all Units of Study by Streams</li>
<li>View Course Maps</li>
</ul>
