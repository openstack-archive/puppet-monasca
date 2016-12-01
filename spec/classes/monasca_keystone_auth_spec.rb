require 'spec_helper'

describe 'monasca::keystone::auth' do

  let :params do
    {}
  end

  shared_examples 'monasca-keystone-auth' do

    context 'with default parameters' do

      it { is_expected.to contain_class('monasca::params') }

      it 'configures users' do
        is_expected.to contain_keystone_user('monasca-agent')
        is_expected.to contain_keystone_user('monasca-user')

        is_expected.to contain_keystone_role('monasca-agent')
        is_expected.to contain_keystone_role('monitoring-delegate')
        is_expected.to contain_keystone_role('monasca-admin')
        is_expected.to contain_keystone_role('monasca-user')

        is_expected.to contain_keystone_user_role('monasca-agent@services').with(
          :roles => ['monasca-agent', 'monitoring-delegate'],
        )
        is_expected.to contain_keystone_user_role('monasca-user@services').with(
          :roles => ['monasca-user'],
        )
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
      it_behaves_like 'monasca-keystone-auth'
    end
  end
end
