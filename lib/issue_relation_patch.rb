require 'issue'
require 'awesome_nested_set'

Issue.class_eval do
  acts_as_nested_set
end