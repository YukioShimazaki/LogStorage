#==============================================================================================================================
#�v���O�������FGet-Audit.ps1
#�@�\�FWindows�Z�L�����e�B���O���烍�O�C���i4624�i���O�I���^�C�v=10 or 2)�j�A���O�I�t�C�x���g�i4634�A4647�j�𒊏o���Acsv�t�@�C���֏o�͂���B
#
#�o�̓t�@�C���F�z�X�g��_yyyyMMddHHmmss.csv
#���L�����F�e���ڒ���,�����̓f���~�^�����Əd�����邽�߁A���p�X�y�[�X�ɒu���̂����A�G�N�X�|�[�g����B
#
#==============================================================================================================================


####################################################################################
#
# �ϐ��錾
#
####################################################################################

#�z�X�g��
$HOSTNAME  = [Net.Dns]::GetHostName()

#���O�t�@�C���̏o�͐�
$yyyyMMddHHmmss = get-date -format yyyyMMddHHmmss
$file = $HOSTNAME + "_" + $yyyyMMddHHmmss + ".csv"

#�f���~�^����
$DELIM_KANMA=","

####################################################################################
#
# �ϐ��錾
#
####################################################################################

#�w�b�_��
$header_line =  "�C�x���g����,�z�X�g��,���O�t�@�C����,�C�x���gID,���O�\�[�X,���O�^�C�v,���O���b�Z�[�W"

#�w�b�_���o��
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
                            ($_.eventID -eq 4624  -and (($_.message -match "\s*?���O�I�� �^�C�v:\s*2\s*?") -or ($_.message -match "\s*?���O�I�� �^�C�v:\s*10\s*?")) ) `
                        )`
                        -and `
                        (`
                            $_.message -notmatch "\s*?�A�J�E���g��:\s*DWM-*\s*?"
                         ) `
                    }`
            | Where-Object { $_.TimeGenerated -gt (get-date).addhours(-24) } `
			|  Select-Object EntryType,EventID,Source,TimeGenerated,Message | Sort-Object $SortKeyName

#get-eventlog -logname security  | more

	#�擾�����C�x���g���O���t�@�C���ɏ�������---------------------
        foreach ($row in $logArray) {


                #### �f�[�^�ϊ����@#####

            	#Message�ɓ����Ă�����s�R�[�h��ϊ��@
            	$LogMessage = [string]$row.Message.Replace("`r`n"," ")

                #Message�ɓ����Ă�����s�R�[�h��ϊ��A
          	    $LogMessage = $LogMessage.Replace("`n"," ")

            	#Message�ɓ����Ă���J���}��ϊ�
            	$LogMessage = $LogMessage.Replace(","," ")

            	#Message�ɓ����Ă���J���}��ϊ�
            	$LogMessage = $LogMessage.Replace(" ","`t")
            
		        #���t�̏����𐮌`
		        $LogTimeGenerated = [string]$row.TimeGenerated.ToString("yyyy/MM/dd HH:ss:mm")

		        #Log�\�[�X
		        $LogSource =  [string]$row.Source

		        #Log�^�C�v
		        $LogType = [string]$row.EntryType

		        #�C�x���g�h�c
		        $LogEventID  = [string]$row.EventID
	  
		        $line =  $LogTimeGenerated + "," + $hostname + "," + $LogName + "," + $LogEventID + "," + $LogSource + "," + $LogType + "," + $LogMessage

		        #$line =  $LogTimeGenerated + $DELIM_SPACE + $IPADDR + $DELIM_SPACE + $ELC_VER +  $DELIM_SPACE + $LogSource + "[" +  $LogEventID + "]:"  +  $DELIM_SPACE + "["+ $START_SEQ +", �����̊č�, " + $enDateTime + ", N/A, " + $HOSTNAME + ".local] " +  $DELIM_SPACE + $LogMessage
                write-host $line              

        #	    	Write-Host $line

		        #�t�@�C���ɏ�������
            	$line | Out-File -filepath $file  -Encoding default -Append

	}
}