# frozen_string_literal: true

begin
  require 'did_you_mean'
rescue LoadError
end

module YardJunk
  class Logger
    module Spellcheck
      # DidYouMean changed API dramatically between 1.0 and 1.1, and different rubies have different
      # versions of it bundled.
      if !Kernel.const_defined?(:DidYouMean)
        def spell_check(*)
          []
        end
      elsif DidYouMean.const_defined?(:SpellCheckable) # 1.0 +
        class SpellChecker < Struct.new(:error, :dictionary) # rubocop:disable Style/StructInheritance
          include DidYouMean::SpellCheckable

          def candidates
            {error => dictionary}
          end
        end

        def spell_check(error, dictionary)
          SpellChecker.new(error, dictionary).corrections
        end
      elsif DidYouMean.const_defined?(:SpellChecker) # 1.1+
        def spell_check(error, dictionary)
          DidYouMean::SpellChecker.new(dictionary: dictionary).correct(error)
        end
      elsif DidYouMean.const_defined?(:BaseFinder) # < 1.0
        class SpellFinder < Struct.new(:error, :dictionary) # rubocop:disable Style/StructInheritance
          include DidYouMean::BaseFinder

          def searches
            {error => dictionary}
          end
        end

        def spell_check(error, dictionary)
          SpellFinder.new(error, dictionary).suggestions
        end
      else
        def spell_check(*)
          []
        end
      end
    end
  end
end
