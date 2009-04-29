require 'redmine'
require 'query'
require_dependency 'issues_helper_patch'
require 'issue_relation_patch'
require 'issues_parent_hook'

Redmine::Plugin.register :redmine_issues_group do
  name 'Redmine Issues Group plugin'
  author 'Andrew Chaika'
  description 'This is a issue group plugin for Redmine'
  version '0.0.7'
  requires_redmine :version_or_higher => '0.8.0' 
end