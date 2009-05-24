# To change this template, choose Tools | Templates
# and open the template in the editor.

class IssuesSubTasksHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :inline => <<-END
  <% if (!@issue.parent.nil?) %>
  <hr />
  <p><strong><%=l(:field_parent_issue)%></strong></p>
  <div id="parent">
  <%= link_to_issue(@issue.parent) %>: <%=h @issue.parent.subject %>
  </div>
  <% end %>
  <% if (@issue.children.any?) %>
  <hr />
  <p><strong><%=l(:label_subissues)%></strong></p>
  <div id="subissues">
  <%
    query = Query.new(:name => "_")
    query.project = @project
    query.column_names = [:id, :subject, :status, :start_date, :due_date]

    sort_init(query.sort_criteria.empty? ? [['id', 'desc']] : query.sort_criteria)
    sort_update({'id' => "#{Issue.table_name}.id"}.merge(query.available_columns.inject({}) {|h, c| h[c.name.to_s] = c.sortable; h}))
  %>
  <%= render :partial => 'issues/list', :locals => {:issues => @issue.children, :query => query, :group_num => 0, :level => 1, :graph => [] } %>
  </div>
  <% 
  end
  %>
END
end
