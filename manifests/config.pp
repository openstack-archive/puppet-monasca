# == Class: monasca::config
#
# This class is used to manage arbitrary monasca configurations.
#
# === Parameters
#
# [*xxx_config*]
#   (optional) Allow configuration of arbitrary monasca configurations.
#   The value is an hash of xxx_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#
#   In yaml format, Example:
#   xxx_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# [*monasca_config*]
#   (optional) Allow configuration of monasca.conf configurations.
#
# [*monasca_ini*]
#   (optional) Allow configuration of monasca.ini configurations.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class monasca::config (
  $monasca_config = {},
  $monasca_ini  = {},
) {
  validate_hash($monasca_config)
  validate_hash($monasca_ini)

  create_resources('monasca_config', $monasca_config)
  create_resources('monasca_ini', $monasca_ini)
}
