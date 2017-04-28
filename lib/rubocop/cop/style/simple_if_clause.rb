# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Style
      # @example
      #   # bad
      #   bad_method()
      #
      #   # bad
      #   bad_method(args)
      #
      #   # good
      #   good_method()
      #
      #   # good
      #   good_method(args)
      class SimpleIfClause < Cop
        # TODO: Implement the cop into here.
        #
        # In many cases, you can use a node matcher for matching node pattern.
        # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
        #
        # For example
        MSG = 'Replace the if-clause with "!!%s".'.freeze

        def on_if(node)
          #return if node.elsif?
          if node.if_branch.true_type? && node.else_branch.false_type?
            add_offense(node, :expression, format(MSG, node.condition.source))
          end

          if node.if_branch.false_type? && node.else_branch.true_type?
            add_offense(node, :expression, format(MSG, node.condition.source))
          end
        end
      end
    end
  end
end
