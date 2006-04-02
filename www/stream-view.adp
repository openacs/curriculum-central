<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>
<if @export_p@><property name="user_options">[<a href="@export_url@">#curriculum-central.export#</a>]</property></if>

<div id="cc-stream-container">
  <multiple name="stream">
  <ul id="years">
    <li>@stream.year_name@</li>
    <ul id="sessions">
      <group column="year_id">
      <li>@stream.session_name@</li>
      <ul id="uos">
        <group column="year_session_group">
        <li><span class="label">@stream.uos_code@ @stream.uos_name@ (@stream.rel_name@)</span><span class="options"><a href="@stream.uos_details_url@" class="button">#curriculum-central.view_details#</a></span><div class="spacer"></div></li>
        </group>
      </ul>
      </group>
    </ul>
  </ul>
  </multiple>
</div>
