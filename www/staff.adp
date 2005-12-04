<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>


<div id="cc-staff-container">
<multiple name="staff">
<ul>
<li><a href="dept?department_id=@staff.department_id@">@staff.department_name@</a>
  <ul>
  <group column="department_id">
  <li><a href="staff-member?staff_id=@staff.staff_id@">@staff.name@ (@staff.position@)</a></li>
  </group>
  </ul>
</li>
</ul>
</multiple>
</div>
