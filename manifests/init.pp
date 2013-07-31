class dnslb ($dir = '/opt/dnslb', $zone = 'example.com.json',$config = 'example.com.yaml') {
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }
  python::virtualenv { $dir:
    ensure => present
  }
  python::pip { 'python-dnslb':
    virtualenv => $dir,
    ensure     => latest
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
  service {'dnslb':
    ensure    => 'running',
    require   => [File['dnslb-upstart'],File['dnslb-defaults']]
  }
  File['dnslb-defaults'] -> Service['dnslb']
  File['dnslb-upstart'] -> Service['dnslb']
}
