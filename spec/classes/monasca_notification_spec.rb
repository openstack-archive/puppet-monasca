require 'spec_helper'

describe 'monasca::notification' do
  shared_examples 'monasca::notification' do
    let :cfg_file do
      '/etc/monasca/notification.yaml'
    end

    let :start_script do
      '/etc/init/monasca-notification.conf'
    end

    let :pre_condition do
     'include monasca'
    end

    let :params do
      {
        :install_python_deps => false,
      }
    end

    it 'starts the notification service' do
      should contain_service('monasca-notification')
    end

    it 'builds the notification config file properly' do
      should contain_file(cfg_file).with_content(/^\s*kafka:$/)
      should contain_file(cfg_file).with_content(/^\s*url: localhost:9092$/)
      should contain_file(cfg_file).with_content(/^\s*group: monasca-notification$/)
      should contain_file(cfg_file).with_content(/^\s*alarm_topic: alarm-state-transitions$/)
      should contain_file(cfg_file).with_content(/^\s*notification_topic: alarm-notifications$/)
      should contain_file(cfg_file).with_content(/^\s*notification_retry_topic: retry-notifications$/)
      should contain_file(cfg_file).with_content(/^\s*max_offset_lag: 600$/)
      should contain_file(cfg_file).with_content(/^\s*periodic:$/)
      should contain_file(cfg_file).with_content(/^\s*60: 60-seconds-notifications$/)
      should contain_file(cfg_file).with_content(/^\s*mysql:$/)
      should contain_file(cfg_file).with_content(/^\s*host: $/)
      should contain_file(cfg_file).with_content(/^\s*port: 3306$/)
      should contain_file(cfg_file).with_content(/^\s*user: $/)
      should contain_file(cfg_file).with_content(/^\s*passwd: $/)
      should contain_file(cfg_file).with_content(/^\s*db: mon$/)
      should contain_file(cfg_file).with_content(/^\s*notification_types:$/)
      should contain_file(cfg_file).with_content(/^\s*plugins:$/)
      should contain_file(cfg_file).with_content(/^\s*- monasca_notification.plugins.hipchat_notifier:HipChatNotifier$/)
      should contain_file(cfg_file).with_content(/^\s*- monasca_notification.plugins.slack_notifier:SlackNotifier$/)
      should contain_file(cfg_file).with_content(/^\s*email:$/)
      should contain_file(cfg_file).with_content(/^\s*server: localhost$/)
      should contain_file(cfg_file).with_content(/^\s*port: 25$/)
      should contain_file(cfg_file).with_content(/^\s*notifications_size: 256$/)
      should contain_file(cfg_file).with_content(/^\s*sent_notifications_size: 50$/)
      should contain_file(cfg_file).with_content(/^\s*notification_path: \/notification\/alarms$/)
      should contain_file(cfg_file).with_content(/^\s*notification_retry_path: \/notification\/retry$/)
      should contain_file(cfg_file).with_content(/^\s*60: \/notification\/60_seconds$/)
      should contain_file(cfg_file).with_content(/^\s*periodic_path:$/)
      should contain_file(cfg_file).with_content(/^\s*logging:$/)
      should contain_file(cfg_file).with_content(/^\s*version: 1$/)
      should contain_file(cfg_file).with_content(/^\s*disable_existing_loggers: False$/)
      should contain_file(cfg_file).with_content(/^\s*formatters:$/)
      should contain_file(cfg_file).with_content(/^\s*filename: \/var\/log\/monasca\/notification.log$/)
      should contain_file(cfg_file).with_content(/^\s*ca_certs: \/etc\/ssl\/certs\/ca-certificates.crt$/)
    end

    it 'builds the startup script properly' do
      should contain_file(start_script).with_content(/^\s*kill timeout 240$/)
      should contain_file(start_script).with_content(/^\s*setgid monasca$/)
      should contain_file(start_script).with_content(/^\s*setuid monasca-notification$/)
      should contain_file(start_script).with_content(/^\s*exec \/var\/www\/monasca-notification\/bin\/monasca-notification > \/dev\/null$/)
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'monasca::notification'
    end
  end
end
