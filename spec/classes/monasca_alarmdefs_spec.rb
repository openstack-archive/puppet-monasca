require 'spec_helper'

describe 'monasca::alarmdefs' do
  describe 'on debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end
  end
end
