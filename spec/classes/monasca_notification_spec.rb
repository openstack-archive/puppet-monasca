require 'spec_helper'

describe 'monasca::notification' do
  describe 'on debian platforms' do
    let :facts do
    @default_facts.merge({
      :osfamily => 'Debian',
    })
    end

    let :cfg_file do
      "/etc/monasca/notification.yaml"
    end

    let :start_script do
      "/etc/init/monasca-notification.conf"
    end

    let :pre_condition do
     "include monasca"
    end

    let(:params) { {
      :install_python_deps => false,
    } }

    it 'starts the notification service' do
        is_expected.to contain_service('monasca-notification')
    end

    it 'builds the notification config file properly' do
        is_expected.to contain_file(cfg_file).with_content(/^\s*kafka:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*url: localhost:9092$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*group: monasca-notification$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*alarm_topic: alarm-state-transitions$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*notification_topic: alarm-notifications$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*notification_retry_topic: retry-notifications$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*max_offset_lag: 600$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*periodic:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*60: 60-seconds-notifications$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*mysql:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*host: $/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*port: 3306$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*user: $/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*passwd: $/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*db: mon$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*notification_types:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*plugins:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*- monasca_notification.plugins.hipchat_notifier:HipChatNotifier$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*- monasca_notification.plugins.slack_notifier:SlackNotifier$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*email:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*server: localhost$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*port: 25$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*notifications_size: 256$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*sent_notifications_size: 50$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*notification_path: \/notification\/alarms$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*notification_retry_path: \/notification\/retry$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*60: \/notification\/60_seconds$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*periodic_path:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*logging:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*version: 1$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*disable_existing_loggers: False$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*formatters:$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*filename: \/var\/log\/monasca\/notification.log$/)
        is_expected.to contain_file(cfg_file).with_content(/^\s*ca_certs: \/etc\/ssl\/certs\/ca-certificates.crt$/)
    end

    it 'builds the startup script properly' do
        is_expected.to contain_file(start_script).with_content(/^\s*kill timeout 240$/)
        is_expected.to contain_file(start_script).with_content(/^\s*setgid monasca$/)
        is_expected.to contain_file(start_script).with_content(/^\s*setuid monasca-notification$/)
        is_expected.to contain_file(start_script).with_content(/^\s*exec \/var\/www\/monasca-notification\/bin\/monasca-notification > \/dev\/null$/)
    end
  end
end
