#!/bin/bash

#####################################################
# 名称       : log_copy_daily.sh
# 処理名称   : ログをコピーする。
# 機能概要   : ①リストファイルに下記をカンマ区切りで記載する。
#	       対象ログファイル（カラム1),ログの格納ディレクトリ（カラム2),コピー先ディレクトリ	（カラム3),読み込む世代（カラム4)
#	　　　 ②①のファイルを読み込む
#              ③カラム1に指令されたログファイルをカラム2で指定されたカラムされたログの格納ディレクトリからの
#               読み込む世代（カラム4)前のファイルをカラム3のコピー先ディレクトリへコピーする。
#              なお、コピー先へは、「ホスト名-カラム1のログファイル名-yyyymmdd」の命名規則でコピーする。
########################################################


##### 変数宣言 #######

## プロセス番号
PRC_NM=$$

## ベースディレクトリ
BASE_DIR=/home/ment/logstogare/daily

## シェル名称
SHL_NM=log_copy_daily.sh

## リストファイル
LOG_LIST=log_copy_daily.lst

## プログラムステップカウンタ
STP_CNT=0

## システム系変数　##

#ホスト名
HOST_NAME=linux

#シェル実行日(yyyymmdd)
SHL_EXEC_DATE=`date '+%Y%m%d'`

## 結果関連変数　##
#処理のリターンコードを格納
RET_CD=0



#--- テンポラリ変数 ----##
TARGET_LOG=
TARGET_DIR=
COPY_DST_DIR=
TARGET_GEN=

TMP_TARGET_GEN=0

##### メッセ－ジ設定 #####
N_MSG001="[${SHL_NM}(${PRC_NM})] "
E_MSG001="[${SHL_NM}(${PRC_NM})] ERROR.."

#--- メール送信関連 ----##

##### メッセ－ジ出力関数 #####

function LogOutPut
{
    case ${MSG_CS} in
	"I") echo "[STEP${STP_CNT}(${SHL_NM}($PRC_NM))]----${MSG_HD} ${MSG_BODY} ${MSG_OPT} `date '+%Y%m%d%H%M%S'`(RC=${RET_CD})"
	     ;;
	"E") echo "[STEP${STP_CNT}(${SHL_NM}($PRC_NM))]----${MSG_HD} ${MSG_BODY} ${MSG_OPT} `date '+%Y%m%d%H%M%S'`(RC=${RET_CD})" >&2
	     #                 logger -i -t "${MSG_HD}"  "${MSG_SR} ${MSG_OPT} ReturnCode=${RET_CD}"
	     ;;
	*) echo "message output error..." >&2
	   ;;
    esac
}

##################################################################################
#
#  処理の開始
#
##################################################################################

##### 正常開始メッセ－ジ出力 #####

MSG_CS="I"
STP_CNT=`expr $STP_CNT + 1`
MSG_HD="ログのコピー処理の実行を開始します。"
MSG_BODY=""
MSG_OPT=""
RET_CD=0
LogOutPut


##################################################################################
#
# リストファイルの読み込み
#
##################################################################################

#空白行,空行は除く
cat ${LOG_LIST} |grep -v '^\s*$' | grep -v '^$' | 
while read line
do


	#各項目の格納	
	TARGET_LOG=`echo ${line} | cut -d ',' -f 1`
	TARGET_DIR=`echo ${line} | cut -d ',' -f 2`
	COPY_DST_DIR=`echo ${line} | cut -d ',' -f 3`
	TARGET_GEN=`echo ${line} | cut -d ',' -f 4`

	#事前にターゲットログファイルの存在確認をしておく（指定のカラム分)
	echo "【検索対象の結果（直近日付の2ファイル分）】"
	ls -t ${TARGET_DIR}/${TARGET_LOG}*| head -n ${TARGET_GEN}

	#パイプステータスを取得する。
	for child_ret in ${PIPESTATUS[@]}
	do
	    #エラーが有ったらエラーステータス(child_ret)をリターンしexit
	    echo "【リストファイルの読み込み結果ステータス】：" ${child_ret}
	    [ $child_ret -ne 0 ] && exit $child_ret
	done

#	echo $?

	#事前にターゲットログファイルの存在確認ができたら	
      	ls -t ${TARGET_DIR}/${TARGET_LOG}*| head -n ${TARGET_GEN} |
	while read log_list
	do
	    #読み込み回数の取得
	    TMP_TARGET_GEN=`expr $TMP_TARGET_GEN + 1`
	    echo "【読み込み回数】:"${TMP_TARGET_GEN}
	    
	    #リストファイルのカラム4の世代数と一致した場合

	    if [ ${TMP_TARGET_GEN} -eq ${TARGET_GEN} ]
	    then
		echo "【読み込み回数】:"${TMP_TARGET_GEN} " 【指定された世代数】:"${TARGET_GEN} " 一致しました"
		echo "【取得されたターゲットファイル】:"${log_list}
		#ホスト名-オリジナルログファイル名-yyyymmdd形式でコピーファイル名作成
		#例：hostname-access_log-20160828
		COPY_FILE_NAME=${HOST_NAME}-${TARGET_LOG}-${SHL_EXEC_DATE}
		echo "【コピーするファイル名】:"${COPY_FILE_NAME}

	    	# !! コピー処理の実行 !!
		# 上書きモードでコピー
		cp -f ${log_list} ${COPY_DST_DIR}/${COPY_FILE_NAME}

		RET_CD=$?

		if [ ${RET_CD} -ne 0 ]; then

		    ### 異常終了メッセージ ###
		    MSG_CS="E"
		    STP_CNT=`expr $STP_CNT + 1`
		    MSG_SR="${E_MSG001}"
		    STP_CNT=${STP_CNT}
		    MSG_HD="【コピー元】：${log_list} , 【コピー先】：${COPY_DST_DIR}/${COPY_FILE_NAME}"
		    MSG_BODY="コピーファイル処理が異常終了しました。"
		    MSG_OPT=""
		    RET_CD=2

		    LogOutPut
		    exit ${RET_CD}
		    
		else

		    ##### 正常メッセ－ジ出力 #####
		    MSG_CS="I"
		    STP_CNT=`expr $STP_CNT + 1`
		    MSG_HD="【コピー元】：${log_list} , 【コピー先】：${COPY_DST_DIR}/${COPY_FILE_NAME}"
		    MSG_BODY="コピーファイル処理が正常終了しました。"
		    MSG_OPT=""
		    RET_CD=0

		    LogOutPut
 fi
		
	    fi

	    

	done

	



		      
done

RET_CD=$?
if [ ${RET_CD} -ne 0 ]; then
    ### 異常終了メッセージ ###
    MSG_CS="E"
    STP_CNT=`expr $STP_CNT + 1`
    MSG_SR="${E_MSG001}"
    STP_CNT=${STP_CNT}
    MSG_HD="ログのコピー処理の実行を終了します。"
    MSG_BODY="リストファイルの読み込み処理が異常終了しました。"
    MSG_OPT=""
    RET_CD=2

    LogOutPut
    exit ${RET_CD}
else
    ##### 正常メッセ－ジ出力 #####
    MSG_CS="I"
    STP_CNT=`expr $STP_CNT + 1`
    MSG_HD=""
    MSG_BODY="リストファイルの読み込み処理が正常終了しました。"
    MSG_OPT=""
    RET_CD=0
    LogOutPut
 fi

##### 正常メッセ－ジ出力 #####
MSG_CS="I"
STP_CNT=`expr $STP_CNT + 1`
MSG_HD="ログコピー処理の実行が正常終了しました。"
MSG_BODY=""
MSG_OPT=""
RET_CD=0
LogOutPut


exit ${RET_CD}
