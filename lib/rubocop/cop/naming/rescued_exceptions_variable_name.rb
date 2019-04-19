# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that rescued exceptions variables are named as
      # expected.
      #
      # The `PreferredName` config option takes a `String`. It represents
      # the required name of the variable. Its default is `e`.
      #
      # @example PreferredName: e (default)
      #   # bad
      #   begin
      #     # do something
      #   rescue MyException => exception
      #     # do something
      #   end
      #
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => e
      #     # do something
      #   end
      #
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => _e
      #     # do something
      #   end
      #
      # @example PreferredName: exception
      #   # bad
      #   begin
      #     # do something
      #   rescue MyException => e
      #     # do something
      #   end
      #
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => exception
      #     # do something
      #   end
      #
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => _exception
      #     # do something
      #   end
      #
      class RescuedExceptionsVariableName < Cop
        MSG = 'Use `%<preferred>s` instead of `%<bad>s`.'.freeze

        def on_resbody(node)
          exception_type, exception_name = *node
          return unless exception_type || exception_name

          exception_name ||= exception_type.children.first
          return if exception_name.const_type? ||
                    variable_name(exception_name) == preferred_name(exception_name)

          add_offense(node, location: location(exception_name))
        end

        def autocorrect(node)
          lambda do |corrector|
            _, exception_name = *node
            corrector.replace(location(exception_name), preferred_name)
          end
        end

        private

        def preferred_name(exception_name)
          name = cop_config.fetch('PreferredName', 'e')
          name = "_#{name}" if variable_name(exception_name).to_s.start_with?('_')
          name
        end

        def variable_name(exception_name)
          location(exception_name).source
        end

        def location(exception_name)
          exception_name.loc.expression
        end

        def message(node)
          _, exception_name = *node
          format(MSG, preferred: preferred_name(exception_name), bad: variable_name(exception_name))
        end
      end
    end
  end
end
