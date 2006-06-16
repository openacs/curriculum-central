<tr>
  <td class="label">#curriculum-central.schedule#</td>
  <td class="value">
    <table>
      <multiple name="schedule">
      <tr>
        <td class="label">@schedule.content_label;noquote@</td>
        <td class="value">@schedule.course_content;noquote@</td>
      </tr>

      <if @schedule.assessments@ ne "">
      <tr>
        <td class="label">@schedule.assess_label;noquote@</td>
        <td class="value">@schedule.assessments;noquote@</td>
      </tr>
      </if>
      <tr><td></td></tr>
      </multiple>
    </table>
  </td>
</tr>
