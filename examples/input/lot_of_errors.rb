# This file tries to show as much errors in documentation as possible

# Macros attached to class
# @!macro [attach] attached4
#  $1 $2 $3
class A
  # Wrong macro directive format:
  #
  # @!macro
  #
  # Unknown directive:
  # @!wtf


  # @wrong Free hanging unknown tag

  # Unknown macro name:
  # @!macro wtf
  # Points to unknown class: {B}
  #
  # @wrong This is unknown tag
  #
  # @param arg1 [C] Link to unknown class.
  # @param arg3 This is unknown argument.
  #
  def foo(arg1, arg2)
  end

  # @param para
  # @param para
  # @example
  # @see {invalid}
  def bar(para)
  end

  OPTIONS = %i[foo bar baz]
  # undocumentable attr_reader
  attr_reader *OPTIONS
end

# not recognize namespace
Bar::BOOKS = 5
