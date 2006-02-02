<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

#curriculum-central.view_uos_for#
<ul>
<multiple name="streams">
<li>@streams.stream_name@ [#curriculum-central.overview_lc# | <a href="@streams.stream_uos_url@">#curriculum-central.map_lc#</a>]</li>
</multiple>
</ul>

View all Units of Study offered by @department_name@