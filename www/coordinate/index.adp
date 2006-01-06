<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<ul>
<li><a href="tl-methods">#curriculum-central.manage_your_list_of_tl_approaches#</a></i>
<li><a href="gradattrs">#curriculum-central.manage_your_list_of_graduate_attributes#</a></li>
<li><a href="assess-methods">#curriculum-central.manage_your_list_of_assessment_methods#</a></li>
</ul>

<ul>
<if @stream_coordinator_p@>
<li><a href="uos-add">#curriculum-central.add_unit_of_study#</a></li>
</if>
<li><a href="uos-pending">#curriculum-central.your_pending_units_of_study#</a> (@num_users_pending@ #curriculum-central.pending#)</li>
<li><a href="uos-all-pending">#curriculum-central.all_pending_units_of_study#</a> (@num_all_pending@ #curriculum-central.pending#)</li>
</ul>

<h3>Things To Do</h3>
<ul>
<li>Develop Stream - Assign Units of Study to a stream (core/recommended)</li>
</ul>
