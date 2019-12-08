require 'spec_helper'

describe 'monasca::alarmdefs' do
  let :pre_condition do
    "include monasca
     include monasca::api"
  end

  shared_examples 'monasca::alarmdefs' do
    it { should contain_python__virtualenv('/var/www/monasca-alarmdefs') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'monasca::alarmdefs'
    end
  end
end
