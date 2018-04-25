Set-Location "/Users/fabianb/Documents/devel/OntapSDS"
 
Get-ChildItem ".\lib" | Where {$_.Name -like "*.ps1"} | ForEach {
 
    Write-Host "[Including $_]" -ForegroundColor Green
    . .\lib\$_
}