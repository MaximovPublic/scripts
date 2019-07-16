# Non-recursion rename by pattern.
Get-ChildItem -Filter "*_45.03.02.02_*" | Rename-Item -NewName {$_.name -replace "_45.03.02.02_", "_Бакалавриат_45.03.02.02_"}