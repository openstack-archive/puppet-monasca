require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_parameter_order')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.show_ignored = true

PuppetSyntax.future_parser = true
PuppetSyntax.hieradata_paths = [ "files/**/*.yaml" ]

# Set the config file location to /dev/null so that if we're running this on a
# build server, it doesn't find the local puppet.conf and generate deprecation
# warnings.  We want to test manifests, not puppet.conf
Puppet.settings[:config] = '/dev/null'

desc 'Run all syntax checks, unit tests, lint, etc'
task :test => [ :syntax, :spec, :lint ]

task(:default).clear
task :default => :test
