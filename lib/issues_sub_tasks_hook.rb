# To change this template, choose Tools | Templates
# and open the template in the editor.

class IssuesSubTasksHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :partial => "issues/subissues_list"
#  :inline =>
#<<-END
#END
end
