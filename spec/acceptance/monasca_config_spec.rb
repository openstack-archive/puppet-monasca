require 'spec_helper_acceptance'

describe 'basic monasca_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Monasca_config <||>
      File <||> -> Agent_config <||>

      file { '/etc/monasca' :
        ensure => directory,
      }
      file { '/etc/monasca/monasca.conf' :
        ensure => file,
      }
      file { '/etc/monasca/agent/agent.conf' :
        ensure => file,
      }

      monasca_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      monasca_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      monasca_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      monasca_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      agent_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      agent_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      agent_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      agent_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/monasca/monasca.conf') do
      it { should exist }
      it { should contain('thisshouldexist=foo') }
      it { should contain('thisshouldexist2=<SERVICE DEFAULT>') }

      its(:content) { should_not match /thisshouldnotexist/ }
    end

    describe file('/etc/monasca/agent/agent.conf') do
      it { should exist }
      it { should contain('thisshouldexist=foo') }
      it { should contain('thisshouldexist2=<SERVICE DEFAULT>') }

      its(:content) { should_not match /thisshouldnotexist/ }
    end

  end
end
