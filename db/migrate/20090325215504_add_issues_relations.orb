class AddIssuesRelations < ActiveRecord::Migration
  def self.up
    add_column :issues, :parent_id, :integer, :null => true, :default => nil
    add_column :issues, :lft, :integer
    add_column :issues, :rgt, :integer
  end

  def self.down
    remove_column :issues, :parent_id
    remove_column :projects, :lft
    remove_column :projects, :rgt
  end
end
