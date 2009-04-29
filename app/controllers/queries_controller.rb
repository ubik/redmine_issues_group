require 'redmine'
require_dependency 'queries_controller' 

class QueriesController < ApplicationController
	skip_before_filter :find_query, :only => [:autocomplete_for_category]
  def edit_with_groupby
    if request.post?
      @query.group_by = params[:group_by]
    end
    edit_without_groupby
  end
  alias_method_chain :edit, :groupby
  def new
    @query = Query.new(params[:query])
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.user = User.current
    @query.is_public = false unless (@query.project && current_role.allowed_to?(:manage_public_queries)) || User.current.admin?
    @query.column_names = nil if params[:default_columns]
    @query.group_by = params[:group_by] if params[:group_by]
    
    params[:fields].each do |field|
      @query.add_filter(field, params[:operators][field], params[:values][field])
    end if params[:fields]
    
    if request.post? && params[:confirm] && @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :controller => 'issues', :action => 'index', :project_id => @project, :query_id => @query
      return
    end
    render :layout => false if request.xhr?
  end  
  def autocomplete_for_category
    @categories = Query.find(:all, :conditions => ["LOWER(category) LIKE ?", "#{params[:category]}%"],
                              :limit => 10,
                              :order => 'category ASC').collect{|q| q.category}.uniq
    render :layout => false
  end
end