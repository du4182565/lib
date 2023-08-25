#!/bin/bash
# author alain
# site:https://www.alainlam.cn
# 循环检测Samba服务器是否在线，并自动挂载
# 本脚本会将日志写入到系统日志，如果你的NAS不是长时间在线，请酌情修改脚本内容，以免日志文件过多

server_ip="你的IP地址"
server_path="/你需要存放PVE文件的路径"
mount_point="/mnt/pve/挂载到PVE本地的目录"
# 是否循环检查是否在线(没有挂载时)
online_check=true
# 循环检查是否在线的间隔时间（没有挂载时）
online_check_interval=10
# 离线检查
offline_check=true
# 离线检查间隔时间
offline_check_interval=60
# 挂载用户，非特权LXC容器的用户为100000
uid=100000
# 挂载分组，非特权LXC容器的用户组为100000
gid=100000
# 挂载权限
dir_mode="0755"
file_mode="0644"
# SMB账号
smb_username="你的SMB账号"
# SMB密码
smb_pwd="你的SMB密码"

# 是否已经挂载
isMounted=false

while :; do

    if mountpoint -q $mount_point; then
        if ! $isMounted; then
            # 设置为挂载状态
            isMounted=true
            echo "SMB挂载成功"
            if $offline_check; then
                echo "开启在线状态检测，间隔时间${offline_check_interval}s"
            fi
        fi
        if $offline_check; then
            sleep $offline_check_interval
            continue
        fi
    else
        # 设置为非挂载状态
        isMounted=false
        echo "SMB没有挂载，ping ${server_ip} ..."
        if (ping -c 1 -w 5 $server_ip >/dev/null 2>&1); then
            echo "${server_ip}在线，尝试挂载"

            # 判断挂载目录是否存在
            if [ ! -d $mount_point ]; then
                echo "挂载目录不存在，新建目录"
                mkdir -p $mount_point
            fi

            if [ ! -d $mount_point ]; then
                echo "挂载目录不存在，取消挂载，请检查权限, code:403"
                exit 403
            fi

            # 挂载SMB网络硬盘
            mount.cifs -o ,uid=$uid,gid=$gid,dir_mode=$dir_mode,file_mode=$file_mode,vers=2.1,username=$smb_username,password=$smb_pwd //$server_ip$server_path $mount_point

            if mountpoint -q $mount_point; then
                continue
            else
                echo "挂载失败"
                if $online_check; then
                    echo "继续尝试挂载${server_ip}，间隔时间${online_check_interval}s"
                    sleep $online_check_interval
                    continue
                else
                    echo "不继续尝试挂载，退出脚本，code:404"
                    exit 404
                fi
            fi
        else
            if $online_check; then
                echo "${server_ip}离线，上线检查间隔时间${online_check_interval}s"
                sleep $online_check_interval
                continue
            else
                echo "不循环检查，退出脚本，code:404"
                exit 404
            fi
        fi
    fi

done
