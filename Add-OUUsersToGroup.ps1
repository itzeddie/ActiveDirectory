## ADD Users from specific OU to AD Group

Import-Module ActiveDirectory
$ADOUs = ''
$ADUsers = ForEach ($ADOU in $ADOUs) { Get-ADUser -Filter * -SearchBase $ADOU }
$ADGroup = ''
$ChangeNumber = ''
$Directory = ''

If(Test-Path $Directory) {
	Set-Location -Path $Directory
	ForEach ($ADUser in $ADUsers) {
		If(!(Get-ADPrincipalGroupMembership -Identity $ADUser | select Name | Where-Object {$_.name -eq 'AUTH-O365-MFA-OWA' })) {
			If(Get-ADPrincipalGroupMembership -Identity $ADUser | select Name | Where-Object {$_.name -like 'APP-O365-*' }) {
				try {
					# Add-ADGroupMember -Identity $ADGroup -Members $ADUser.SamAccountName
					Write-Host "SUCCESS: $($ADUser.Name) ($($ADUser.SamAccountName)) added to $($ADGroup)" -ForegroundColor Green -BackgroundColor Black
					"SUCCESS: $($ADUser.Name) added to $($ADGroup)" | Out-File "$($ChangeNumber).log" -Append
					}
				catch {
					Write-Host "FAIL: $($ADUser.Name) ($($ADUser.SamAccountName)) could not be added to $($ADGroup)" -ForegroundColor Red -BackgroundColor Black
					"FAIL: $($ADUser.Name) could not be added to $($ADGroup)" | Out-File "$($ChangeNumber).log" -Append
					}
				}
			Else {
				Write-Host "SKIPPED: $($ADUser.Name) ($($ADUser.SamAccountName)) is not a member of an Office 365 Group." -ForegroundColor Cyan -BackgroundColor Black
				"SKIPPED: $($ADUser.Name) is not a member of an Office 365 Group." | Out-File "$($ChangeNumber).log" -Append
			}
		}
	}
}
Else {
	Write-Host "$($Directory) does not exist." -ForegroundColor Red -BackgroundColor Black
	}
