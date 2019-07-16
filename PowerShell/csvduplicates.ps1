# Find duplicates of AbiturientID field in ADUserBachelors.csv .
$CheckArray = Import-Csv .\ADUserBachelors.csv -Encoding UTF8
$CheckArray.AbiturientID | Group-Object | Where-Object { $_.count -ge 2 } | Export-csv -Path duplicates.csv -NoTypeInformation