Puppet::Type.type(:monasca_ini).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/monasca/monasca.ini'
  end

end
