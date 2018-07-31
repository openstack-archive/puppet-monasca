require 'spec_helper'

describe 'monasca::checks::rabbitmq' do
  describe 'on debian platforms' do
    let :facts do
    @default_facts.merge({
      :osfamily => 'Debian',
      :os       => { 'family' => 'Debian' },
    })
    end

    let :rabbitmq_fragment do
      "test_instance_rabbitmq_instance"
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
      :instances => {
        'test_instance' => {
          'rabbitmq_api_url' => 'url',
          'rabbitmq_user' => 'user',
          'rabbitmq_pass' => 'password',
          'queues' => ['test_queue'],
          'nodes' => ['test_node'],
          'exchanges' => ['test_exchange'],
          'queues_regexes' => ['test_queue_regex'],
          'nodes_regexes' => ['test_node_regex'],
          'exchanges_regexes' => ['test_exchange_regex'],
          'max_detailed_queues' => 1000,
          'max_detailed_exchanges' => 100,
          'max_detailed_nodes' => 10,
          'whitelist' => {},
        }
      },
    } }

    it 'builds the rabbitmq config file properly' do
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*rabbitmq_api_url: url$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*rabbitmq_user: user$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*rabbitmq_pass: password$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*queues: \["test_queue"\]$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*nodes: \["test_node"\]$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*exchanges: \["test_exchange"\]$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*queues_regexes: \["test_queue_regex"\]$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*nodes_regexes: \["test_node_regex"\]$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*exchanges_regexes: \["test_exchange_regex"\]$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*max_detailed_queues: 1000$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*max_detailed_exchanges: 100$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*max_detailed_nodes: 10$/)
        is_expected.to contain_concat_fragment(rabbitmq_fragment).with_content(/^\s*whitelist: {}$/)
    end
  end
end
