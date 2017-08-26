# This file tries to show as much errors in documentation as possible
class A
  # Wrong macro:
  #
  # @!macro

  # @wrong Free hanging unknown tag

  # Points to unknown class: {B}
  #
  # @wrong This is unknown tag
  #
  # @param arg1 [C] Link to unknown class.
  # @param arg3 This is unknown argument.
  #
  def foo(arg1, arg2)
  end
end
