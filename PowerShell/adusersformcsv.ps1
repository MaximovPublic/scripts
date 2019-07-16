# Generate .csv with new users for AD.
# Generate latin username using cyrillic name
# generate data for import

function CyrillicToLatin
{
    param([string]$CyrillicString)
    $Translit = @{
        [char]'а' = "a"
        [char]'А' = "a"
        [char]'б' = "b"
        [char]'Б' = "b"
        [char]'в' = "v"
        [char]'В' = "v"
        [char]'г' = "g"
        [char]'Г' = "g"
        [char]'д' = "d"
        [char]'Д' = "d"
        [char]'е' = "e"
        [char]'Е' = "e"
        [char]'ё' = "e"
        [char]'Ё' = "e"
        [char]'ж' = "zh"
        [char]'Ж' = "zh"
        [char]'з' = "z"
        [char]'З' = "z"
        [char]'и' = "i"
        [char]'И' = "i"
        [char]'й' = "y"
        [char]'Й' = "y"
        [char]'к' = "k"
        [char]'К' = "k"
        [char]'л' = "l"
        [char]'Л' = "l"
        [char]'м' = "m"
        [char]'М' = "m"
        [char]'н' = "n"
        [char]'Н' = "n"
        [char]'о' = "o"
        [char]'О' = "o"
        [char]'п' = "p"
        [char]'П' = "p"
        [char]'р' = "r"
        [char]'Р' = "r"
        [char]'с' = "s"
        [char]'С' = "s"
        [char]'т' = "t"
        [char]'Т' = "t"
        [char]'у' = "u"
        [char]'У' = "u"
        [char]'ф' = "f"
        [char]'Ф' = "f"
        [char]'х' = "kh"
        [char]'Х' = "kh"
        [char]'ц' = "tc"
        [char]'Ц' = "tc"
        [char]'ч' = "ch"
        [char]'Ч' = "ch"
        [char]'ш' = "sh"
        [char]'Ш' = "sh"
        [char]'щ' = "shch"
        [char]'Щ' = "shch"
        [char]'ъ' = ""
        [char]'Ъ' = ""
        [char]'ы' = "i"
        [char]'Ы' = "i"
        [char]'ь' = ""
        [char]'Ь' = ""
        [char]'э' = "e"
        [char]'Э' = "e"
        [char]'ю' = "yu"
        [char]'Ю' = "yu"
        [char]'я' = "ya"
        [char]'Я' = "ya"
        [char]' ' = ""
    }
    $FinalSamSequence=""
    ForEach ($c in $CyrillicChars = $CyrillicString.ToCharArray()){
        if ($Translit[$c] -cne $Null ){
    		$FinalSamSequence = $FinalSamSequence + $Translit[$c]
    	}
        else {
    	    $FinalSamSequence = $FinalSamSequence + $c
    	}
    }
    Write-Output $FinalSamSequence
}

$ExportArray = @()

$FutureUsers = Import-Csv .\2019-06-07-sqlresult.csv -Encoding UTF8 -Delimiter ';'
ForEach ($User in $FutureUsers){
    $NewUserObject = new-Object PSObject
	$VisibleName = (Get-Culture).TextInfo.ToTitleCase($User.Name.ToLower())
	$VisibleSurname = (Get-Culture).TextInfo.ToTitleCase($User.Surname.ToLower())
	$VisiblePatronymic = (Get-Culture).TextInfo.ToTitleCase($User.Patronymic.ToLower())
	$VisibleFaculty = $User.Faculty
	$VisibleOrderName = $User.NameOrder
    $FutureName = $VisibleName
	$FutureSurname = $VisibleSurname
	$FutureInitials = ""
	if ($VisiblePatronymic -ne "") {$FutureInitials = $VisiblePatronymic.Substring(0,1) + ". "}
	$FutureDisplayName = $FutureName + " " + $FutureInitials + $FutureSurname
	$SamPrototypePatronymic = ""
	if ($User.patronymic -ne "") {$SamPrototypePatronymic = $User.patronymic.Substring(0,1)}
    $SamPrototype = $User.Surname.ToLower() + $User.name.Substring(0,1).ToLower() + $SamPrototypePatronymic.ToLower()
	$FutureSamAccountName = CyrillicToLatin $SamPrototype
	$CheckADUser = Get-ADUser -LDAPFilter "(sAMAccountName=$FutureSamAccountName)"
	if ($CheckADUser -ne $Null) {$FutureSamAccountName = $FutureSamAccountName + "2019"}
	if ($FutureSamAccountName -lt 6) {$FutureSamAccountName = $FutureSamAccountName + "2019"}
	$FutureUserPrincipalname = $FutureSamAccountName + "@example.com"
	$FutureDescription = "студент факультета " + $VisibleFaculty + "; № прик. " + $VisibleOrderName
	$FutureADPath = "OU=2019,OU=bachelors,OU=students,DC=example,DC=com"
	$FuturePassword = ([char[]](Get-Random -Input $(48..57 + 97..122) -Count 12)) -join ""
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "AbiturientID" -Value $User.uid
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Faculty" -Value $VisibleFaculty
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "GivenName" -Value $FutureName
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Surname" -Value $FutureSurname
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Initials" -Value $FutureInitials
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $FutureDisplayName
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $FutureSamAccountName
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $FutureUserPrincipalname
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Description" -Value $FutureDescription
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Path" -Value $FutureADPath
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Enabled" -Value "`$True"
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "Password" -Value $FuturePassword
	$NewUserObject | Add-Member -MemberType NoteProperty -Name "PasswordNeverExpires" -Value "`$True"
	$ExportArray += $NewUserObject
	
	Write-Output $User.uid 
    Write-Output $VisibleName
    Write-Output $VisibleSurname
    Write-Output $VisiblePatronymic
    Write-Output $VisibleFaculty
    Write-Output $SamPrototype
	Write-Output $FutureSamAccountName
	Write-Output $FuturePassword
	Write-Output $FutureDescription
    Write-Output " "
}
$ExportArray | Export-Csv -Path ADUser2019.csv -Encoding UTF8 -NoTypeInformation