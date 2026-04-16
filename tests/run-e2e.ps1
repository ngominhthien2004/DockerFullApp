param(
  [switch]$SkipBrowserInstall
)

$ErrorActionPreference = "Stop"

$testsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$combinedDir = Resolve-Path (Join-Path $testsDir "..")

Write-Host "Starting combined-image container..."
Push-Location $combinedDir
try {
  try {
    docker rm -f combined-dev *> $null
  }
  catch {
    # Container does not exist yet; continue.
  }
  try {
    docker compose down --remove-orphans *> $null
  }
  catch {
    # Ignore cleanup failures before bring-up.
  }
  docker compose up --build -d
}
finally {
  Pop-Location
}

try {
  $maxWaitSeconds = 180
  $elapsed = 0
  $containerId = ""

  Write-Host "Waiting for container healthcheck..."
  while ($elapsed -lt $maxWaitSeconds) {
    if (-not $containerId) {
      $containerId = docker compose -f (Join-Path $combinedDir "docker-compose.yml") ps -q combined-dev
    }

    if (-not $containerId) {
      Start-Sleep -Seconds 2
      $elapsed += 2
      continue
    }

    $health = docker inspect --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}" $containerId
    if ($health -eq "healthy") {
      Write-Host "Container is healthy."
      break
    }

    Start-Sleep -Seconds 5
    $elapsed += 5
  }

  if ($elapsed -ge $maxWaitSeconds) {
    throw "Timed out waiting for combined-dev to become healthy."
  }

  Push-Location $testsDir
  try {
    npm install
    if (-not $SkipBrowserInstall) {
      npx playwright install chromium
    }
    npm test
  }
  finally {
    Pop-Location
  }
}
finally {
  Write-Host "Stopping combined-image container..."
  Push-Location $combinedDir
  try {
    docker compose down --remove-orphans
  }
  finally {
    Pop-Location
  }
}
