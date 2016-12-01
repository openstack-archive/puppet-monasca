require 'spec_helper'

describe 'monasca::api' do

  let :params do
    {}
  end

  shared_examples 'monasca-api' do

    context 'with default parameters' do

      it { is_expected.to contain_class('monasca') }
      it { is_expected.to contain_class('monasca::params') }

      it 'installs monasca-api package and service' do
        is_expected.to contain_service('monasca-api').with(
          :name   => 'monasca-api',
          :ensure => 'running',
          :tag    => 'monasca-service',
        )
        is_expected.to contain_package('monasca-api').with(
          :name   => 'monasca-api',
          :ensure => 'latest',
          :tag    => ['openstack', 'monasca-package'],
        )
      end

      it 'configures various stuff' do
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*region: NA$/)
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*maxQueryLimit: 10000$/)
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*delegateAuthorizedRole: monitoring-delegate$/)
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*adminRole: monasca-admin$/)
      end
    end

    context 'with overridden parameters' do
      before do
        params.merge!({
          :region_name     => 'region1',
          :max_query_limit => 100,
          :role_delegate   => 'monitoring-delegate2',
          :role_admin      => 'monasca-admin2',
        })
      end

      it 'configures various stuff' do
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*region: region1$/)
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*maxQueryLimit: 100$/)
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*delegateAuthorizedRole: monitoring-delegate2$/)
        is_expected.to contain_file('/etc/monasca/api-config.yml').with_content(/^\s*adminRole: monasca-admin2$/)
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
      it_behaves_like 'monasca-api'
    end
  end
end
