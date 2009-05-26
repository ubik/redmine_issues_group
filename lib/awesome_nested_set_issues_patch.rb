# To change this template, choose Tools | Templates
# and open the template in the editor.

module AwesomeNestedSetIssuesPatch

  def self.included(base) # :nodoc:    
    #base.send(:include, InstanceMethods)
    base.class_eval do      
      #unloadable
      alias_method :move_to_in_set, :move_to

      def move_to_left_of(node)
        move_to_in_set node, :left
      end

      # Move the node to the left of another node (you can pass id only)
      def move_to_right_of(node)
        move_to_in_set node, :right
      end

      # Move the node to the child of another node (you can pass id only)
      def move_to_child_of(node)
        move_to_in_set node, :child
      end

      # Move the node to root nodes
      def move_to_root
        move_to_in_set nil, :root
      end
    end
  end
  
end