<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
<script language="JavaScript">
<!--
function go()
{
	box = document.ga_nav.ga_select;
	destination = box.options[box.selectedIndex].value;
	if (destination) location.href = destination;
}
// -->
</script>
</property>
<property name="user_options">[<a href="@requisites_map_url@">#curriculum-central.requisites_view#</a>]</property>

<div id="cc-stream-map-container">

  <center>
  <form name="ga_nav">
    #curriculum-central.select_a_graduate_attribute#
    <select name="ga_select" onChange="go()">
      <multiple name="ga_names">
      <if @ga_names.selected_p@>
        <option value="@ga_names.url@" selected>@ga_names.name@</option>
      </if>
      <else>
        <option value="@ga_names.url@">@ga_names.name@</option>
      </else>
      </multiple>    
    </select>
  </form>
  </center>

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

  <div class="spacer">&nbsp;</div>

  <div id="key">
    #curriculum-central.ga_key_description#
    <ul>
      <li class="ga-very-low">#curriculum-central.very_low#</li>
      <li class="ga-low">#curriculum-central.low#</li>
      <li class="ga-moderate">#curriculum-central.moderate#</li>
      <li class="ga-high">#curriculum-central.high#</li>
      <li class="ga-very-high">#curriculum-central.very_high#</li>
    </ul>
    <h3>#curriculum-central.key#</h3>
  </div>

</div>
