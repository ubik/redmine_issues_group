require 'issue'
require 'awesome_nested_set'

module IssueRelationPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      acts_as_nested_set
    end
  end
end