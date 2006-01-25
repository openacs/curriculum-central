<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>

<div id="cc-stream-view-status-container">
<if @modified_p@>
<div class="modified">
<ul>
<li>#curriculum-central.status_modified#</li>
<li><a href="@publish_url@" class="button">#curriculum-central.publish#</a></li>
</ul>
</div>
</if>
<else>
<div class="published">
#curriculum-central.status_published#
</div>
</else>
</div>

<div id="cc-stream-container">
  <multiple name="stream">
  <ul id="years">
    <li>@stream.year_name@</li>
    <ul id="semesters">
      <group column="year_id">
      <li>@stream.semester_name@</li>
      <ul id="uos">
        <group column="group">
        <li><a href="@stream.edit_url@"><img src="/shared/images/Edit16.gif" /></a> | <a href="@stream.delete_url@"><img src="/shared/images/Delete16.gif" /></a><span>@stream.uos_code@ @stream.uos_name@ (@stream.core_or_not@)</span></li>
        </group>
      </ul>
      </group>
    </ul>
  </ul>
  </multiple>

  <if @not_offered:rowcount@ ne 0>
  <h2>#curriculum-central.uos_not_offered_in_any_years#</h2>
  <div class="cc-stream-view-not-offered">
  <ul>
    <multiple name="not_offered">
    <li>@not_offered.uos_code@ @not_offered.uos_name@ (<a href="@not_offered.edit_url@">#curriculum-central.edit#</a>)</li>
    </multiple>
  </ul>
  </div>
  </if>
</div>
