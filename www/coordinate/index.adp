<master src="../resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<h3>#curriculum-central.manage_items_related_to_your_teaching_style#</h3>
<ul>
<li><a href="tl-methods">#curriculum-central.manage_your_list_of_tl_approaches#</a></i>
<li><a href="gradattrs">#curriculum-central.manage_your_list_of_graduate_attributes#</a></li>
<li><a href="assess-methods">#curriculum-central.manage_your_list_of_assessment_methods#</a></li>
<li><a href="textbooks">#curriculum-central.manage_your_list_of_textbooks#</a></li>
</ul>

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
<li><a href="uos-all">#curriculum-central.view_all_uos#</a></li>
<li><a href="uos-add">#curriculum-central.add_unit_of_study#</a></li>
<li><a href="uos-all-pending">#curriculum-central.all_pending_units_of_study#</a> (@num_all_pending@ #curriculum-central.pending#)</li>
</ul>
</if>

<h3>#curriculum-central.uos_administration#</h3>
<ul>
<li><a href="uos-pending">#curriculum-central.your_pending_units_of_study#</a> (@num_users_pending@ #curriculum-central.pending#)</li>
</ul>
