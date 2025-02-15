cd /#!/bin/bash
SH_PATH=$(cd "$(dirname "$0")";pwd)
cd ${SH_PATH}

create_mainfest_file(){
    echo "进行配置。。。"
    read -p "请输入你的应用名称：" IBM_APP_NAME
    echo "应用名称：${IBM_APP_NAME}"
    read -p "请输入你的应用内存大小(默认256)：" IBM_MEM_SIZE
    if [ -z "${IBM_MEM_SIZE}" ];then
    IBM_MEM_SIZE=256
    fi
    echo "内存大小：${IBM_MEM_SIZE}"
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "生成随机UUID：${UUID}"
    WSPATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
    appname1=${IBM_APP_NAME}
    echo "生成随机WebSocket路径：${WSPATH}"
    
    cat >  ${SH_PATH}/IBMVPS/v2ray-cloudfoundry/manifest.yml  << EOF
    applications:
    - path: .
      name: ${IBM_APP_NAME}
      random-route: true
      memory: ${IBM_MEM_SIZE}M
EOF

    cat >  ${SH_PATH}/IBMVPS/v2ray-cloudfoundry/v2ray/config.json  << EOF
    {
        "inbounds": [
            {
                "port": 8080,
                "protocol": "vmess",
                "settings": {
                    "clients": [
                        {
                            "id": "${UUID}",
                            "alterId": 4
                        }
                    ]
                },
                "streamSettings": {
                    "network":"ws",
                    "wsSettings": {
                        "path": "${WSPATH}"
                    }
                }
            }
        ],
        "outbounds": [
            {
                "protocol": "freedom",
                "settings": {}
            }
        ]
    }
EOF
    echo "配置完成。"
}

clone_repo(){
    echo "进行初始化。。。"
    rm -rf IBMVPS
    rm -rf IBMyes
    git clone https://github.com/bigfangfang/IBMVPS
    cd IBMVPS
    git submodule update --init --recursive
    cd v2ray-cloudfoundry/v2ray
    # Upgrade V2Ray to the latest version
    rm v2ray v2ctl
    
    # Script from https://github.com/v2fly/fhs-install-v2ray/blob/master/install-release.sh
    # Get V2Ray release version number
    TMP_FILE="$(mktemp)"
    if ! curl -s -o "$TMP_FILE" 'https://api.github.com/repos/v2fly/v2ray-core/releases/latest'; then
        rm "$TMP_FILE"
        echo 'error: 获取最新V2Ray版本号失败。请重试'
        exit 1
    fi
    RELEASE_LATEST="$(sed 'y/,/\n/' "$TMP_FILE" | grep 'tag_name' | awk -F '"' '{print $4}')"
    rm "$TMP_FILE"
    echo "当前最新V2Ray版本为$RELEASE_LATEST"
    # Download latest release
    DOWNLOAD_LINK="https://github.com/v2fly/v2ray-core/releases/download/$RELEASE_LATEST/v2ray-linux-64.zip"
    if ! curl -L -H 'Cache-Control: no-cache' -o "latest-v2ray.zip" "$DOWNLOAD_LINK"; then
        echo 'error: 下载V2Ray失败，请重试'
        return 1
    fi
    unzip latest-v2ray.zip v2ray v2ctl geoip.dat geosite.dat
    rm latest-v2ray.zip
    
    chmod 0755 ./*
    cd ${SH_PATH}/IBMVPS/v2ray-cloudfoundry
    echo "初始化完成。"
}

install(){
    echo "进行安装。。。"
    cd ${SH_PATH}/IBMVPS/v2ray-cloudfoundry
    ibmcloud target --cf
    ibmcloud cf install
    ibmcloud cf push
    echo "安装完成。"
    echo "生成的随机 UUID：${UUID}"
    echo "生成的随机 WebSocket路径：${WSPATH}"
    VMESSCODE=$(base64 -w 0 << EOF
    {
      "v": "2",
      "ps": "ibmvps-${appname1}",
      "add": "bigfang.us-south.cf.appdomain.cloud",
      "port": "443",
      "id": "${UUID}",
      "aid": "4",
      "net": "ws",
      "type": "none",
      "host": "",
      "path": "${WSPATH}",
      "tls": "tls"
    }
EOF

    )
    echo "别高兴太早，到这一步未必说明下面的vmess连接就可以用！"
    echo "请注意如果出现2个或者3个红色的FAILED就说明你的VMESS连接是无法连接外网的。这个时候需要去排查问题，可以通过这个影片去仔细看看可能能找到答案 https://bit.ly/2ZjVCkN"
    echo "或者观看YouTube影片 IBM Cloud VPS 详细分享：https://bit.ly/3ibq1JI"
    echo "如果你看到只有一个红色的Failed 那么恭喜你大概率你的Vmess连接有效！Vmess导入客户端后，请务必将域名中bigfang更改为你的应用程序名称！请务必根据在cloudflare中加速"
    echo "我的电报：bigfangfang"
    echo "电报群交流群：https://t.me/dafangbigfang 群里有很多小伙伴都会帮你"
    echo "电报频道：https://t.me/dafangbigfangC"
    echo "感谢 @CCChieh "
    echo ""
    echo "配置链接："
    echo vmess://${VMESSCODE}
    

}

clone_repo
create_mainfest_file
install


exit 0
