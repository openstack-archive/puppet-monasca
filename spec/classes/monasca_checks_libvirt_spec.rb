require 'spec_helper'

describe 'monasca::checks::libvirt' do
  describe 'on debian platforms' do
    let :facts do
    @default_facts.merge({
      :osfamily => 'Debian',
      :os       => { 'family' => 'Debian' },
    })
    end

    let :libvirt_file do
      "/etc/monasca/agent/conf.d/libvirt.yaml"
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
      :host_aggregate_re => 'M4',
    } }

    it 'builds the libvirt config file properly' do
        is_expected.to contain_file(libvirt_file).with_content(/^\s*admin_password: password$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*admin_tenant_name: tenant_name$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*admin_user: user$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*identity_uri: uri$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*cache_dir: \/dev\/shm$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*nova_refresh: 14400$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*network_use_bits: true$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*metadata: \[\]$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*customer_metadata: \[\]$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*vm_probation: 300$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*ping_check: false$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*alive_only: false$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*disk_collection_period: 0$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*vm_cpu_check_enable: true$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*vm_disks_check_enable: true$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*vm_network_check_enable: true$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*vm_ping_check_enable: false$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*vm_extended_disks_check_enable: false$/)
        is_expected.to contain_file(libvirt_file).with_content(/^\s*host_aggregate_re: M4$/)
    end
  end
end
