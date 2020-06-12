# Mudguard

**Mudguard** is a Ruby static code analyzer that investigates the coupling of modules in your source code. Mudguard
prevents your code from becoming a [Big ball of mud](http://www.laputan.org/mud/) and helps implementing and
maintaining an intended design.

Mudguard is inspired by
* [Rubocop](https://github.com/rubocop-hq/rubocop)
* Clean Architecture by Robert C. Martin (ISBN-13: 978-0-13-449416-6)
* having seen many larger code bases in a sorrow state
* my inability to efficiently break up application code into gems or rails engines

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'mudguard'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mudguard

## Quickstart
```
$ cd my/cool/ruby/project
$ mudguard
```

Mudguard creates on it's first run a file called **.mudguard.yml** which is used to configure the **design policies** 
governing your code. A .mudguard.yml could look like:
```
'./**/*.rb': # all code
  # all code can depend on siblings in same module or class
  - ^(::.+)(::[^:]+)* -> \1(::[^:]+)*$
  # all code can depend on certain types
  - .* -> ::(String|SecureRandom|Container|Time|Date|JSON|Object|Hash)$

  # in all code module Application can depend on module Domain
  - ^::Application(::[^:]+)* -> ::(Domain)(::[^:]+)*$
  # in all code module Infrastructure can depend on module Application
  - ^::Infrastructure(::[^:]+)* -> ::(Application)(::[^:]+)*$

'spec/**/*.rb': # spec code
  # Only in test code can we use RSpec, Timecop and Exception
  - .* -> ::(RSpec|Timecop|Exception)$
``` 

## The .mudguard.yml
The .mudguard.yml defines scopes and policies. A policy defines which dependencies are inside that scope permissible:
```
scope1:
    - policy 1
    - policy 2
scope2:
    - policy 3
```
The **scope** is a [glob-pattern](https://en.wikipedia.org/wiki/Glob_(programming)) and defines to which files a set
of policies apply. For example a value `lib/docker/**/*.rb` defines a scope containing all Ruby files inside 
folder lib/docker. 

A **policy** is a [regular expression](https://ruby-doc.org/core-2.5.1/Regexp.html) matching one or a set of 
dependencies that are permissible inside that scope. Mudguard represents a **dependency** as a symbol in form 
of `X -> Y` meaning "X depends on Y". See following examples:

| Policy | matched Dependency|  Explanation |
| --- | --- | --- |
| ^::A -> ::B$ | `::A -> ::B` |Module A can depend on module or constant B |
| ^::Infrastructure -> ::Rails$ | `::Infrastructure -> ::Rails` |Module Infrastructure can depend on Rails |
| ^::Infrastructure(::[^:]+)* -> ::ActiveRecord$ | `::Infrastructure::Logger -> ::ActiveRecord` or `::Infrastructure::Persistence -> ::ActiveRecord`|Module Infrastructure and its submodules can depend on ActiveRecord |
| .*   -> ::Exception$ | `::Api::Gateway` -> ::Exception or `::Logger -> ::Gateway` |Any module can depend on class Exception | 

Any dependency for which Mudguard doesn't find a matching policy is reported as an impermissible dependency.

## Outlook
Using regular expressions as policies is very flexible but difficult to use. Furthermore certain patterns used in 
the regular expressions do repeat. It might be useful to replace regular expressions in future with a specific language
to describe permissible dependencies. Any thoughts on that?

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Enceradeira/mudguard.
 This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mudguard project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mudguard/blob/master/CODE_OF_CONDUCT.md).
