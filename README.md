# Tepra

Utilities for KING JIM's Tepra

## Installation

Add this line to your application's Gemfile:

    gem 'tepra'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tepra

## Usage

tepra print

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Revise the documentation and reflect to rubygem

After revision, issue following.

    $ cd ~/orochi-devel/tepra/
    $ rake build

You see new gem on `pkg/tepra-0.0.8.gem`.  Move it to
`documentation/rubygems/gems/`, then make index.

    $ cd ~/orochi-devel/documentation/
    $ gem generate_index -d rubygems -u

Stage both `rubygems/gems/tepra-0.0.8.gem` and
`quick/Marshal.4.8/tepra-0.0.8.gemspec.rz` and push modifications.
