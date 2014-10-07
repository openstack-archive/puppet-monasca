#
# Class for the monasca api server
#
class monasca::apiserver {
  #
  # modules to be added to puppet file:
  #   deric-storm (? -- maybe not)
  #   puppetlabs-java (already there)
  #

  include monasca::storm
  #class {'storm::nimbus': }
}
