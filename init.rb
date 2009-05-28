require 'redmine'
require 'query'
require 'dispatcher'
require_dependency 'issues_helper_patch'
require 'awesome_nested_set_issues_patch'
require 'issue_relation_patch'
require 'issues_sub_tasks_hook'

Redmine::Plugin.register :redmine_issues_group do
  name 'Redmine Issues Group plugin'
  author 'Andrew Chaika'
  description 'This is a issue group plugin for Redmine'
  version '0.1.4'
  requires_redmine :version_or_higher => '0.8.0' 
  project_module :issue_tracking do
    permission :edit_parent, {:issues => [:parent_edit, :copy_subissue, :autocomplete_for_parent]}
  end
end

class RedmineIssuesParentListener < Redmine::Hook::ViewListener
  render_on :view_issues_context_menu_end, :inline => 
   "<li><%= context_menu_link l(:button_parent_edit), {:controller => 'issues', :action => 'parent_edit', :ids => @issues.collect(&:id)}," +
                           " :class => 'icon-parent-edit' %></li>"
  render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag 'stylesheet', :plugin => 'redmine_issues_group' %>"
end

Dispatcher.to_prepare do
	IssuesHelper.send(:include, IssuesHelperPatch)
	Issue.send(:include, IssueRelationPatch)
	CollectiveIdea::Acts::NestedSet::InstanceMethods.send(:include, AwesomeNestedSetIssuesPatch)
end