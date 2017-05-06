# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of a single string formatting utility.
      # Valid options include Kernel#format, Kernel#sprintf and String#%.
      #
      # The detection of String#% cannot be implemented in a reliable
      # manner for all cases, so only two scenarios are considered -
      # if the first argument is a string literal and if the second
      # argument is an array literal.
      class FormatString < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Favor `%s` over `%s`.'.freeze

        def_node_matcher :formatter, <<-PATTERN
        {
          (send nil ${:sprintf :format} _ _ ...)
          (send {str dstr} $:% ... )
          (send !nil $:% {array hash})
        }
        PATTERN

        def on_send(node)
          formatter(node) do |selector|
            detected_style = selector == :% ? :percent : selector

            return if detected_style == style

            add_offense(node, :selector, message(detected_style))
          end
        end

        def message(detected_style)
          format(MSG, method_name(style), method_name(detected_style))
        end

        def method_name(style_name)
          style_name == :percent ? 'String#%' : style_name
        end

        def autocorrect(node)
          if style == :percent
            lambda do |corrector|
              receiver  = node.children[2].source
              elements  = node.children[3..-1].map(&:source).join(', ')
              corrected = "#{receiver} % [#{elements}]"
              corrector.replace(node.loc.expression, corrected)
            end
          elsif node.children[1] == :%
            lambda do |corrector|
              if node.children.last.array_type?
                elements = node.children.last.children.map(&:source).join(', ')
              else
                elements = node.children[2..-1].map(&:source).join(', ')
              end
              corrected = "#{style}(#{node.children[0].source}, #{elements})"
              corrector.replace(node.loc.expression, corrected)
            end
          else
            lambda do |corrector|
              corrector.replace(node.loc.selector, style.to_s)
            end
          end
        end
      end
    end
  end
end
