#!/bin/bash
#本脚本只适用于openstack镜像制作。---安装好CentOS7.x系列系统的虚机,系统环境初始化脚本。
#安装所需软件包
yuminstall(){
        yum makecache 
        yum install -y acpid cloud-init cloud-utils-growpart
        sleep 2
        clear
}
#关闭selinux
downselinux(){
        echo "---系统环境开始初始化中loading---"
        echo "------"
        if grep "SELINUX=disabled" /etc/selinux/config  > /dev/null ;then
                echo "  selinux已经关闭"
                echo "------"
        else
                sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
                echo "  selinux已经关闭"
                echo "------"
        fi
}
#禁用zeroconf
downzeroconf(){
        if grep "NOZEROCONF=yes" /etc/sysconfig/network >/dev/null ;then
                echo "  zeroconf已经禁用"
                echo "------"
        else    
                echo "NOZEROCONF=yes" >> /etc/sysconfig/network
                echo "  zeroconf已经禁用"
                echo "------"
        fi
}
#网卡配置文件
initeth0(){
        cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
        TYPE="Ethernet"
        BOOTPROTO="dhcp"
        DEFROUTE="yes"
        IPV4_FAILURE_FATAL="no"
        NAME="eth0"
        DEVICE="eth0"
        ONBOOT="yes"
        
EOF
 
        echo "  网卡配置文件初始成功"
        echo "------"
}
 
#禁用ipv6
downipv6(){ 
       if grep "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf > /dev/null ;then
                echo "  整个系统所有接口的ipv6已经禁用"
        else    
                echo  "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf 
                sudo sysctl -p /etc/sysctl.conf >/dev/null
                echo "  整个系统所有接口的ipv6已经禁用"
        fi
        
        if grep "net.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf > /dev/null ;then
                echo "  默认ipv6已经禁用"
                echo "------"
        else
                echo "net.ipv6.conf.default.disable_ipv6 = 1" >>/etc/sysctl.conf
                sudo sysctl -p /etc/sysctl.conf >/dev/null 
                echo "  默认ipv6已经禁用"
                echo "------"
        fi
}
#更改grup
revisegrup(){ 
       if grep "console=tty0 console=ttyS0,115200n8" /etc/default/grub >/dev/null ;then
                echo "  grup配置已更改"
                echo "------"
        else
                sed -i 's/rhgb quiet/console=tty0 console=ttyS0,115200n8/g' /etc/default/grub 
                echo "  grup配置已更改"
                echo "------"
        fi
}
#禁止root登陆
downrootlogin(){
        if  grep "#PermitRootLogin yes" /etc/ssh/sshd_config >/dev/null ;then
                sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
                echo "  已经禁止root登陆"
        elif grep "PermitRootLogin yes" /etc/ssh/sshd_config >/dev/null ;then 
                sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config 
                echo "  已经禁止root登陆"
        elif grep "PermitRootLogin no" /etc/ssh/sshd_config >/dev/null ;then
                echo "  已经禁止root登陆" 
        else
                echo "  禁止root登陆失败"
        fi
 
 
        if grep "#PasswordAuthentication yes" /etc/ssh/sshd_config >/dev/null ;then
                sed -i 's/#PasswordAuthentication yes/#/g' /etc/ssh/sshd_config
                sed -i 's/PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
                echo "  身份验证已允许"
        elif grep "PasswordAuthentication yes" /etc/ssh/sshd_config > /dev/null ;then
                echo "  身份验证已允许"
        elif grep "PasswordAuthentication no" /etc/ssh/sshd_config > /dev/null ;then
                sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
                echo "  身份验证已允许"
        else
                echo "  身份验证允许失败"
        fi
                echo "------"
        sleep 6
        clear
}
 
setservice(){
#更新引导
        grub2-mkconfig -o /boot/grub2/grub.cfg
#设置开机自启项 
        systemctl enable acpid chronyd.service   
 
#关闭不用的服务
        systemctl disable firewalld.service 
        systemctl disable irqbalance.service
        systemctl disable tuned.service
        systemctl disable kdump.service
}
#清理工作
clena(){
        cloud-init clean
        yum clean all
        echo " " > /etc/resolv.conf
        history -c
        sleep 0.2
        clear
}
#结束提醒
over(){
        echo "----------------------------"
        echo "---镜像系统环境初始化完成---"
        echo "----------------------------"
 } 
 
 
        yuminstall
        downselinux
        downzeroconf
        initeth0
        downipv6
        revisegrup
        downrootlogin
        setservice
        clena
        over
