<#
    .SYNOPSIS
    schedules a system reboot using a Windows Scheduled Task

    .DESCRIPTION
    This script creates a Scheduled Task which triggers a reboot
    at 4AM the next morning. If a Scheduled Tasks already
    exists, it will be replaced by the new one. Taskname and
    time can be changed by editing the variables in the script.

    .LINK
    https://github.com/michael-batz/ps-collection

    .NOTES
        Filename: schedule-reboot.ps1
        Author: Michael Batz <m.batz@lra-wue.bayern.de>
        License: MIT License

#>

# define parameters
$taskTime = "4:00 AM"
$taskUser = "NT AUTHORITY\SYSTEM"
$taskName = "Patchmanagement ScheduledReboot"

# remove existing scheduled tasks
foreach($task in (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Unregister-ScheduledTask -InputObject $task -Confirm:$false
}

# calculate correct day for task
$taskTime = [DateTime]$taskTime
if($taskTime -lt (Get-Date)) {
    # if configured time is in the past, add one day
    $taskTime = $taskTime.AddDays(1)
}

# register new scheduled task
$taskAction = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\shutdown.exe" -Argument "/r /d p:2:3"
$taskTrigger = New-ScheduledTaskTrigger -Once -At $taskTime
Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -User $taskUser
