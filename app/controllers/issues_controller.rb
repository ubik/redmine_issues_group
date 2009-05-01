require 'redmine'
require_dependency 'issues_controller' 

class IssuesController < ApplicationController
	skip_before_filter :authorize, :only => [:autocomplete_for_parent]
  #before_filter :find_all_issues, :only => [:parent_edit] #:bulk_edit, :move, :destroy, 
  prepend_before_filter :find_all_issues, :authorize, :only => [:parent_edit]

  def autocomplete_for_parent
    @issues = Issue.find(:all, :conditions => ["LOWER(subject) LIKE ? OR id LIKE ?", "%#{params[:text]}%", "%#{params[:text]}%"],
                              :limit => 10,
                              :order => 'id ASC').uniq
    render :layout => false
  end
  def parent_edit
    if request.post?
      if params[:parent]
        i = Issue.find_by_id(params[:parent]) rescue nil unless params[:parent].empty? 
        if @issues.include?(i)
          flash[:error] = l(:notice_failed_to_update)
        else
          @issues.each do |issue|
            if i.nil?
              issue.move_to_root()
            else
              issue.move_to_child_of(i) 
            end
          end
          flash[:notice] = l(:notice_successful_update) unless @issues.empty?
        end
      end
      redirect_to(params[:back_to] || {:controller => 'issues', :action => 'index'}) #:project_id => @project
      return
    end
  end
  private
  def find_all_issues
    @issues = Issue.find_all_by_id(params[:id] || params[:ids])
    raise ActiveRecord::RecordNotFound if @issues.empty?
    projects = @issues.collect(&:project).compact.uniq
    @project = projects.first
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  def retrieve_query_with_groupby
    retrieve_query_without_groupby
    if params[:query_id].blank?
      @query.group_by = params[:group_by] if params[:group_by]
    end
  end
  alias_method_chain :retrieve_query, :groupby
end