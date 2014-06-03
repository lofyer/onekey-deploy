#!/bin/bash
EXT_URL=http://gitlab.example.com
DATA_DIR=/gitlab_data
GIT_USER=gitlab
GIT_GROUP=gitlab

yum install openssh-server postfix

wget https://downloads-packages.s3.amazonaws.com/centos-6.5/gitlab-6.9.2_omnibus-1.el6.x86_64.rpm

rpm -i gitlab-6.9.2_omnibus-1.el6.x86_64.rpm

mkdir -p /etc/gitlab
touch /etc/gitlab/gitlab.rb
chmod 600 /etc/gitlab/gitlab.rb

cat >> /etc/gitlab/gitlab.rb << EOF
git_data_dir "$DATA_DIR"
user['username'] = "$GIT_USER"
user['group'] = "$GIT_GROUP"
external_url "EXT_URL"
EOF

gitlab-ctl reconfigure
