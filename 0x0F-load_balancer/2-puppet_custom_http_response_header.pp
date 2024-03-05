# Define Nginx class
class { 'nginx':
  manage_repo    => true,
  service_ensure => 'running',
  service_enable => true,
}

# Create custom 404 page
file { '/usr/share/nginx/html/custom_404.html':
  ensure  => file,
  content => "Ceci n'est pas une page\n",
}

# Configure Nginx to use custom 404 page and add custom HTTP response header
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "
    server {
      listen 80 default_server;
      listen [::]:80 default_server;
      root /usr/share/nginx/html;
      index index.html;
      server_name _;

      location / {
        try_files \$uri \$uri/ =404;
        add_header X-Served-By \$hostname;
      }
      error_page 404 /custom_404.html;
      location = /custom_404.html {
        internal;
      }

      location /redirect_me {
        return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4;
      }
    }
  ",
  require => Class['nginx'],
}

# Restart Nginx service to apply changes
service { 'nginx':
  ensure  => running,
  enable  => true,
  require => File['/etc/nginx/sites-available/default'],
}
