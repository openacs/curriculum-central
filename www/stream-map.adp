<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>

<div id="cc-stream-map-container">

  <div class="spacer">&nbsp;</div>

  <multiple name="stream">
  <ul class="years">
    <li>@stream.year_name@</li>
    <ul class="sessions">
      <group column="year_id">
      <li>@stream.session_name@</li>
      
      <ul id="uos">
        <group column="year_session_group">
        <div class="float">
          <ul>
            <li class="uos-code">@stream.uos_code@</li>  
            <li class="uos-name">@stream.uos_name@</li>
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

</div>
