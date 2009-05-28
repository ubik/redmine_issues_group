require 'redmine'
require_dependency 'issues_controller' 

class IssuesController < ApplicationController
	skip_before_filter :authorize, :only => [:autocomplete_for_parent]
  #before_filter :find_all_issues, :only => [:parent_edit] #:bulk_edit, :move, :destroy, 
  #before_filter :find_issues, :only => [:copy_subissue]
  prepend_before_filter :find_all_issues, :only => [:parent_edit, :copy_subissue] #:authorize,
  before_filter :authorize, :except => [:index, :changes, :gantt, :calendar, :preview, :update_form, :context_menu]

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
        @project = i.nil? ? nil : i.project 
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
      redirect_to(params[:back_to] || {:controller => 'issues', :action => 'index', :project_id => @project})
      return
    end
  end

  def copy_subissue
    @allowed_projects = []
    # find projects to which the user is allowed to move the issue
    if User.current.admin?
      # admin is allowed to move issues to any active (visible) project
      @allowed_projects = Project.find(:all, :conditions => Project.visible_by(User.current))
    else
      User.current.memberships.each {|m| @allowed_projects << m.project if (m.respond_to?(:roles) ? m.roles.detect {|r| r.allowed_to?(:edit_parent)} : m.role.allowed_to?(:edit_parent)) }
    end
    @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:new_project_id]} if params[:new_project_id]
    @target_project ||= @project
    @trackers = @target_project.trackers
    if request.post?
      new_tracker = params[:new_tracker_id].blank? ? nil : @target_project.trackers.find_by_id(params[:new_tracker_id])
      unsaved_issue_ids = []
      @issues.each do |issue|
        issue.init_journal(User.current)
        issue.subject = params[:new_subject]
        #unsaved_issue_ids << issue.id unless
        i2 = issue.move_to(@target_project, new_tracker, params[:copy_options])
        i2.move_to_child_of issue
        i2.save
        issue.reload
      end
      if unsaved_issue_ids.empty?
        flash[:notice] = l(:notice_successful_update) unless @issues.empty?
      else
        flash[:error] = l(:notice_failed_to_save_issues, :count => unsaved_issue_ids.size,
                                                         :total => @issues.size,
                                                         :ids => '#' + unsaved_issue_ids.join(', #'))
      end
      redirect_to :controller => 'issues', :action => 'show', :id => @issues[0].id
      return
    end
    render :layout => false if request.xhr?
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