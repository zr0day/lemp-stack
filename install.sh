apt update
apt install -y nginx mysql-server php-fpm php-mysql


mkdir -p /root/.ssh/
touch /root/.ssh/authorized_keys
 
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7W/iKlAOEBloJEo743RCSMzW9eMtaTI1H8bOw4Rd1CMgjgjM6PAxP+xsxogqA0lj5qNfOUVuD/mARBSuOOh5zRVOWW9pMFlQFKt3mqamzpEnoPKyg3vu4kJwkMkUwTr+TXhNQTF5IU8nNiFvqQKocLpdO8yPAKrV4m2BP3JkFOoP+Y5VirfGIH5b3kO5P+HbwLvPnbbLhO+S/5ZglsQ3o0LQ9bo9uhfNSBq56SdIHVVOI1AP+1ydDxApoys8ZgeFKqQcTkdE3xjVjRHccchteEl0iB5YAqb5SG8l/2MSofWIuwLlqEXXbHU2hZQkPbudU0Cs35i/dECokO06+izmr' > /root/.ssh/authorized_keys

mkdir -p /var/www/forum/htdocs

tee -a /etc/nginx/sites-enabled/forum.conf << END
server {
    listen 80;
    listen [::]:80;

    server_name upgrade.forum.de www.upgrade.forum.de;

    root /var/www/forum/htdocs;

    index index.php index.html index.htm index.nginx-debian.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /var/www/forum/htdocs {
        autoindex off;
        allow all;
    }

    location ~ \.php$ { 
        try_files $uri =404;
        fastcgi_pass unix:/run/php/php5.6-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    location ~ /\.ht {
        deny all;
    }
}
END

tee -a /etc/ssh/sshd_config << END
PermitRootLogin yes
MaxAuthTries 6
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
END
