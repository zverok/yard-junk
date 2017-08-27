# Yard-Junk: get rid of junk in your YARD docs!

Yard-Junk is [yard](https://github.com/lsegal/yard) plugin/patch, that provides:

* structured documentation error logging;
* documentation errors validator, ready to be integrated into CI pipeline.

## Showcase

Let's generate the docs for the [rom](https://github.com/rom-rb/rom) library.

Output of `yard doc` without JunkYard: [too huge to embed in README](https://gist.github.com/zverok/6dcf946d674e63545cee9f8a74e08728).

Things to notice:

* irregular and frequently approximate addresses (`in file 'core/lib/rom/types.rb':9`,
  `in file 'core/lib/rom/global.rb' near line 41`, sometimes in separate line, sometimes inline),
  hard to jump-to with any tool;
* a lot of ununderstood metaprogramming (grep for "Undocumentable mixin") -- nothing to fix here,
  but YARD still notifies you;
* verbose and not very informative errors (look at that "Undocumentable mixin" -- and then grep
  for "The proxy Coercible has not yet been recognized." and compare).

Output of `yard doc` with Yard-Junk:

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
  I've just configured `yard-junk` to drop them for this repo);
* Usage of Ruby's bundled `did_you_mean` gem to show reasonable suggestions:
```
Unknown tag @raises. Did you mean @raise?
@param tag has unknown parameter name: options. Did you mean `new_options`?
```
* Rephrased and cleaned up messages.

`yard-junk` tool output:

```
Problems
--------
mistyped tags or other typos in documentation

changeset/lib/rom/changeset.rb:79: [UnknownParam] @param tag has unknown parameter name: options. Did you mean `new_options`?
changeset/lib/rom/changeset/stateful.rb:219: [UnknownParam] @param tag has unknown parameter name: assoc
core/lib/rom/associations/definitions/abstract.rb:66: [UnknownParam] @param tag has unknown parameter name: options
core/lib/rom/attribute.rb:339: [MissingParamName] @param tag has empty parameter name
core/lib/rom/command_registry.rb:52: [UnknownParam] @param tag has unknown parameter name: name
core/lib/rom/commands/class_interface.rb:78: [UnknownParam] @param tag has unknown parameter name: command
core/lib/rom/commands/class_interface.rb:79: [UnknownParam] @param tag has unknown parameter name: parent
core/lib/rom/commands/class_interface.rb:108: [UnknownParam] @param tag has unknown parameter name: options. Did you mean `_options`?
core/lib/rom/commands/class_interface.rb:118: [MissingParamName] @param tag has empty parameter name
core/lib/rom/configuration.rb:46: [UnknownParam] @param tag has unknown parameter name: The
core/lib/rom/configuration.rb:47: [UnknownParam] @param tag has unknown parameter name: Plugin. Did you mean `plugin`?
core/lib/rom/gateway.rb:171: [UnknownParam] @param tag has unknown parameter name: Transaction
core/lib/rom/global.rb:40: [InvalidTagFormat] Invalid tag format for @example
core/lib/rom/global/plugin_dsl.rb:41: [UnknownParam] @param tag has unknown parameter name: adapter
core/lib/rom/memory/dataset.rb:54: [UnknownParam] @param tag has unknown parameter name: names
core/lib/rom/plugin_base.rb:38: [UnknownParam] @param tag has unknown parameter name: base. Did you mean `_base`?
core/lib/rom/plugin_registry.rb:140: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/plugin_registry.rb:187: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/relation.rb:297: [UnknownParam] @param tag has unknown parameter name: options
core/lib/rom/relation.rb:406: [UnknownParam] @param tag has unknown parameter name: new_options
core/lib/rom/relation.rb:524: [UnknownParam] @param tag has unknown parameter name: klass
core/lib/rom/relation/combined.rb:28: [MissingParamName] @param tag has empty parameter name
core/lib/rom/relation/curried.rb:69: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/relation/loaded.rb:91: [UnknownTag] Unknown tag @raises. Did you mean @raise?
core/lib/rom/schema.rb:144: [MissingParamName] @param tag has empty parameter name
core/lib/rom/schema.rb:300: [MissingParamName] @param tag has empty parameter name
core/lib/rom/schema.rb:311: [MissingParamName] @param tag has empty parameter name
core/lib/rom/types.rb:1: [UnknownNamespace] namespace Coercible is not recognized
core/lib/rom/types.rb:1: [UnknownNamespace] namespace Coercible is not recognized
core/lib/rom/types.rb:1: [UnknownNamespace] namespace Coercible is not recognized
mapper/lib/rom/header.rb:47: [UnknownParam] @param tag has unknown parameter name: model
mapper/lib/rom/processor/transproc.rb:212: [MissingParamName] @param tag has empty parameter name

0 failures, 32 problems (2 seconds to run)
```

It is basically the same as above, and:

* sorted by files/lines instead of "reported when found" approach;
* with short stats at the end;
* returning proper exit code (0 if no problems/parsing errors, non-0 otherwise), which allows `yard-junk`
  to be integrated into CI pipeline, and control that new PRs will not screw docs (forgetting to
  rename parameters in docs when they are renamed in code, for example).

As a nice addition, `yard-junk` command uses its own links to code objects resolver, which is 10x
faster (and, eventually, more correct) than YARD's own approach to resolve links when rendering docs.

## Usage

It is a `yard-junk` gem, install it as usual, or add to your `Gemfile`.

### Better logs

Add this to your `.yardopts` file:
```
--plugin junk
```

After that, just run `yard` or `yard doc` as usual, and enjoy better logs! You can also setup JunkYard
logs by passing options (in the same `.yardopts`):
```
--junk-log-format FORMAT_STR
--junk-log-ignore ERROR_TYPE1,ERROR_TYPE2,...
```

Format is usual Ruby's [#format](https://ruby-doc.org/core-2.2.3/Kernel.html#method-i-format) method
with named fields:
* `message` -- error message;
* `file` -- error file;
* `line` -- error line;
* `type` -- error type.

Default format is `%{file}:%{line}: [%{type}] %{message}`, as shown above.

`--junk-log-ignore` option allows to ingore error classes by their type names (shown in logs in `[]`).
By default, `Undocumentable` error is ignored: it is produced as metaprogramming pieces of code like
```ruby
attr_reader *OPTIONS
```
or
```ruby
include Rails.routes
```
...and typically have no way to fix, while polluting logs with a lot of, well, junk.

### Standalone docs check

Just run `yard-junk` command after gem is installed. It should work :)

### Rake task (integrating in CI)

Add this to your `Rakefile`:

```ruby
require 'yard-junk/rake'
YardJunk::Rake.task
```

and then run it (or add to your `.travis.yml`) as
```
rake yard:junk
```

## Reasons

## Caveats

## Roadmap

* Docs for usage as a system-wide YARD plugin;
* Docs for internals;
* Colorized output for text reporter;
* HTML reporter for CIs allowing to store build artifacts;
* Documentation quality checks as a next level of YARD checker;
* Option to check new/updated code only (integration with git history)?

## Authors

## License
