<master src="../resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="staff_options">[<a href="../help">#curriculum-central.manuals#</a>]</property>

<if @stream_coordinator_p@>
<h3>#curriculum-central.department_level_administration#</h3>
<ul>
<li><a href="uos-names">#curriculum-central.view_uos_names#</a></li>
<li><a href="uos-name-ae">#curriculum-central.add_uos_name#</a></li>
</ul>

<ul>
<li><a href="streams">#curriculum-central.view_streams#</a></li>
</ul>

<ul>
<li><a href="uos-add">#curriculum-central.add_unit_of_study#</a></li>
<li><a href="uos-all-pending">#curriculum-central.all_pending_units_of_study#</a> (@num_all_pending@ #curriculum-central.pending#)</li>
</ul>
</if>

<h3>#curriculum-central.uos_administration#</h3>
<ul>
<li><a href="uos-all">#curriculum-central.view_all_uos#</a></li>
<li><a href="uos-pending">#curriculum-central.your_pending_units_of_study#</a> (@num_users_pending@ #curriculum-central.pending#)</li>
</ul>
