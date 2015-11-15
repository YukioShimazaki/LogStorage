

#ホスト名
$hostname  = [Net.Dns]::GetHostName()

#ログ出力日
$LogTimeGenerated = get-date -format "yyyy/MM/dd HH:mm:ss"

#ログファイルの出力先
$file = "soft" + "_" + $hostname + ".txt"


#取得元ととなるレジストリキーの配列
$REGISTRY_PATHES = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

#ヘッダ出力
Write-Host ("アプリケーション名,アプリケーションバージョン,製造元")

#レジストリキーの配列を読み込み
Foreach ($REGISTRY_PATH in $REGISTRY_PATHES )  {

#    Write-Host ("レジストリキー：" + $REGISTRY_PATH )

    $ChildItems = Get-ChildItem $REGISTRY_PATH -Recurse
    
    Foreach ( $ChildItem in $ChildItems ) {

           $ItemProperty = Get-ItemProperty $ChildItem.psPath | sort $ItemProperty.DisplayName
           If ( $ItemProperty.DisplayName -ne $Null ) {

               #Write-Host ("アプリケーション名：" + $ItemProperty.DisplayName )
               #Write-Host ("アプリケーションバージョン：" + $ItemProperty.DisplayVersion )
               #Write-Host ("製造元：" + $ItemProperty.Publisher )

               #データ出力
#               Write-Host ($ItemProperty.DisplayName + "," + $ItemProperty.DisplayVersion  + "," +  $ItemProperty.Publisher)

		       #日付の書式を整形
#		       $LogTimeGenerated = [string]$row.TimeGenerated.ToString("yyyy/MM/dd HH:ss:mm")

               #アクション
               $action = "インストールされたソフト一覧"

               #アプリケーション名
               $applcation = $ItemProperty.DisplayName

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


                $line =  $LogTimeGenerated + "," + $hostname + "," + $action + "," + $applcation + "," + $version + "," + $Publisher 

               	#ファイルに書き込む
            	$line | Out-File -filepath $file  -Encoding default -Append
           }
    }
}
