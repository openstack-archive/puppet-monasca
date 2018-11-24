require 'spec_helper'

describe 'monasca::checks::ovs' do
  shared_examples 'monasca::checks::ovs' do
    let :ovs_file do
      '/etc/monasca/agent/conf.d/ovs.yaml'
    end

    let :pre_condition do
     "class { 'monasca::agent':
        url                 => 'http://127.0.0.1',
        username            => 'user',
        password            => 'password',
        keystone_url        => 'http://127.0.0.1:5000',
        install_python_deps => false,
     }"
    end

    let :params do
      {
        :admin_password    => 'password',
        :admin_tenant_name => 'tenant_name',
        :admin_user        => 'user',
        :identity_uri      => 'uri',
        :metadata          => ['tenant_name'],
      }
    end

    it 'builds the ovs config file properly' do
      should contain_file(ovs_file).with_content(/^\s*admin_password: password$/)
      should contain_file(ovs_file).with_content(/^\s*admin_tenant_name: tenant_name$/)
      should contain_file(ovs_file).with_content(/^\s*admin_user: user$/)
      should contain_file(ovs_file).with_content(/^\s*cache_dir: \/dev\/shm$/)
      should contain_file(ovs_file).with_content(/^\s*identity_uri: uri$/)
      should contain_file(ovs_file).with_content(/^\s*network_use_bits: true$/)
      should contain_file(ovs_file).with_content(/^\s*metadata: \["tenant_name"\]$/)
      should contain_file(ovs_file).with_content(/^\s*neutron_refresh: 14400$/)
      should contain_file(ovs_file).with_content(/^\s*ovs_cmd: 'sudo \/usr\/bin\/ovs-vsctl'$/)
      should contain_file(ovs_file).with_content(/^\s*included_interface_re: qg\.\*$/)
      should contain_file(ovs_file).with_content(/^\s*use_absolute_metrics: true$/)
      should contain_file(ovs_file).with_content(/^\s*use_rate_metrics: true$/)
      should contain_file(ovs_file).with_content(/^\s*use_health_metrics: true$/)
      should contain_file(ovs_file).with_content(/^\s*publish_router_capacity: true$/)
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'monasca::checks::ovs'
    end
  end
end
