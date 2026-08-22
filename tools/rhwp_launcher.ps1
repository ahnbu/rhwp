[CmdletBinding()]
param(
  [string]$FilePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'rhwp_launcher.lib.ps1')

$config = Get-RhwpLauncherConfig

if (-not (Test-Path $config.DistIndexPath)) {
  Show-RhwpPopup -Message "rhwp-studio build 결과가 없습니다.`n`n먼저 `D:\vibe-coding\rhwp\rhwp-studio`에서 `npm run build`를 실행하세요."
  exit 1
}

if (-not (Test-Path $config.ChromePath)) {
  Show-RhwpPopup -Message "Chrome 실행 파일을 찾을 수 없습니다.`n`n경로: $($config.ChromePath)"
  exit 1
}

if (-not $config.NpmCommand) {
  Show-RhwpPopup -Message "npm.cmd를 찾을 수 없습니다.`n`nNode.js 설치를 확인하세요."
  exit 1
}

if (-not (Test-RhwpServerReady -Config $config)) {
  $previewArgs = Get-RhwpPreviewArguments -Config $config
  Start-Process -FilePath $config.NpmCommand -ArgumentList $previewArgs -WorkingDirectory $config.StudioDir -WindowStyle Hidden | Out-Null

  $ready = $false
  for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Milliseconds 500
    if (Test-RhwpServerReady -Config $config) {
      $ready = $true
      break
    }
  }

  if (-not $ready) {
    Show-RhwpPopup -Message "RHWP preview 서버를 시작하지 못했습니다.`n`n$($config.PreviewHost):$($config.PreviewPort) 포트 상태와 npm preview 실행 가능 여부를 확인하세요."
    exit 1
  }
}

$appUrl = Get-RhwpAppUrl -Config $config

if ($FilePath) {
  try {
    $resolvedFilePath = (Resolve-Path -LiteralPath $FilePath).Path
    $stageInfo = Get-RhwpLaunchStage -Config $config -FilePath $resolvedFilePath
    Publish-RhwpLaunchFile -StageInfo $stageInfo | Out-Null
    $appUrl = Get-RhwpAppUrl -Config $config -StageInfo $stageInfo
  } catch {
    Show-RhwpPopup -Message "RHWP에서 파일을 열 수 없습니다.`n`n$($_.Exception.Message)"
    exit 1
  }
}

$chromeArgs = Get-RhwpChromeArguments -Config $config -AppUrl $appUrl
Start-Process -FilePath $config.ChromePath -ArgumentList $chromeArgs -WorkingDirectory $config.RepoRoot | Out-Null
