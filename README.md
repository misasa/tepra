# tepra

Print QR code labels on King Jim TEPRA printers from the command line or through
the REST API. Running `tepra` without a subcommand starts the web server.

Related projects include [orochi-for-medusa](https://github.com/misasa/orochi-for-medusa),
[godigo](https://github.com/misasa/godigo), and
[sisyphus-for-medusa](https://github.com/misasa/sisyphus-for-medusa).

## Requirements

- Ruby 2.5, 2.6, or 2.7
- Windows and [King Jim SPC software](http://www.kingjim.co.jp/support/tepra/software) for printing

## Install and configure

```sh
gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
gem install tepra
```

Create `~/.teprarc`. Use the exact printer name shown in Windows under
**Control Panel > Devices and Printers**.

```yaml
:printer: KING JIM SR3900P
:timeout: 30
:template: 18x18
```

To print a label, pass the ID and name as a comma-separated pair.

```sh
tepra print "20171117134145-914053,TS-SJ-54"
```

Run `tepra --help`, `tepra print --help`, or `tepra server --help` for details.

## Contributing

1. Fork the repository and create a feature branch.
2. Run the tests and commit your changes.
3. Push your branch and open a pull request.

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
