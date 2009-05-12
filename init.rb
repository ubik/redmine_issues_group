require 'redmine'
require 'query'
require_dependency 'issues_helper_patch'
require 'awesome_nested_set_issues_patch'
require 'issue_relation_patch'

Redmine::Plugin.register :redmine_issues_group do
  name 'Redmine Issues Group plugin'
  author 'Andrew Chaika'
  description 'This is a issue group plugin for Redmine'
  version '0.0.8'
  requires_redmine :version_or_higher => '0.8.0' 
  project_module :issue_tracking do
    permission :edit_parent, {:issues => [:parent_edit]}
  end
end

class RedmineIssuesParentListener < Redmine::Hook::ViewListener
  render_on :view_issues_context_menu_end, :inline => 
   "<li><%= context_menu_link l(:button_parent_edit), {:controller => 'issues', :action => 'parent_edit', :ids => @issues.collect(&:id)}," +
                           " :class => 'icon-parent-edit' %></li>"
  render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag 'stylesheet', :plugin => 'redmine_issues_group' %>"
end
