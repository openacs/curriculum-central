<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<multiple name="stream">
@stream.year_name@<br />
<group column="year_id">
@stream.semester_name@<br />
<group column="semester_id">
@stream.uos_code@ @stream.uos_name@ <a href="stream-map-ae?stream_id=@stream_id@&uos_id=@stream.uos_id@&map_id=@stream.map_id@"><img src="/shared/images/Edit16.gif" height="16" width="16" border="0"></a><p />
</group>
</group>
</multiple>