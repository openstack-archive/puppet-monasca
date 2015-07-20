puppet-monasca
=============

#### Table of Contents

1. [Overview - What is the monasca module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with monasca](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The monasca module is a part of [OpenStack](https://github.com/openstack), and is meant to assist with the installation and configuration of monasca itself, and its dependent services (mentioned below).

Module Description
------------------

Setup
-----

**What the monasca module affects:**

* monasca, monitoring as a service for Openstack.
* storm, Apache's distributed realtime computational system.
* kafka, Apache's publish-subscribe messaging system.
* influxdb, a stand-alone open-source distributes time series database.

Implementation
--------------

### monasca

monasca is a combination of Puppet manifest that configures the monasca client and server configuration, as well as monasca's dependent services.

Limitations
-----------
This module currently only supports debian based installs.

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/stackforge/puppet-monasca/graphs/contributors
