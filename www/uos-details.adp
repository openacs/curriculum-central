<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>

<center>
<div id="cc-list-container">
  <div class="row">
    <span class="label">#curriculum-central.unit_coordinator#</span>
    <span class="value"><if @unit_coordinator_pretty_name@ ne "">@unit_coordinator_pretty_name@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.credit_value#</span>
    <span class="value"><if @credit_value@ ne "">@credit_value@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.sessions#</span>
    <span class="value"><if @session_names@ ne "">@session_names@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.online_course_content#</span>
    <span class="value"><if @online_course_content@ ne "">@online_course_content@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.aims_and_objectives#</span>
    <span class="value"><if @objectives@ ne "">@objectives@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.learning_outcomes#</span>
    <span class="value"><if @learning_outcomes@ ne "">@learning_outcomes@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.syllabus#</span>
    <span class="value"><if @syllabus@ ne "">@syllabus@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.relevance#</span>
    <span class="value"><if @relevance@ ne "">@relevance@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.contact_hours#</span>
    <span class="value"><if @formal_contact_hrs@ ne "">@formal_contact_hrs@</if><else>&nbsp;</else></span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.assessments#</span>
    <span class="value">TODO</span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.core_uos_for#</span>
    <span class="value">TODO</span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.recommended_uos_for#</span>
    <span class="value">TODO</span>
  </div>
  <div class="row">
    <span class="label">#curriculum-central.prerequisites#</span>
    <span class="value">TODO</span>
  </div>
  <div class="spacer"></div>
</div>
</center>