<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>
<property name="user_options">[<a href="@ga_map_url@">#curriculum-central.graduate_attributes#</a>]<if @export_p>[<a href="@export_url@">#curriculum-central.export#</a>]</if></property>

<div id="cc-stream-map-container">

  <div class="spacer">&nbsp;</div>

  <if @selected_uos_id@ ne "">
  <div id="key">
    #curriculum-central.requisite_key_description#
    <ul>
      <li class="selected">#curriculum-central.selected_uos#</li>
      <li class="prerequisite">#curriculum-central.prerequisite#</li>
      <li class="assumed-knowledge">#curriculum-central.assumed_knowledge#</li>
    </ul>
    <ul>
      <li class="corequisite">#curriculum-central.corequisite#</li>
      <li class="prohibition">#curriculum-central.prohibition#</li>
      <li class="no-longer-offered">#curriculum-central.no_longer_offered#</li>
    </ul>
    <h3>#curriculum-central.key#</h3>
  </div>
  </if>

  <multiple name="stream">
  <ul class="years">
    <li>@stream.year_name@</li>
    <ul class="sessions">
      <group column="year_id">
      <li>@stream.session_name@</li>
      
      <ul id="uos">
        <group column="year_session_group">
        <div class="@stream.float_class@">
          <ul class="info">
            <li class="uos-code">@stream.uos_code@</li>  
            <li class="uos-name">@stream.uos_name@</li>
          </ul>
	  <ul class="options">
            <li class="info"><a href="@stream.uos_details_url@" class="button">#curriculum-central.view_details#</a></li>
            <li class="info"><a href="@stream.uos_requisites_url@" class="button">#curriculum-central.requisites#</a></li>
          </ul>
        </div>
        </group>

        <div class="spacer">&nbsp;</div>
      </ul>

      </group>
    </ul>
  </ul>
  </multiple>

  <div class="spacer">&nbsp;</div>

</div>
