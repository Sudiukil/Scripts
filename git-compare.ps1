$RED = [ConsoleColor]::Red
$GREEN = [ConsoleColor]::Green
$NC = [ConsoleColor]::White

if (-not $args) {
  Write-Host "Usage: $(Split-Path -Leaf $MyInvocation.MyCommand.Path) <upstream-branch>" -ForegroundColor $RED
  exit 1
}

$UPSTREAM_BRANCH = $args[0]
$DIFF_CURRENT_UPSTREAM = git cherry -v $UPSTREAM_BRANCH
$DIFF_UPSTREAM_CURRENT = (git cherry -v HEAD $UPSTREAM_BRANCH | ForEach-Object { $_ -replace '\+', '-' })

Write-Host $DIFF_CURRENT_UPSTREAM -ForegroundColor $GREEN
Write-Host $DIFF_UPSTREAM_CURRENT -ForegroundColor $RED

exit 0