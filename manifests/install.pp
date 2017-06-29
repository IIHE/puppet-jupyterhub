# == Class jupyterhub::install
#
# This class is called from jupyterhub for install.
#
class jupyterhub::install
(
  $use_nodesource = true,
)
{
  include ::nodejs

  if $use_nodesource {
    class { '::nodejs':
      repo_url_suffix => '6.x',
    }
  }
  if $::osfamily == 'Debian' {
    ensure_packages(['python3-venv'])
  }
  if $::osfamily == 'RedHat' {
    ensure_packages(['python34'])
  }

  user { $::jupyterhub::jupyterhub_username:
    ensure => present,
  }

  ~> file { $::jupyterhub::jupyterhub_dir:
    ensure => directory,
    owner  => $::jupyterhub::jupyterhub_username,
  }

  -> python::pyvenv { $::jupyterhub::pyvenv:
    ensure  => present,
    version => 'system',
    owner   => $::jupyterhub::jupyterhub_username,
    group   => $::jupyterhub::jupyterhub_group,
    require => Package['python3-venv'],
  }

  python::pip { 'jupyter':
    pkgname    => 'jupyter',
    virtualenv => $::jupyterhub::pyvenv,
    owner      => $::jupyterhub::jupyterhub_username,
    require    => Python::Pyvenv[ $::jupyterhub::pyvenv ],
  }

  python::pip { 'jupyterhub':
    pkgname    => 'jupyterhub',
    virtualenv => $::jupyterhub::pyvenv,
    owner      => $::jupyterhub::jupyterhub_username,
    require    => Python::Pyvenv[ $::jupyterhub::pyvenv ],
  }

  python::pip { 'oauthenticator':
    pkgname    => 'oauthenticator',
    virtualenv => $::jupyterhub::pyvenv,
    owner      => $::jupyterhub::jupyterhub_username,
    require    => Python::Pyvenv[ $::jupyterhub::pyvenv ],
  }

  python::pip { 'sudospawner':
    pkgname    => 'git+https://github.com/jupyter/sudospawner',
    virtualenv => $::jupyterhub::pyvenv,
    owner      => $::jupyterhub::jupyterhub_username,
    require    => Python::Pyvenv[ $::jupyterhub::pyvenv ],
  }

  package { 'configurable-http-proxy':
    ensure   => 'present',
    provider => 'npm',
  }
}
