$excelApp = New-Object -comobject Excel.Application

if ($args.Length -lt 1)
{
  Write-Host "Please provide full path and filename (ie: `"c:\books\excelfile.xlsx`")"
  Exit 1
}

$excelBook = $excelApp.Workbooks.Open($args[0])
$excelBook.PrintOut()
$excelApp.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excelApp)
Remove-Variable excelApp

Exit 0