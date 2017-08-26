# Junk Yard: get rid of junk in your YARD docs!

JunkYard is [yard]() plugin/patch, that provides:
* structured documentation error logging;
* documentation errors validator, ready to be integrated into CI pipeline.

## Showcase

Let's generate the docs for the [rom](https://github.com/rom-rb/rom) library.

Output of `yard doc` without JunkYard: [too huge to embed in README](https://gist.github.com/zverok/6dcf946d674e63545cee9f8a74e08728)

Things to notice:

* irregular and frequently approximate addresses (`in file 'core/lib/rom/types.rb':9`,
  `in file 'core/lib/rom/global.rb' near line 41`, sometimes in separate line, sometimes inline),
  hard to jump-to with any tool;
* a lot of ununderstood metaprogramming (grep for "Undocumentable mixing") -- nothing to fix here,
  but YARD still notifies you;
* verbose and not very informative errors (look at that "Undocumentable mixin" -- and then grep
  for "The proxy Coercible has not yet been recognized." and compare).

Output of `yard doc` with JunkYard:

```
core/lib/rom/global.rb:40: [InvalidTagFormat] Invalid tag format for @example
core/lib/rom/schema.rb:144: [MissingParamName] @param tag has empty parameter name
core/lib/rom/schema.rb:300: [MissingParamName] @param tag has empty parameter name
core/lib/rom/schema.rb:311: [MissingParamName] @param tag has empty parameter name
core/lib/rom/gateway.rb:171: [UnknownParam] @param tag has unknown parameter name: Transaction
core/lib/rom/relation.rb:297: [UnknownParam] @param tag has unknown parameter name: options
core/lib/rom/relation.rb:406: [UnknownParam] @param tag has unknown parameter name: new_options
core/lib/rom/relation.rb:524: [UnknownParam] @param tag has unknown parameter name: klass
core/lib/rom/attribute.rb:339: [MissingParamName] @param tag has empty parameter name
core/lib/rom/plugin_base.rb:38: [UnknownParam] @param tag has unknown parameter name: base. Did you mean `_base`?
core/lib/rom/configuration.rb:46: [UnknownParam] @param tag has unknown parameter name: The
core/lib/rom/configuration.rb:47: [UnknownParam] @param tag has unknown parameter name: Plugin. Did you mean `plugin`?
core/lib/rom/memory/dataset.rb:54: [UnknownParam] @param tag has unknown parameter name: names
core/lib/rom/plugin_registry.rb:140: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/plugin_registry.rb:187: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/relation/loaded.rb:91: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/command_registry.rb:52: [UnknownParam] @param tag has unknown parameter name: name
core/lib/rom/relation/curried.rb:69: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/global/plugin_dsl.rb:41: [UnknownParam] @param tag has unknown parameter name: adapter
core/lib/rom/relation/combined.rb:28: [MissingParamName] @param tag has empty parameter name
core/lib/rom/commands/class_interface.rb:78: [UnknownParam] @param tag has unknown parameter name: command
core/lib/rom/commands/class_interface.rb:79: [UnknownParam] @param tag has unknown parameter name: parent
core/lib/rom/commands/class_interface.rb:108: [UnknownParam] @param tag has unknown parameter name: options. Did you mean `_options`?
core/lib/rom/commands/class_interface.rb:118: [MissingParamName] @param tag has empty parameter name
core/lib/rom/associations/definitions/abstract.rb:66: [UnknownParam] @param tag has unknown parameter name: options
changeset/lib/rom/changeset.rb:79: [UnknownParam] @param tag has unknown parameter name: options. Did you mean `new_options`?
changeset/lib/rom/changeset/stateful.rb:219: [UnknownParam] @param tag has unknown parameter name: assoc
mapper/lib/rom/header.rb:47: [UnknownParam] @param tag has unknown parameter name: model
mapper/lib/rom/processor/transproc.rb:212: [MissingParamName] @param tag has empty parameter name
core/lib/rom/types.rb:1: [UnknownNamespace] namespace Coercible is not recognized
core/lib/rom/types.rb:1: [UnknownNamespace] namespace Coercible is not recognized
core/lib/rom/types.rb:1: [UnknownNamespace] namespace Coercible is not recognized
```

Things to notice:

* Regular output style with clearly recognizable addresses (and fixed to point at actual line with
  the problematic tag, not the method which tag is related for);
* Error classes, allowing grouping, grepping, and configuring (notice no "Undocumentable xxx" errors:
  I've just configured `junk_yard` to drop them for this repo);
* Usage of Ruby's bundled `did_you_mean` gem to show reasonable suggestions:
```
Unknown tag @raises. Did you mean @raise?
@param tag has unknown parameter name: options. Did you mean `new_options`?
```
* Rephrased and cleaned up messages.

TBC.

## Usage

## Reasons

## Authors

## License
