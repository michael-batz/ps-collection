##################################################################
#                                                                #
# Send e-mail reminder on expiring passwords for AD users        #
# Michael Batz <m.batz@lra-wue.bayern.de>                        #
#                                                                #
##################################################################

$configUserOU = "OU=Users,DC=exmaple,DC=com"
$configReminderDays = @(10, 5)
$configMailServer = "mail.example.com"
$configMailSender = "it@example.com"
$configMailSubject = "Your password is expiring"
$configMailBody = @"
Dear {0} {1},

the password on your user account is expiring on {2}.
Please change your password before that time to ensure your user account isn't locked.
If you have any questions please let us know.

Best regards
IT Support
"@

# get all users
$users = Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Searchbase $configUserOU -Properties EmailAddress, msDS-UserPasswordExpiryTimeComputed
foreach($user in $users) {
    # check, if an email address is set
    if(!$user.EmailAddress) {
        continue
    }
	
	# calculate expire timespan
	$timeNow = Get-Date
	$timeExpired = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")
	$expireTimeSpan = New-TimeSpan -Start $timeNow -End $timeExpired
	# if timespan from expired password is on the configured day...
	if($expireTimeSpan.Days -in $configReminderDays) {
		Write-Output $user.name
		# ...send e-mail to user
		$personalizedMailBody = [string]::Format($configMailBody, $user.GivenName, $user.Surname, $timeExpired)
		Send-MailMessage -SmtpServer $configMailServer -From $configMailSender -To $user.EmailAddress -Body $personalizedMailBody -Subject $configMailSubject -Encoding "UTF8"	
	}
}
