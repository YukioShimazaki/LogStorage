#==============================================================================================================================
#プログラム名：Get-Audit.ps1
#機能：Windowsセキュリティログからログイン（4624（ログオンタイプ=10 or 2)）、ログオフイベント（4634、4647）を抽出し、csvファイルへ出力する。
#
#出力ファイル：ホスト名_yyyyMMddHHmmss.csv
#特記事項：各項目中の,文字はデリミタ文字と重複するため、半角スペースに置換のうえ、エクスポートする。
#
#==============================================================================================================================


####################################################################################
#
# 変数宣言
#
####################################################################################

#ホスト名
$HOSTNAME  = [Net.Dns]::GetHostName()

#ログファイルの出力先
$yyyyMMddHHmmss = get-date -format yyyyMMddHHmmss
$file = $HOSTNAME + "_" + $yyyyMMddHHmmss + ".csv"

#デリミタ文字
$DELIM_KANMA=","

####################################################################################
#
# 変数宣言
#
####################################################################################

#ヘッダ部
$header_line =  "イベント日時,ホスト名,ログファイル名,イベントID,ログソース,ログタイプ,ログメッセージ"

#ヘッダ部出力
$header_line | Out-File -filepath $file  -Encoding default -Append

$LogNames = @("Security")
$SortKeyName = "TimeGenerated"
Foreach ( $LogName in $LogNames ) {

	$logArray = Get-EventLog -logname $LogName `
            | where { (`
                            ($_.eventID -eq 4634) `
                                -or `
                            ($_.eventID -eq 4647) `
                                -or `
                            ($_.eventID -eq 4624  -and (($_.message -match "\s*?ログオン タイプ:\s*2\s*?") -or ($_.message -match "\s*?ログオン タイプ:\s*10\s*?")) ) `
                        )`
                        -and `
                        (`
                            $_.message -notmatch "\s*?アカウント名:\s*DWM-*\s*?"
                         ) `
                    }`
            | Where-Object { $_.TimeGenerated -gt (get-date).addhours(-24) } `
			|  Select-Object EntryType,EventID,Source,TimeGenerated,Message | Sort-Object $SortKeyName

#get-eventlog -logname security  | more

	#取得したイベントログをファイルに書き込む---------------------
        foreach ($row in $logArray) {


                #### データ変換部　#####

            	#Messageに入っている改行コードを変換①
            	$LogMessage = [string]$row.Message.Replace("`r`n"," ")

                #Messageに入っている改行コードを変換②
          	    $LogMessage = $LogMessage.Replace("`n"," ")

            	#Messageに入っているカンマを変換
            	$LogMessage = $LogMessage.Replace(","," ")

            	#Messageに入っているカンマを変換
            	$LogMessage = $LogMessage.Replace(" ","`t")
            
		        #日付の書式を整形
		        $LogTimeGenerated = [string]$row.TimeGenerated.ToString("yyyy/MM/dd HH:ss:mm")

		        #Logソース
		        $LogSource =  [string]$row.Source

		        #Logタイプ
		        $LogType = [string]$row.EntryType

		        #イベントＩＤ
		        $LogEventID  = [string]$row.EventID
	  
		        $line =  $LogTimeGenerated + "," + $hostname + "," + $LogName + "," + $LogEventID + "," + $LogSource + "," + $LogType + "," + $LogMessage

		        #$line =  $LogTimeGenerated + $DELIM_SPACE + $IPADDR + $DELIM_SPACE + $ELC_VER +  $DELIM_SPACE + $LogSource + "[" +  $LogEventID + "]:"  +  $DELIM_SPACE + "["+ $START_SEQ +", 成功の監査, " + $enDateTime + ", N/A, " + $HOSTNAME + ".local] " +  $DELIM_SPACE + $LogMessage
                write-host $line              

        #	    	Write-Host $line

		        #ファイルに書き込む
            	$line | Out-File -filepath $file  -Encoding default -Append

	}
}