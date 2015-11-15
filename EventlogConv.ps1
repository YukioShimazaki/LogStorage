# (�Q�l�j
# http://d.hatena.ne.jp/skRyo/20120625/1340599737
#

#���O�t�@�C���̏o�͐�
$filetime = get-date -format yyyyMMddhhmmss
$file = "eventlog" + "_" + $filetime + ".txt"

#�z�X�g��
$hostname  = [Net.Dns]::GetHostName()


$LogNames = @("System","Application","Security")
$SortKeyName = "TimeGenerated"
Foreach ( $LogName in $LogNames ) {

	$logArray = Get-EventLog -logname $LogName | Where-Object { $_.TimeGenerated -gt (get-date).addhours(-24) } `
			|  Select-Object EntryType,EventID,Source,TimeGenerated,Message | Sort-Object $SortKeyName

	#�擾�����C�x���g���O���t�@�C���ɏ�������---------------------
        foreach ($row in $logArray) {

            	#Message�ɓ����Ă�����s�R�[�h��ϊ��@
            	$LogMessage = [string]$row.Message.Replace("`r`n"," ")

                #Message�ɓ����Ă�����s�R�[�h��ϊ��A
          	    $LogMessage = $LogMessage.Replace("`n"," ")

            	#Message�ɓ����Ă���J���}��ϊ�
            	$LogMessage = $LogMessage.Replace(","," ")

		#���t�̏����𐮌`
		$LogTimeGenerated = [string]$row.TimeGenerated.ToString("yyyy/MM/dd HH:ss:mm")

		#Log�\�[�X
		$LogSource =  [string]$row.Source

		#Log�^�C�v
		$LogType = [string]$row.EntryType

		#�C�x���g�h�c
		$LogEventID  = [string]$row.EventID
	  
		$line =  $LogTimeGenerated + "," + $hostname + "," + $LogName + "," + $LogEventID + "," + $LogSource + "," + $LogType + "," + $LogMessage

#	    	Write-Host $line

		#�t�@�C���ɏ�������
            	$line | Out-File -filepath $file  -Encoding default -Append

	}

}