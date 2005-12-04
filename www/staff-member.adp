<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>


Need to display the following:

<ul>
<li>portrait</li>
<li>name: @name@</li>
<li>position: @position@</li>
<li>address: @address@</li>
<li>email: @email@</li>
<if @phone@ ne ""><li>phone number: @phone@</li></if>
<if @fax@ ne ""><li>fax number: @fax@</li></if>
<if @homepage_url@ ne ""><li>personal home page: @homepage_url@</li></if>
</ul>