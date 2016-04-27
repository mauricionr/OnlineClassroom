Clear-Host 

$classroomDomainName = "CptClassroom1234"
$globalAdminAccountName = "Instructor"
$globalAdminPassword = "pass@word1"

$classroomDomain = $classroomDomainName + ".onMicrosoft.com"
$classroomSharePointRootSite = "https://" + $classroomDomainName + ".sharepoint.com"
$classroomSharePointTenantSite = "https://" + $classroomDomainName + "-admin.sharepoint.com"

$globalAdminAccount = $globalAdminAccountName + "@" + $classroomDomain 
$globalAdminPassword = "pass@word1"
$globalAdminSecurePassword = ConvertTo-SecureString -String $globalAdminPassword -AsPlainText -Force

$e5LcenseSku = $classroomDomainName + ":ENTERPRISEPREMIUM"


function New-Student($firstName, $lastName, $alternateEmail) {

 $userPrincipalName = $firstName + "." + $lastName + "@" + $classroomDomain
 $userDisplayName = $firstName + " " + $lastName
 $password = "pass@word1"

 # Create new user account for student 
 New-MsolUser -UserPrincipalName $userPrincipalName `
              -DisplayName $userDisplayName `
              -UsageLocation "US" `
              -UserType Member `
              -LicenseAssignment $e5LcenseSku `
              -AlternateEmailAddresses $alternateEmail `
              -Password $password `
              -PasswordNeverExpires $true `
              -ForceChangePassword $false

 # write user info for student to log file
 "Student: $userDisplayName" | Out-File $LogFilePath -Append
 "Login: $userPrincipalName" | Out-File $LogFilePath -Append
 "Password: $password" | Out-File $LogFilePath -Append
 "Alt Email: $alternateEmail" | Out-File $LogFilePath -Append
 "" | Out-File $LogFilePath -Append
 "" | Out-File $LogFilePath -Append
}

# create new log file 
$CurrentDirectory = Get-Location 
$LogFilePath = ("{0}\StudentsLog.txt" -f $CurrentDirectory.Path)
"Log of created student accounts" | Out-File $LogFilePath
"" | Out-File $LogFilePath -Append

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
                         -ArgumentList $globalAdminAccount, $globalAdminSecurePassword

Connect-MsolService -Credential $credential
Connect-SPOService -Url $classroomSharePointTenantSite -credential $credential

$StudentsFilePath = ("{0}\Students.csv" -f $CurrentDirectory.Path)
$Students = Import-csv -path $StudentsFilePath

foreach($Student in $Students) { 
   New-Student $Student.FirstName $Student.LastName $Student.AlternateEmail 
}