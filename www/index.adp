<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @admin_p@>[<a href="admin">admin</a>]</if>

<ul>
<li><a href="uos-add">Add Unit of Study</a></li>
</ul>

View curriculum for:
<ul>
<multiple name="faculties">
<li><a href="@faculties.faculty_dept_url@">@faculties.faculty_name@</a></li>
</multiple>
</ul>
