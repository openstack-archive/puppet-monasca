source 'https://rubygems.org'

gem 'puppetlabs_spec_helper', :require => false
gem 'puppet-lint', '~> 1.0'
gem 'rake', '10.1.1'
gem 'rspec', '< 2.99'

if puppetversion = ENV['PUPPET_GEM_VERSION']
          gem 'puppet', puppetversion, :require => false
else
          gem 'puppet', :require => false
end

# vim:ft=ruby
