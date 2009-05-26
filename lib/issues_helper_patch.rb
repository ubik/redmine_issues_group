require_dependency 'issues_helper' 

module IssuesHelperPatch
  def self.included(base) # :nodoc:    
    base.send(:include, InstanceMethods)     
    base.class_eval do      
      unloadable
      alias_method_chain :sidebar_queries, :category
    end
  end
  module InstanceMethods    
    def sidebar_queries_with_category
      unless @sidebar_queries
        # User can see public queries and his own queries
        visible = ARCondition.new(["is_public = ? OR user_id = ?", true, (User.current.logged? ? User.current.id : 0)])
        # Project specific queries and global queries
        visible << (@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id])
        @sidebar_queries = Query.find(:all, 
                                      :order => "name ASC",
                                      :conditions => visible.conditions)
      end
      @sidebar_queries
    end
    def group_issues(issues, query)
      issues = issues.select{|i| i.ancestors.size == 0 || ((issues + i.ancestors).uniq.size == issues.size+i.ancestors.size)}
      if query.group_by && query.group_by != ""
        issues.group_by {|i| column_plain_content(query.group_by.to_sym, i) }.sort()
      else
        { "" => issues }
      end
    end
    def issue_outline(issue, issue_list, level, g)
      content = ""
      (1..level-1).each do |l|
        class_name = 'space'
        class_name = 'outline-3' if (g[l-1] <= 1)
        content += content_tag 'td', '&nbsp;', :class => class_name
      end

      ind = (issue == issue_list.last)? 2 : (issue == issue_list.first ? 0 : 1)
      class_name = case ind
        when 0; level == 1 ? "outline-4" : "outline-2"
        when 1; "outline-2"
        when 2; issue == issue_list.first && level == 1 ? "outline-5" : "outline-1"
        else "space"
      end
      class_name = class_name + " has-childs open" unless issue.leaf?
      content += content_tag 'td', '&nbsp;', :class => class_name, :onclick => issue.leaf? ? "" : "toggle_sub(" + issue.id.to_s + ");"
      content
    end
    def column_header_with_spans(column)
      column.name == :subject ? "<th><span class='has-childs open' onclick='toggle_all();'>&nbsp;&nbsp;&nbsp;&nbsp;</span></th>"+sort_header_tag(column.name.to_s, :caption => column.caption, :default_order => column.default_order, :colspan => 9) :
        column_header(column)
    end
    def column_plain_content(column_name, issue)
      column = @query.available_columns.find{|c| c.name == column_name}
  		if column.nil?
  			issue.project.parent ? issue.project.parent.name : issue.project.name if column_name == :main_project
  		else
  			if column.is_a?(QueryCustomFieldColumn)
  				cv = issue.custom_values.detect {|v| v.custom_field_id == column.custom_field.id}
  				show_value(cv)
  			else
  				value = issue.send(column.name.to_s)
  				if value.is_a?(Date)
  					format_date(value)
  				elsif value.is_a?(Time)
  					format_time(value)
  				elsif column.name == :done_ratio
            value.to_s.rjust(3) << '%'
  				else
  					value.to_s
  				end
  			end
  		end
    end
  end
end