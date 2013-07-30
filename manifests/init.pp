class dnslb ($venv = '/opt/dnslb', $dir = '/opt/dnslb',$domain = 'example.com') {
  package {'build-essential': ensure => installed}
  package {'libyaml-dev': ensure => installed}
  Package['build-essential'] -> Package['libyaml-dev']
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }
  Package['libyaml-dev'] -> Class['python']
  python::virtualenv { $venv:
    ensure => present
  }
  python::pip { 'python-dnslb':
    virtualenv => $venv
  }
  file {'dnslb-upstart':
    ensure    => file,
    path      => '/etc/init/dnslb.conf',
    content   => template('dnslb/dnslb-upstart.erb'),
    notify    => Service['dnslb']
  }
  file {'dnslb-defaults':
    ensure    => file,
    path      => '/etc/default/dnslb',
    content   => template('dnslb/dnslb-defaults.erb'),
    replace   => false,
    notify    => Service['dnslb']
  }
  file { "dnslb-config":
    path => "$dir/$domain.yaml",
    ensure => exists
  }
  service {'dnslb':
    ensure    => 'running',
    require   => [File['dnslb-upstart'],File['dnslb-defaults'],File['dnslb-config']]
  }
  File['dnslb-config'] -> Service['dnslb']
  File['dnslb-defaults] -> Service['dnslb']
  File['dnslb-upstart] -> Service['dnslb']
}
