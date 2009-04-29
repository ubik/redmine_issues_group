# Provides a link to the issue age graph on the issue index page

class IssuesParentHook < Redmine::Hook::Listener
	def controller_issues_bulk_edit_before_save(context = { }) 
    if context[:params][:parent]
      if context[:params][:parent].empty? 
        context[:issue].move_to_root()
      else
        context[:issue].move_to_child_of(Issue.find_by_id(context[:params][:parent])) 
      end
    end
	end
end