require 'spec_helper_acceptance'

describe 'alarmdefs class' do

  describe 'bootstrapping alarm definitions' do
    it 'we expect a failure for now' do
      tmpdir = default.tmpdir('alarmdefs')
      pp = <<-EOS
        class { 'monasca::alarmdefs':
          admin_password => 'foo',
          api_server_url => 'http://127.0.0.1:8070',
          auth_url       => 'http://127.0.0.1:5000',
          project_name   => 'project_foo',
        }
      EOS

      #
      # Since the bootstrap script will try to talk
      # to a real keystone and monasca api server.
      #
      # TODO: More comprehensive stack setup
      #
      apply_manifest(pp, :catch_failures => false)
    end
  end
end
