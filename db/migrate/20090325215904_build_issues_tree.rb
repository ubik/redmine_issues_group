class BuildIssuesTree < ActiveRecord::Migration
  def self.up
    Issue.rebuild!
  end

  def self.down
  end
end
