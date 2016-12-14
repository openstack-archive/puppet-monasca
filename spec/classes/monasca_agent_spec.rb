require 'spec_helper'

describe 'monasca::agent' do

  let :params do
    { :url                 => 'http://localhost:8070/v2.0',
      :username            => 'monasca-agent',
      :password            => 'password',
      :keystone_url        => 'http://localhost:5000/v3/',
      :install_python_deps => false }
  end

  shared_examples 'monasca-agent' do

    context 'with default parameters' do

      it 'sets up monasca-agent files' do
        is_expected.to contain_file('/etc/init.d/monasca-agent').with(
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
        )
      end

      it 'installs monasca-agent service' do
        is_expected.to contain_service('monasca-agent').with(
          :ensure => 'running',
        )
      end

      it 'configures various stuff' do
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*url: http:\/\/localhost:8070\/v2.0$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*username: monasca-agent$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*password: password$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*keystone_url: http:\/\/localhost:5000\/v3\/$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_name: null$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_domain_id: null$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_domain_name: null$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_id: null$/)
      end
    end

    context 'with overridden parameters' do
      before do
        params.merge!({
          :project_name        => 'test_project',
          :project_domain_id   => 'domain_id',
          :project_domain_name => 'test_domain',
          :project_id          => 'project_id',
        })
      end

      it 'configures various stuff' do
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_name: test_project$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_domain_id: domain_id$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_domain_name: test_domain$/)
        is_expected.to contain_file('/etc/monasca/agent/agent.yaml').with_content(/^\s*project_id: project_id$/)
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts)
      end
      it_behaves_like 'monasca-agent'
    end
  end
end
