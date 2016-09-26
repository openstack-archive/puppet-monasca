require 'spec_helper'

describe 'monasca::checks::ovs' do
  describe 'on debian platforms' do
    let :facts do
    @default_facts.merge({
      :osfamily => 'Debian',
    })
    end

    let :ovs_file do
      "/etc/monasca/agent/conf.d/ovs.yaml"
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

    let(:params) { {
      :admin_password => 'password',
      :admin_tenant_name => 'tenant_name',
      :admin_user => 'user',
      :identity_uri => 'uri',
      :metadata => ['tenant_name'],
    } }

    it 'builds the ovs config file properly' do
        is_expected.to contain_file(ovs_file).with_content(/^\s*admin_password: password$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*admin_tenant_name: tenant_name$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*admin_user: user$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*cache_dir: \/dev\/shm$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*identity_uri: uri$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*network_use_bits: true$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*metadata: \["tenant_name"\]$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*neutron_refresh: 14400$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*ovs_cmd: 'sudo \/usr\/bin\/ovs-vsctl'$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*included_interface_re: qg\.\*$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*use_absolute_metrics: true$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*use_rate_metrics: true$/)
        is_expected.to contain_file(ovs_file).with_content(/^\s*use_health_metrics: true$/)
    end
  end
end
