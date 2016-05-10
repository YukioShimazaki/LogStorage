#==============================================================================================================================
#プログラム名：Get-Softwares.ps1
#機能：WindowsOS(WindowsServer2012 R2以降およびWindows10(64bit)からインストトールされたソフトウェアの値を示す
#　　　のレジストリキーに設定されている値を抽出し、csv形式で出力する。REGISTRY_PATHESに設定される値は、デフォルトでは以下の２つ。
#　　　"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
#
#引数（in)：なし
#戻り値：正常終了=0、異常終了=9
#出力ファイル：エクスポートファイル（カレントディレクトリ上に「soft_ホスト名.csv」で出力
#出力フォーマット：エクスポート日時,ホスト名,アプリケーション名,バージョン,製造元
#特記事項：各項目中の,文字はデリミタ文字と重複するため、半角スペースに置換のうえ、エクスポート
#
#Author：Y.shimazaki
#Updateed：2016.05.11
#
#==============================================================================================================================


#---------------------------------------------------------------------------
#
#  変数(valiable.section)
#
#----------------------------------------------------------------------------
#ホスト名
$hostname  = [Net.Dns]::GetHostName()

#ログ出力日
$LogTimeGenerated = get-date -format "yyyy/MM/dd HH:mm:ss"

#ログファイルの出力先（プログラムのカレントディレクトリ）
$file = "soft" + "_" + $hostname + ".csv"

#取得元ととなるレジストリキーの配列
$REGISTRY_PATHES = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")


#---------------------------------------------------------------------------
#
#  処理(procedure.section)
#
#----------------------------------------------------------------------------

#デバッグログ出力
$ProcStarted = get-date -format "yyyy/MM/dd HH:mm:ss"
Write-Host ("■Debug■ソフトウェア抽出処理を開始します(" + $ProcStarted + ")")

#例外の捕捉
try {
        #レジストリキーの配列を読み込み
        Foreach ($REGISTRY_PATH in $REGISTRY_PATHES )  {

	        #デバッグログ出力
	        Write-Host ("■Debug■レジストリ(" + $REGISTRY_PATH + ")を読み込みます")  

    	        $ChildItems = Get-ChildItem $REGISTRY_PATH -Recurse


    	        Foreach ( $ChildItem in $ChildItems ) {

                   $ItemProperty = Get-ItemProperty $ChildItem.psPath | sort $ItemProperty.DisplayName
                   If ( $ItemProperty.DisplayName -ne $Null ) {

		        #デバッグログ出力
		        Write-Host ("■Debug■値を取得しました")  
		        Write-Host ("■Debug■アプリケーション名：" + $ItemProperty.DisplayName )
		        Write-Host ("■Debug■アプリケーションバージョン：" + $ItemProperty.DisplayVersion  )
		        Write-Host ("■Debug■製造元：" + $ItemProperty.Publisher)。

		        #日付の書式を整形
        #		$LogTimeGenerated = [string]$row.TimeGenerated.ToString("yyyy/MM/dd HH:ss:mm")

		        #アプリケーション名
		        $applcation = $ItemProperty.DisplayName

		        if($applcation -ne $null) {
			        #applcationに入っているカンマを変換
			        $applcation = $applcation.Replace(","," ")
		        }

		        #バ―ジョン
		        $version = $ItemProperty.DisplayVersion
		
		        if($version -ne $null) {
			        #versionに入っているカンマを変換
			        $version = $version.Replace(","," ")
                       }

                       #製造元
                       $Publisher = $ItemProperty.Publisher

                       if($Publisher -ne $null) {
			        #Publisherに入っているカンマを変換
			        $Publisher = $Publisher.Replace(","," ")
                       }

		        #エクスポート文字列整形
                        $line =  $LogTimeGenerated + "," + $hostname + "," + $applcation + "," + $version + "," + $Publisher 


               	        #ファイルに書き込む
            	        $line | Out-File -filepath $file  -Encoding default -Append

		                #デバッグログ出力
		                Write-Host ("■Debug■取得した値を書き込みました。（" +   $line )  
                   }
            }
        }

        #デバッグログ出力
        $ProEnded = get-date -format "yyyy/MM/dd HH:mm:ss"
        Write-Host ("■Debug■ソフトウェア抽出処理が正常終了しました。(" + $ProEnded + ")")

        #リターン
        exit 0

#例外のキャッチ
}catch [Exception]{

    $ProEnded = get-date -format "yyyy/MM/dd HH:mm:ss"
    Write-Host ("■Debug■ソフトウェア抽出処理が異常終了しました。(" + $ProEnded + ")")
    Write-Host ("■Debug■エラーメッセージ。(" + $error + ")")

    #リターン
    exit 9
}