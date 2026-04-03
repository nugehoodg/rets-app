Get-ChildItem -Recurse -Filter '*.dart' -Path 'c:\Users\Nuge\Documents\music-player\the_archivist\lib' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
    Set-Content -Path $_.FullName -Value $newContent -NoNewline
}
Write-Host "Replaced withOpacity in all dart files"
