# gem package -- tepra

Print QR-code to King Jim's Tepra via command line or REST interface

# Description

Print QR-code to King Jim's Tepra via command line or REST interface.
The program works as label-print server.  When the program is launched
without argument, it runs as web server.

See [gem package -- orochi-for-medusa](https://github.com/misasa/orochi-for-medusa) that refers to this package.
See [gem package -- godigo](https://github.com/misasa/godigo) that refers to this package.
See [gem package -- sisyphus-for-medusa](https://github.com/misasa/sisyphus-for-medusa) that refers to this package.

# Requrements

Ruby 2.5, 2.6, or 2.7.

# Dependency

## [King Jim SPC](http://www.kingjim.co.jp/support/tepra/software "follow instruction")


# Installation

Install the package by yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
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

## Build and verify the gem

With Ruby 2.6.10 and Bundler 2.4.22 installed, run the specs, build the gem and
check its installed CLI.

```sh
bundle install
bundle exec rspec
bundle exec rake build
bundle exec ruby script/verify_package.rb pkg/tepra-1.2.1.gem
```

GitHub Actions builds and checks the gem after all Ruby test jobs pass. The
`tepra-gem` artifact is available in the workflow run. A stable `vVERSION`
tag on a tested `master` commit also publishes the verified gem and its
SHA-256 manifest to [GitHub Releases](https://github.com/misasa/tepra/releases).
The tag must match the version in `lib/tepra/version.rb`.

## Download and transfer from Jenkins

Use Bash, curl, `shasum` and `link` to fetch a public Release. The default
selects the latest stable Release. Use `--version` to pin the build to deploy.

```sh
bash script/download_release.sh --output-dir ./downloads
bash script/download_release.sh --version 1.2.1 --output-dir ./downloads-1.2.1
```

The helper verifies the SHA-256 manifest before saving the files. For the
Jenkins transfer step, set `TEPRA_DEPLOY_DEST` to the server and directory
configured for the job, then run the helper with `--deploy`.

```sh
export TEPRA_DEPLOY_DEST='user@server.example.edu:/absolute/web/path'
bash script/download_release.sh --version 1.2.1 --output-dir ./transfer-1.2.1 --deploy
```

The remote parent directory must already exist. Jenkins uses its existing
noninteractive SSH credentials and known host. The helper copies both assets
to a new `vVERSION` subdirectory and refuses existing local files or a remote
version directory. Use a fresh local output directory for each transfer.
After the transfer, update the gem index through the existing server-side process.
