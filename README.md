# gem package -- tepra

Print QR-code to King Jim's Tepra via command line or REST interface

# Description

Print QR-code to King Jim's Tepra via command line or REST interface.
The program works as label-print server.  When the program is launched
without argument, it runs as web server.

See [gem package -- orochi-for-medusa](https://github.com/misasa/orochi-for-medusa) that refers to this package.
See [gem package -- godigo](https://github.com/misasa/godigo) that refers to this package.
See [gem package -- sisyphus-for-medusa](https://github.com/misasa/sisyphus-for-medusa) that refers to this package.


# Dependency

## [King Jim SPC](http://www.kingjim.co.jp/support/tepra/software "follow instruction")


# Installation

Install the package by yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems
    $ gem install tepra

Have a configuration file `~/.teprarc`.  The simplest example is shown
below.  Note that name of label printer should be identical to those
listed in `Control Panel / Devices and Printers`.

    :printer: KING JIM SR3900P
    :timeout: 30
    :template: 18x18

To print a label with barcode, issue following command.

    tepra print "20171117134145-914053,TS-SJ-54"

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

Issue following to test your revision.

    $ cd ~/devel-godigo/tepra/
    $ bundle exec rspec

After revision, issue following.

    $ cd ~/devel-godigo/tepra/
    $ rake build

You see new gem on `pkg/tepra-1.1.9.gem`.  Move it to
`documentation/rubygems/gems/`, then make index.

    $ cd ~/devel-godigo/documentation/
    $ gem generate_index -d rubygems -u

Stage both `rubygems/gems/tepra-1.1.9.gem` and
`quick/Marshal.4.8/tepra-1.1.9.gemspec.rz` and push modifications.
