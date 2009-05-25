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
  <%
    @allowed_projects = []
    if User.current.admin?
      @allowed_projects = Project.find(:all, :conditions => Project.visible_by(User.current))
    else
      User.current.memberships.each {|m| @allowed_projects << m.project if m.role.allowed_to?(:edit_parent)}
    end
    @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:new_project_id]} if params[:new_project_id]
    @target_project ||= @issue.project
    @trackers = @target_project.trackers
  %>
  <hr />
  <%= render :partial => 'issues/add_subissue', :locals => { :issue => @issue } %>
  <p><strong><%=l(:label_subissues)%></strong></p>
  <% if (@issue.children.any?) %>
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
  <% content_for :header_tags do %>
    <%= stylesheet_link_tag 'jquery-ui', :plugin => 'redmine_issues_group' %>
    <%= javascript_include_tag 'jquery', :plugin => 'redmine_issues_group' %>
    <%= javascript_include_tag 'jquery-ui', :plugin => 'redmine_issues_group' %>
  <% end %>
END
end
