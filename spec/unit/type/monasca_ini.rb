require 'puppet'
require 'puppet/type/monasca_ini'
describe 'Puppet::Type.type(:monasca_ini)' do
  before :each do
    @monasca_ini = Puppet::Type.type(:monasca_ini).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:monasca_ini).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:monasca_ini).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:monasca_ini).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:monasca_ini).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @monasca_ini[:value] = 'bar'
    expect(@monasca_ini[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @monasca_ini[:value] = 'b ar'
    expect(@monasca_ini[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @monasca_ini[:ensure] = :present
    expect(@monasca_ini[:ensure]).to eq(:present)
    @monasca_ini[:ensure] = :absent
    expect(@monasca_ini[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @monasca_ini[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end
end
