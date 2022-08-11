#!/bin/bash
 
#bin/bsah - l
 
export LANG=en_US.UTF-8
 
export LANGUAGE=en_US.UTF-8
 
export LC_ALL=en_US.UTF-8
 
set -e
 
#输出错误
function echo_error() {
    echo "❗️❗️❗️\033[31m $1 \033[0m"
}
 
#输出信息
function echo_info() {
    echo "️➡️ ️➡️\033[32m $1 \033[0m"
}
 
#打包
function packaging() {
 
    echo_info "====================开始===================="
 
    #参数校验 $#  添加到Shell的参数个数
    if [ $# != "3" ] || ([ $1 != "test" ] && [ $1 != "product" ]); then
       echo_error '请指定打包环境：test, product'
       exit 1
    fi
    echo_info "当前目录: $(pwd)"

    #参数配置
    fastlane_output_path="./fastlane_output"
    
    #你的fir账号 API Token
    fircli_token="7b49d56d91b0abcf9929cc151d907462"
    #fir 指定appIcon
    fircli_Icon=~/Desktop/GSEC_metadata/appicon/AppIcon60x60.png
 
    #定义一些符变量
    export v_env=$1
    export v_distribution=$2

    export v_project_name="Small Secretary"
    export v_target_name="Small Secretary"
    export v_build_number="${BUILD_NUMBER}"
    export v_git_branch="${GIT_BRANCH}"
    #export v_commit_node="$(git log -n 1 --pretty=format:"%h")"
    export v_download_URL="http://d.firim.pro/vgud"
    #export v_QRCode_URL="URL"
    #export v_last_10_logs="$(git log -n 10 --pretty=format:"%h %ci %cn%n%s%n")"
 
    echo_info "====================安装pod依赖===================="
    #安装pod依赖
    rm -rf './Pods/Local Podspecs'
    pod setup
    pod install || true
 
    #删除构建输出
    rm -rf "${fastlane_output_path}"
    
    #版本号
    export v_app_version=$(echo "$(fastlane run get_version_number xcodeproj:"${v_project_name}".xcodeproj target:"${v_target_name}")" | tr -d '\n' | sed -E 's/.*Result: ([0-9\.]*).*/\1/g')
    #app名字
    export v_app_name=$(echo "$(fastlane run get_info_plist_value path:"./${v_project_name}/Info.plist" key:"CFBundleDisplayName")")
 
    #构建
    echo_info "====================构建===================="
    ipa_name="${v_project_name}_${v_distribution}_${v_app_version}_${v_env}_$(date "+%Y%m%d%H%M%S")"
    
    #修改appIcon
    rm -rf AppIcon副本
    if [ $v_distribution != "AppStore" ] && ([ $v_distribution != "In-House" ] || [ $3 = true ]); then
    icon_asset_dir="${v_project_name}/Assets.xcassets/AppIcon.appiconset"
    rm -rf "${icon_asset_dir}副本"
    cp -R "$icon_asset_dir" "${icon_asset_dir}副本"
    mv "${icon_asset_dir}副本" "AppIcon副本"
    [[ $v_env = "test" ]] && env_str="测试" || env_str="正式"
    standar_pixel_per_side=120
      for pic in `ls -R "$icon_asset_dir"/*.png | tr " " "?"`; do
        pic=${pic//'?'/' '}
        size=$(echo "$(gm identify "${pic}")" | tr -d '\n' | grep -o "[0-9]\+[xX][0-9]\+")
        filename=${pic##*/}
        length=$(echo "$size" | tr -d '\n' | sed -E "s/x.*//g")
        scale=$(echo "scale=2;$length / $standar_pixel_per_side"|bc)
        gm convert "$pic" -fill '#ef934d' -draw "circle 0,0 $(echo "40 * $scale"|bc),$(echo "10 * $scale"|bc)" "$icon_asset_dir/badge.png"
        # gm convert -size 100x100 xc:none -draw "roundrectangle 0,0,100,100,20,20" "$icon_asset_dir/mask.png"
        # gm composite -resize $size "$icon_asset_dir/mask.png" -compose copyopacity "$icon_asset_dir/badge.png" "$icon_asset_dir/roundcorner.png"
        gm convert "$icon_asset_dir/badge.png" -fill '#ffffff' -pointsize $(echo "16 * $scale"|bc) -stroke '#ffffff' -strokewidth 0.5 -font "/System/Library/Fonts/PingFang.ttc" -gravity northwest -draw "rotate -45 text $(echo "-15 * $scale"|bc),$(echo "33 * $scale"|bc) '$env_str'" "$icon_asset_dir/final.png"
        rm -f "$pic"
        mv "$icon_asset_dir/final.png" "$pic"
       

        if [ "$length" == "120" ]; then
            icon120file=$(echo $pic | sed -E 's/\.png/副本.png/g')
            fircli_Icon="${fircli_Icon%/*}/badgeAppIcon.png"
            cp "$pic" "${icon120file}"
            mv "${icon120file}" $fircli_Icon
        fi
      done
      rm -f "$icon_asset_dir/badge.png"
      #rm -f "$icon_asset_dir/mask.png"
      #rm -f "$icon_asset_dir/roundcorner.png"
    fi

    # xcrun xcodebuild -list -project './GTIMobileWorkHelper.xcodeproj'
    #fastlane打包
    fastlane "${v_env//-/_}_${v_distribution//-/_}" ipa_name:"${ipa_name}" output_path:"${fastlane_output_path}"
    #恢复原始icon file
    if [[ $v_distribution != "AppStore" ]];then
	    rm -rf "$icon_asset_dir" && mv -f "AppIcon副本" "$icon_asset_dir"
    fi
    
    #没设置bundleDisplayName
    if [[ $v_app_name != *"Result"* ]]; then
         v_app_name=$(echo "$(fastlane run get_ipa_info_plist_value ipa:"${fastlane_output_path}/${ipa_name}.ipa" key:"CFBundleName")")
    fi
    v_app_name=$(echo $v_app_name | tr -d '\n' | sed -e 's/.*Result: //g' -e 's/\#.*//g' -e 's/\[0m//g')
    # 获取svn最后3次提交信息
    if [ ! -d .git ]; then
        git init
        find ./ -type d -empty -exec touch {}/.gitkeep \;
        git add .
        git commit -q -m "首次记录svn仓库"
        echo_info "初始化svn仓库版本控制"
    fi
    
    if [ -n "$(git status -s)" ];then
        git add .
        git commit -m "同步svn changes"
        echo_info "记录到svn仓库改动"
    fi
	svn upgrade --quiet
	svn_latest_changes=$(echo "$(svn log -l 3)" | tr "\n" " ")
    last_change_revision=$(echo "$svn_latest_changes" | sed -e 's/\-\{5,\}//g' -e 's/ | .*//g')
    log_history_text=$(echo "$svn_latest_changes" | sed -e 's/\-\{5,\}/\\n•/g' -e 's/ [0-9]\{4\}-[0-9]\{2\}.\{25,54\}line[s]\{0,1\}//g' -e 's/[r]*[0-9]\{1,\} | //g')
    log_history_text=${log_history_text#*\\n}
    log_history_text=${log_history_text%\\n•*}
    echo_info "$log_history_text"
	git reset --hard HEAD && git clean -fd
    
    get_path="${v_download_URL}"
    get_path_desc="下载地址："
    click_enable=0
    #上传Fir
    if [[ $3 == true ]] && [[ $2 != "AppStore" ]];then
        echo "*************| 开始上传fir... |*************"
        fir publish "${fastlane_output_path}/${ipa_name}.ipa" -T "${fircli_token}" --specify-icon-file="$fircli_Icon" --changelog="${log_history_text}"
        echo "*************| 🎉上传fir成功🎉 |*************"
        click_enable=1
    else
        get_path=$(echo "file://$(pwd)${fastlane_output_path//./}/${ipa_name}.ipa" | tr -d '\n' | sed -E 's/ /20%/g')
        get_path_desc="导出目录："
        click_enable=1
    fi
     echo_info "${get_path_desc}${get_path}"
    #前端组
     #curl -i -X POST -H "'Content-type':'application/json'" -d '{"msgtype":"template_card","template_card":{"card_type":"text_notice","source":{"icon_url":"https://img.toutiao.io/subject/f17d880998a545cda6984712a475d79c/thumb","desc":"fir.im","desc_color":0},"main_title":{"title":"'"${v_app_name}(${v_distribution})新版本发布了！"'"},"quote_area":{"type":0,"title":"'"LatestRevision：${last_change_revision}"'","quote_text":"'"${log_history_text}"'"},"horizontal_content_list":[{"keyname":"打包环境：","value":"'"${v_env}"'"},{"keyname":"版本号：","value":"'"${v_app_version}"'"},{"keyname":"'"${get_path_desc}"'","value":"'"${get_path}"'"}],"jump_list":[{"type":0,"title":"跳转到下载页面"}],"card_action":{"type":'${click_enable}',"url":"'${get_path}'"}}}' https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=df41f792-b59e-4438-825a-04c69f32a52a&debug=1
    #测试群
     curl -i -X POST -H "'Content-type':'application/json'" -d '{"msgtype":"template_card","template_card":{"card_type":"text_notice","source":{"icon_url":"https://img.toutiao.io/subject/f17d880998a545cda6984712a475d79c/thumb","desc":"fir.im","desc_color":0},"main_title":{"title":"'"${v_app_name}(${v_distribution})新版本发布了！"'"},"quote_area":{"type":0,"title":"'"LatestRevision：${last_change_revision}"'","quote_text":"'"${log_history_text}"'"},"horizontal_content_list":[{"keyname":"打包环境：","value":"'"${v_env}"'"},{"keyname":"版本号：","value":"'"${v_app_version}"'"},{"keyname":"'"${get_path_desc}"'","value":"'"${get_path}"'"}],"jump_list":[{"type":0,"title":"跳转到下载页面"}],"card_action":{"type":'${click_enable}',"url":"'${get_path}'"}}}' https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=de6d17b9-3702-404b-8214-092f9307cc02

:<<'上传二进制包到蒲公英'
    if [ $1 != "appStore" ]; then
        echo_info "====================上传二进制包到蒲公英===================="
        resp=$(curl -F "file=@${fastlane_output_path}/${ipa_name}.ipa" -F "_api_key=${PGY_API_KEY}" -F "buildInstallType=1" https://www.pgyer.com/apiv2/app/upload)
        echo "pgy_resp=${resp}"
 
        #解析数据，生成下载地址
        build_key=$(echo "$resp" | tr "\n" " " | sed -E 's/.*"buildKey" *: *"([^"]*)".*/\1/g')
        v_QRCode_URL=$(echo "$resp" | tr "\n" " " | sed -E 's/.*"buildQRCodeURL" *: *"([^"]*)".*/\1/g' | sed -E 's/\\\//\//g')
        v_download_URL="https://www.pgyer.com/apiv2/app/install?_api_key=${PGY_API_KEY}&buildKey=${build_key}"
    
        v_download_URL="https://www.pgyer.com/${build_key}"
 
        echo_info "二维码地址：${v_QRCode_URL}"
 
        echo_info "app下载地址：${v_download_URL}"
 
        #发送企业微信通知（最后面的key是企业微信机器人里面的key,需要把xxxxxxxxxxxxxx替换为你自己的）
        curl -i -X POST -H "'Content-type':'application/json'" -d '{"msgtype" : "text", "text" : {"content" : "'"iOS ${v_project_name} 新版本发布了！！！\n\n打包环境：${BuildType}\n\n打包分支：${v_git_branch}\n\n版本号：${v_app_version}\n\n更新信息：${Description}\n\n下载地址：${v_download_URL}"'"} }' https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxxxxxxxx
    else
        echo_info "====================AppStore打包完成===================="
        
        #发送企业微信通知
        curl -i -X POST -H "'Content-type':'application/json'" -d '{"msgtype" : "text", "text" : {"content" : "'"iOS ${v_project_name} ipa包上传App Store成功啦！\n\n版本号：${v_app_version}\n\n打包环境：${BuildType}\n\n打包分支：${v_git_branch}\n\n更新信息：${Description}"'"} }' https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxxxxxxxx
            
    fi
    
上传二进制包到蒲公英
    
}
 
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=120
 
#执行打包
packaging ${environment} ${distributionChannel} ${exportAndDistribute}
#packaging test Ad-Hoc false