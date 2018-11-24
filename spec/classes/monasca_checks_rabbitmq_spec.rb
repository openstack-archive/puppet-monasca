require 'spec_helper'

describe 'monasca::checks::rabbitmq' do
  shared_examples 'monasca::checks::rabbitmq' do
    let :rabbitmq_fragment do
      'test_instance_rabbitmq_instance'
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
        :instances => {
          'test_instance' => {
            'rabbitmq_api_url'       => 'url',
            'rabbitmq_user'          => 'user',
            'rabbitmq_pass'          => 'password',
            'queues'                 => ['test_queue'],
            'nodes'                  => ['test_node'],
            'exchanges'              => ['test_exchange'],
            'queues_regexes'         => ['test_queue_regex'],
            'nodes_regexes'          => ['test_node_regex'],
            'exchanges_regexes'      => ['test_exchange_regex'],
            'max_detailed_queues'    => 1000,
            'max_detailed_exchanges' => 100,
            'max_detailed_nodes'     => 10,
            'whitelist'              => {},
          }
        }
      }
    end

    it 'builds the rabbitmq config file properly' do
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*rabbitmq_api_url: url$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*rabbitmq_user: user$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*rabbitmq_pass: password$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*queues: \["test_queue"\]$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*nodes: \["test_node"\]$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*exchanges: \["test_exchange"\]$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*queues_regexes: \["test_queue_regex"\]$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*nodes_regexes: \["test_node_regex"\]$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*exchanges_regexes: \["test_exchange_regex"\]$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*max_detailed_queues: 1000$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*max_detailed_exchanges: 100$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*max_detailed_nodes: 10$/)
      should contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*whitelist: {}$/)
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'monasca::checks::rabbitmq'
    end
  end
end
