param(
    [string]$DeepSeekApiKey = '',
    [string]$DeepSeekModel = 'deepseek-v4-flash',
    [string]$DefaultTheme = 'Celestial Macaron',
    [switch]$InstallExtensions
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$userRoot = Join-Path $repoRoot 'data/default-user'

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-JsonFile {
    param(
        [string]$Path,
        [object]$Value
    )

    $json = $Value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, $json, [System.Text.UTF8Encoding]::new($false))
}

function Set-JsonProperty {
    param(
        [object]$Object,
        [string]$Name,
        [object]$Value
    )

    if ($null -eq $Object.PSObject.Properties[$Name]) {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    } else {
        $Object.$Name = $Value
    }
}

$relativeDirectories = @(
    '',
    'thumbnails',
    'thumbnails/bg',
    'thumbnails/avatar',
    'thumbnails/persona',
    'worlds',
    'user',
    'user/images',
    'user/files',
    'User Avatars',
    'groups',
    'group chats',
    'chats',
    'characters',
    'backgrounds',
    'NovelAI Settings',
    'KoboldAI Settings',
    'OpenAI Settings',
    'TextGen Settings',
    'themes',
    'movingUI',
    'extensions',
    'instruct',
    'context',
    'QuickReplies',
    'assets',
    'user/workflows',
    'vectors',
    'backups',
    'sysprompt',
    'reasoning'
)

foreach ($relativeDirectory in $relativeDirectories) {
    Ensure-Directory -Path (Join-Path $userRoot $relativeDirectory)
}

$settingsPath = Join-Path $repoRoot 'default/content/settings.json'
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json

$settings.firstRun = $false
$settings.main_api = 'openai'
$settings.max_context = 128000
$settings.amount_gen = 4096
$settings.power_user.theme = $DefaultTheme
$settings.power_user.movingUI = $true
$settings.power_user.movingUIPreset = 'Default'
$settings.power_user.blur_strength = 6
$settings.power_user.chat_width = 55
$settings.power_user.fast_ui_mode = $false
$settings.power_user.noShadows = $false
$settings.power_user.font_scale = 1.05
$settings.power_user.avatar_style = 1
$settings.power_user.waifuMode = $true
$settings.power_user.timestamps_enabled = $true
$settings.power_user.hotswap_enabled = $true

Set-JsonProperty -Object $settings.oai_settings -Name 'chat_completion_source' -Value 'deepseek'
Set-JsonProperty -Object $settings.oai_settings -Name 'deepseek_model' -Value $DeepSeekModel
Set-JsonProperty -Object $settings.oai_settings -Name 'openai_max_context' -Value 128000
Set-JsonProperty -Object $settings.oai_settings -Name 'openai_max_tokens' -Value 4096
Set-JsonProperty -Object $settings.oai_settings -Name 'stream_openai' -Value $true
Set-JsonProperty -Object $settings.oai_settings -Name 'show_external_models' -Value $true
Set-JsonProperty -Object $settings.oai_settings -Name 'use_sysprompt' -Value $true
Set-JsonProperty -Object $settings.oai_settings -Name 'preset_settings_openai' -Value 'DeepSeek V4 Flash'

Write-JsonFile -Path (Join-Path $userRoot 'settings.json') -Value $settings

$presetSourcePath = Join-Path $repoRoot 'default/content/presets/openai/DeepSeek V4 Flash.json'
$presetTargetPath = Join-Path $userRoot 'OpenAI Settings/DeepSeek V4 Flash.json'
Copy-Item -LiteralPath $presetSourcePath -Destination $presetTargetPath -Force

$reasoningSourcePath = Join-Path $repoRoot 'default/content/presets/reasoning/DeepSeek.json'
$reasoningTargetPath = Join-Path $userRoot 'reasoning/DeepSeek.json'
Copy-Item -LiteralPath $reasoningSourcePath -Destination $reasoningTargetPath -Force

$themeSourceDirectory = Join-Path $repoRoot 'default/content/themes'
$themeTargetDirectory = Join-Path $userRoot 'themes'
Get-ChildItem -LiteralPath $themeSourceDirectory -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $themeTargetDirectory $_.Name) -Force
}

if ($DeepSeekApiKey) {
    $secrets = @{
        api_key_deepseek = @(
            @{
                id = [guid]::NewGuid().ToString()
                value = $DeepSeekApiKey
                label = 'DeepSeek API Key'
                active = $true
            }
        )
    }
    Write-JsonFile -Path (Join-Path $userRoot 'secrets.json') -Value $secrets
}

if ($InstallExtensions) {
    $extensionRoot = Join-Path $repoRoot 'public/scripts/extensions/third-party'
    Ensure-Directory -Path $extensionRoot

    $extensions = @(
        @{ Name = 'JS-Slash-Runner'; Repo = 'https://github.com/N0VI028/JS-Slash-Runner' },
        @{ Name = 'SillyTavern-LATheme'; Repo = 'https://github.com/LenAnderson/SillyTavern-LATheme' },
        @{ Name = 'SillyTavern-MoonlitEchoesTheme'; Repo = 'https://github.com/RivelleDays/SillyTavern-MoonlitEchoesTheme' },
        @{ Name = 'SillyTavern-Not-A-Discord-Theme'; Repo = 'https://github.com/IceFog72/SillyTavern-Not-A-Discord-Theme' }
    )

    foreach ($extension in $extensions) {
        $extensionPath = Join-Path $extensionRoot $extension.Name
        if (-not (Test-Path -LiteralPath $extensionPath)) {
            git -c http.version=HTTP/1.1 clone $extension.Repo $extensionPath
        }
    }
}

Write-Host "Local setup completed at $userRoot"
