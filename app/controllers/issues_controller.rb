require 'redmine'
require_dependency 'issues_controller' 

class IssuesController < ApplicationController
	skip_before_filter :authorize, :only => [:autocomplete_for_parent]
  def autocomplete_for_parent
    @issues = Issue.find(:all, :conditions => ["LOWER(subject) LIKE ? OR id LIKE ?", "%#{params[:text]}%", "%#{params[:text]}%"],
                              :limit => 10,
                              :order => 'id ASC').uniq
    render :layout => false
  end
  private
  def retrieve_query_with_groupby
    retrieve_query_without_groupby
    if params[:query_id].blank?
      @query.group_by = params[:group_by] if params[:group_by]
    end
  end
  alias_method_chain :retrieve_query, :groupby
end