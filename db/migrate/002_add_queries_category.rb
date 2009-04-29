  class AddQueriesCategory < ActiveRecord::Migration
    def self.up
      add_column :queries, :category, :string
    end

    def self.down
      remove_column :queries, :category
    end
  end
