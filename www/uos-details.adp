<master src="resources/main-portal">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
<link rel="stylesheet" type="text/css" href="/resources/curriculum-central/curriculum-central.css" media="all">
</property>


<div id="cc-list-container">
  <table>
    <multiple name="details">
    <tr>
      <td class="label">@details.label;noquote@</td>
      <td class="value"><if @details.value@ ne "">@details.value;noquote@</if><else>&nbsp;</else></td>
    </tr>
    </multiple>

    <include src="/packages/curriculum-central/lib/tl-methods">
    <include src="/packages/curriculum-central/lib/graduate-attributes">
    <include src="/packages/curriculum-central/lib/textbooks">
    <include src="/packages/curriculum-central/lib/grades">
    <include src="/packages/curriculum-central/lib/schedule">
  </table>
</div>
