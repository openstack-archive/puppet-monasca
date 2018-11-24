require 'spec_helper'

describe 'monasca::checks::libvirt' do
  shared_examples 'monasca::checks::libvirt' do
    let :libvirt_file do
      '/etc/monasca/agent/conf.d/libvirt.yaml'
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
        :host_aggregate_re => 'M4',
      }
    end

    it 'builds the libvirt config file properly' do
        should contain_file(libvirt_file).with_content(/^\s*admin_password: password$/)
        should contain_file(libvirt_file).with_content(/^\s*admin_tenant_name: tenant_name$/)
        should contain_file(libvirt_file).with_content(/^\s*admin_user: user$/)
        should contain_file(libvirt_file).with_content(/^\s*identity_uri: uri$/)
        should contain_file(libvirt_file).with_content(/^\s*cache_dir: \/dev\/shm$/)
        should contain_file(libvirt_file).with_content(/^\s*nova_refresh: 14400$/)
        should contain_file(libvirt_file).with_content(/^\s*network_use_bits: true$/)
        should contain_file(libvirt_file).with_content(/^\s*metadata: \[\]$/)
        should contain_file(libvirt_file).with_content(/^\s*customer_metadata: \[\]$/)
        should contain_file(libvirt_file).with_content(/^\s*vm_probation: 300$/)
        should contain_file(libvirt_file).with_content(/^\s*ping_check: false$/)
        should contain_file(libvirt_file).with_content(/^\s*alive_only: false$/)
        should contain_file(libvirt_file).with_content(/^\s*disk_collection_period: 0$/)
        should contain_file(libvirt_file).with_content(/^\s*vm_cpu_check_enable: true$/)
        should contain_file(libvirt_file).with_content(/^\s*vm_disks_check_enable: true$/)
        should contain_file(libvirt_file).with_content(/^\s*vm_network_check_enable: true$/)
        should contain_file(libvirt_file).with_content(/^\s*vm_ping_check_enable: false$/)
        should contain_file(libvirt_file).with_content(/^\s*vm_extended_disks_check_enable: false$/)
        should contain_file(libvirt_file).with_content(/^\s*host_aggregate_re: M4$/)
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'monasca::checks::libvirt'
    end
  end
end
