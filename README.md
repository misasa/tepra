# tepra

Provide utilities for KING JIM's Tepra

# Dependency

## [King Jim SPC](http://www.kingjim.co.jp/support/tepra/software "follow instruction")


# Installation

Add this line to your application's Gemfile:

```ruby
gem 'tepra'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems
    $ gem install tepra

Have a configuration file `~/.teprarc`.  The simplest example is shown
below.  Note that name of label printer should be identical to those
listed in `Control Panel / Devices and Printers`.

    :printer: KING JIM SR3900P
    :timeout: 30
    :template: 18x18

When you want to choose a printer and paper size from list on `Tepra
Server` interface, have a configuration file as shown below.

    :printer:
      - KING JIM WR1000
      - KING JIM SR5900P-A17F52@126 # on shlef 126
      - KING JIM SR3900P
      - KING JIM SR5900P-A123E5@127 # with DREAM-Surface-2016
      - KING JIM SR5900P-A0EA7E@125 # @ SIMS 5F
      - KING JIM SR5900P-A0EA7A@121 # @ SIMS 5F
    :timeout: 30
    # :template: 18x18
    # :template: 18x50
    # :template: 18x290
    # :template: 24x50
    # :template: 36x50
    :template: 50x80
    # :template: 100x100

# Commands

Commands are summarized as:

| command          | description                                                               | note                       |
|------------------|---------------------------------------------------------------------------|----------------------------|
| tepra            | Print QR-code to King Jim's Tepra from command line or via REST interface |                            |

# Usage

See online document with option `--help`.

# Contributing

1. Fork it ( https://github.com/[my-github-username]/tepra/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Revise the documentation and reflect to rubygem

When you want to check the documentation, issue following.

    $ cd ~/devel-godigo/tepra/
    $ bundle exec rspec spec/tepra/commands/print_command_spec.rb --tag show_help:true

After revision, issue following.

    $ cd ~/devel-godigo/tepra/
    $ rake build

You see new gem on `pkg/tepra-0.0.8.gem`.  Move it to
`documentation/rubygems/gems/`, then make index.

    $ cd ~/devel-godigo/documentation/
    $ gem generate_index -d rubygems -u

Stage both `rubygems/gems/tepra-0.0.8.gem` and
`quick/Marshal.4.8/tepra-0.0.8.gemspec.rz` and push modifications.
