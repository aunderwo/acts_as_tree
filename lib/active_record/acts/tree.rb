module ActiveRecord
  module Acts
    module Tree
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Specify this +acts_as+ extension if you want to model a tree structure by providing a parent association and a children
      # association. This requires that you have a foreign key column, which by default is called +parent_id+.
      #
      #   class Category < ActiveRecord::Base
      #     acts_as_tree :order => "name"
      #   end
      #
      #   Example:
      #   root
      #    \_ child1
      #         \_ subchild1
      #         \_ subchild2
      #
      #   root      = Category.create("name" => "root")
      #   child1    = root.children.create("name" => "child1")
      #   subchild1 = child1.children.create("name" => "subchild1")
      #
      #   root.parent   # => nil
      #   child1.parent # => root
      #   root.children # => [child1]
      #   root.children.first.children.first # => subchild1
      #
      # In addition to the parent and children associations, the following instance methods are added to the class
      # after calling <tt>acts_as_tree</tt>:
      # * <tt>siblings</tt> - Returns all the children of the parent, excluding the current node (<tt>[subchild2]</tt> when called on <tt>subchild1</tt>)
      # * <tt>self_and_siblings</tt> - Returns all the children of the parent, including the current node (<tt>[subchild1, subchild2]</tt> when called on <tt>subchild1</tt>)
      # * <tt>ancestors</tt> - Returns all the ancestors of the current node (<tt>[child1, root]</tt> when called on <tt>subchild2</tt>)
      # * <tt>root</tt> - Returns the root of the current node (<tt>root</tt> when called on <tt>subchild2</tt>)
      module ClassMethods
        # Configuration options are:
        #
        # * <tt>foreign_key</tt> - specifies the column name to use for tracking of the tree (default: +parent_id+)
        # * <tt>order</tt> - makes it possible to sort the children according to this SQL snippet.
        # * <tt>counter_cache</tt> - keeps a count in a +children_count+ column if set to +true+ (default: +false+).
        def acts_as_tree(options = {})
          configuration = { :foreign_key => "parent_id", :order => nil, :counter_cache => nil }
          configuration.update(options) if options.is_a?(Hash)

          belongs_to :parent, :class_name => name, :foreign_key => configuration[:foreign_key], :counter_cache => configuration[:counter_cache]
          has_many :children, :class_name => name, :foreign_key => configuration[:foreign_key], :order => configuration[:order], :dependent => :destroy

          class_eval <<-EOV
            include ActiveRecord::Acts::Tree::InstanceMethods

            named_scope :roots, :conditions => "#{configuration[:foreign_key]} IS NULL", :order => #{configuration[:order].nil? ? "nil" : %Q{"#{configuration[:order]}"}}
            named_scope :root, :conditions => "#{configuration[:foreign_key]} IS NULL", :order => #{configuration[:order].nil? ? "nil" : %Q{"#{configuration[:order]}"}}


            validate :ensure_foreign_key_does_not_reference_self_or_all_children, :on => :update
            
            protected
            
              def ensure_foreign_key_does_not_reference_self_or_all_children
                unless new_record? # old AR versions don't seem to support the :on option for the validate method (e.g. :on => :update)
                  if self_and_all_children.collect(&:id).include?(self.#{configuration[:foreign_key]})
                    self.errors.add('#{configuration[:foreign_key]}', "can't be a reference to the current node or any of its children")
                    false
                  end
                end
              end
          EOV
        end
      end

      module InstanceMethods
        # Returns all children (recursively) of the current node.
        #
        #   parent.all_children # => [child1, child1_child1, child1_child2, child2, child2_child1, child3]
        def all_children
          self_and_all_children - [self]
        end
        
        # Returns list of ancestors, starting from parent until root.
        #
        #   subchild1.ancestors # => [child1, root]
        def ancestors
          node, nodes = self, []
          nodes << node = node.parent while node.parent
          nodes
        end
        
        # Checks if the current node is a root
        #
        #   parent.is_root? # => true
        #   child.is_root? # => false
        def is_root?
          !new_record? && self.parent.nil?
        end

        # Returns the root node of the tree.
        def root
          node = self
          node = node.parent while node.parent
          node
        end

        # Returns all siblings of the current node.
        #
        #   subchild1.siblings # => [subchild2]
        def siblings
          self_and_siblings - [self]
        end

        # Returns all children (recursively) and a reference to the current node.
        #
        #   parent.self_and_all_children # => [parent, child1, child1_child1, child1_child2, child2, child2_child1, child3]
        def self_and_all_children
          self.children.inject([self]) { |array, child| array += child.self_and_all_children }.flatten
        end

        # Returns all siblings and a reference to the current node.
        #
        #   subchild1.self_and_siblings # => [subchild1, subchild2]
        def self_and_siblings
          parent ? parent.children : self.class.roots
        end
      end
    end
  end
end
