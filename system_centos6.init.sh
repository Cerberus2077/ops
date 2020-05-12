#!/bin/bash
# Description: script to init configuration to new server.

#首先备份原来的cent os官方yum源
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
 
#获取阿里的yum源覆盖本地官方yum源
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
 
#清理yum缓存，并生成新的缓存
yum clean all
yum makecache

# 设置yum源头
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget -O /etc/pki/rpm-gpg/rpM-GpG-KeY-epeL-6 https://www.fedoraproject.org/static/0608B895.txt
rpm --import /etc/pki/rpm-gpg/rpM-GpG-KeY-epeL-6



#临时dns设置，用于yum下载
echo "nameserver 119.29.29.29" > /etc/resolv.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.conf

#设置ntp时间服务
/usr/bin/yum install -y ntpdate
/usr/sbin/ntpdate time1.aliyun.com
echo "*/5 * * * * /usr/sbin/ntpdate time1.aliyun.com > /dev/null 2>&1" >>/var/spool/cron/root
echo "*/5 * * * * /usr/sbin/ntpdate time2.aliyun.com > /dev/null 2>&1" >>/var/spool/cron/root
echo "*/5 * * * * /usr/sbin/ntpdate time3.aliyun.com > /dev/null 2>&1" >>/var/spool/cron/root
chmod 600 /var/spool/cron/root

#关闭防火墙
iptables -F
iptables -X
chkconfig iptables off > /dev/null 2>&1
service iptables stop > /dev/null 2>&1
sed -i 's/SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config 

#设置DNS
\cp -f /etc/resolv.conf /etc/resolv.conf.bak
> /etc/resolv.conf

echo "nameserver 119.29.29.29" >> /etc/resolv.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
/usr/bin/chattr +ai /etc/resolv.conf


#内核参数优化
/bin/cat << EOF > /etc/sysctl.conf
kernel.sysrq = 1
kernel.core_uses_pid = 1
fs.aio-max-nr = 1048576                
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024  65535
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.core.somaxconn = 65535
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.tcp_wmem = 8192 65536 16777216
net.ipv4.tcp_max_syn_backlog = 16384
net.core.netdev_max_backlog = 10000
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_max_orphans = 131072
#fs.file-max = 65536  #os can config
vm.min_free_kbytes = 1048576
vm.swappiness = 10
vm.dirty_ratio = 10
vm.vfs_cache_pressure=150
vm.drop_caches = 1
kernel.panic = 60
EOF
/sbin/sysctl -p >/dev/null 2>&1;


#ssh登陆优化
cp /etc/ssh/sshd_config{,.bak}  
#sed -e 's/\#PermitRootLogin yes/PermitRootLogin no/' -i /etc/ssh/sshd_config > /dev/null 2>&1
sed -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' -i /etc/ssh/sshd_config > /dev/null 2>&1
sed -e 's/#UseDNS yes/UseDNS no/' -i /etc/ssh/sshd_config > /dev/null 2>&1
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvLID0J6iSD53LRkoEkWnuOKfoPFnSMOGbwcO+kUkh1heEeKZ6h0P3V0cX9o6q+SMEmuVnWEvah3qDfkI84uB236ZB8hGkCZfi5Uhcd51E/p9BJ2gd8/cIOMxWjGDaKQT3YwiNzLR8n7Xl32LkvzXzU7sRDWmLZA1qemnAo0wjCPGGR1k94dwQQr2h31JVltgjlQGkkENae/+3/vVEdD4mYmYySBi/1D/v2kjTki/62EbgfdN16FMIBulhPjw7Mssi7g6KaLpdZWOlOlRTqfLIBH1Ck163Gmf3p5+KGaDrcx+YgQGVcRVyO8eoiHXDZUhs64o5rL8tqDehrChb+fShw== root@raxtone.com" > ~/.ssh/authorized_keys
#sed -i '/^PasswordAuthentication/ s/yes/no/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart > /dev/null 2>&1

#修改文件描述符数量
sed -i 's_1024_65535_g' /etc/security/limits.d/90-nproc.conf
/bin/cp /etc/security/limits.conf /etc/security/limits.conf.bak
echo '* soft nofile 65535'>>/etc/security/limits.conf
echo '* hard nofile 65535'>>/etc/security/limits.conf
echo '* soft nproc 102400'>>/etc/security/limits.conf
echo '* hard nproc 102400'>>/etc/security/limits.conf

# 安装常用软件
/usr/bin/yum groupinstall -y "Development Tools"
/usr/bin/yum install -y gcc  glibc  gcc-c++ make  lrzsz  tree  wget curl lsof dstat vim wsmancli ipmitool mtr sysstat ethtool systemtap strace 

# 修改 终端提示符
cat <<EOF>> /etc/profile
alias vi='vim'
export PS1='\n\e[1;37m[\e[m\e[1;32m\u\e[m\e[1;33m@\e[m\e[1;35m\h\e[m \e[4m\`pwd\`\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\\\$' #换行
export HISTTIMEFORMAT="%F %T \`whoami\` "
EOF
source /etc/profile

# 修改vim配置
cat <<EOF>> /etc/vim.rc
	set fo-=cro
	set ts=4
	set paste
	filetype plugin indent on
	set nu" >>/etc/vimrc

EOF

#删除确认
wget https://raw.githubusercontent.com/gavinshaw/code/master/ops-tips/securityremove.sh  -O /bin/securityremove
chmod 755 /bin/securityremove
[ -f /etc/bash.bashrc ] && (sed -i "/securityremove/d" /etc/bash.bashrc && echo 'alias rm="/bin/securityremove"' >> /etc/bash.bashrc && . /etc/bash.bashrc)
[ -f /etc/bashrc ] && (sed -i "/securityremove/d" /etc/bashrc && echo 'alias rm="/bin/securityremove"' >> /etc/bashrc && . /etc/bashrc)
[ -f /root/.bashrc ] && (sed -i "/alias rm/d" /root/.bashrc && echo 'alias rm="/bin/securityremove"' >> /root/.bashrc && . /root/.bashrc)
[[ -f "~/.bashrc" && "$USER" != "root" ]] &&(sed -i "/alias rm/d" ~/.bashrc && echo 'alias rm="/bin/securityremove"' >> ~/.bashrc && . ~/.bashrc)

# 最后重启服务器
reboot
