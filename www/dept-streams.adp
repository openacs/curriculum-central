<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

#curriculum-central.all_uos_offered_by_this_department# [<a href="@all_uos_view_url@">#curriculum-central.overview_lc#</a> | <a href="">#curriculum-central.map_lc#</a>]
<p />
#curriculum-central.view_uos_by_degree_streams#
<ul>
<multiple name="streams">
<li>@streams.stream_name@ [<a href="@streams.stream_view_url@">#curriculum-central.overview_lc#</a> | <a href="@streams.stream_map_url@">#curriculum-central.map_lc#</a>]</li>
</multiple>
</ul>
