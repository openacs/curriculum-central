<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>



<div id="cc-stream-container">
  <multiple name="stream">
  <ul id="years">
    <li>@stream.year_name@</li>
    <ul id="semesters">
      <group column="year_id">
      <li>@stream.semester_name@</li>
      <ul id="uos">
        <group column="group">
        <li><a href="@stream.edit_url@"><img src="/shared/images/Edit16.gif" height="16" width="16" border="0"></a>@stream.uos_code@ @stream.uos_name@</li>
        </group>
      </ul>
      </group>
    </ul>
  </ul>
  </multiple>
</div>