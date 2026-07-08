$json = $input | Out-String
$data = $json | ConvertFrom-Json

$inv = [System.Globalization.CultureInfo]::InvariantCulture

# Garante que os blocos/setas apareçam certos, independente do encoding do arquivo.
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# Glifos montados por code point para o .ps1 continuar em ASCII puro
# (evita o Windows PowerShell 5.1 decodificar errado um arquivo UTF-8 sem BOM).
$block = [char]0x2588   # bloco cheio  (█)
$shade = [char]0x2591   # bloco vazio  (░)
$up    = [char]0x2191   # seta p/ cima (↑) = tokens de entrada
$down  = [char]0x2193   # seta p/ baixo(↓) = tokens de saída

# Cores ANSI
$e     = [char]27
$reset = "$e[0m"
$dim   = "$e[90m"

function Format-Num([double]$n) {
    if ($n -ge 1000000) { return (($n / 1000000).ToString("0.#", $inv) + "M") }
    if ($n -ge 1000)    { return (($n / 1000).ToString("0.#", $inv) + "k") }
    return ([math]::Round($n)).ToString($inv)
}

# --- Linha 1: modelo, barra de contexto, tokens e custo da sessao ---
$model = if ($data.model.display_name) { $data.model.display_name } else { "?" }

$pct = 0
if ($data.context_window -and $null -ne $data.context_window.used_percentage) {
    $pct = [math]::Floor([double]$data.context_window.used_percentage)
}
if ($pct -lt 0)   { $pct = 0 }
if ($pct -gt 100) { $pct = 100 }

$inTok = 0; $outTok = 0
if ($data.context_window) {
    if ($data.context_window.total_input_tokens)  { $inTok  = $data.context_window.total_input_tokens }
    if ($data.context_window.total_output_tokens) { $outTok = $data.context_window.total_output_tokens }
}

$cost = 0.0
if ($data.cost -and $null -ne $data.cost.total_cost_usd) { $cost = [double]$data.cost.total_cost_usd }

# Cor da barra conforme o quanto o contexto encheu
if     ($pct -ge 90) { $color = "$e[91m" }   # vermelho: contexto quase cheio
elseif ($pct -ge 70) { $color = "$e[93m" }   # amarelo:  atencao
else                 { $color = "$e[92m" }   # verde:    tranquilo

$barWidth = 10
$filled = [math]::Floor($pct * $barWidth / 100)
$empty  = $barWidth - $filled
$bar = $color + ($block.ToString() * $filled) + $dim + ($shade.ToString() * $empty) + $reset

$tokensStr = "tokens {0}{1} {2}{3}" -f (Format-Num $inTok), $up, (Format-Num $outTok), $down
$costStr   = "`$" + $cost.ToString("N2", $inv)

$line1 = "[{0}] {1} ctx {2}% | {3} | {4}" -f $model, $bar, $pct, $tokensStr, $costStr

# --- Linha 2: limites do plano (Claude.ai Pro/Max, apos a 1a resposta da API) ---
$rl = $data.rate_limits
$parts = @()
if ($rl) {
    if ($null -ne $rl.five_hour -and $null -ne $rl.five_hour.used_percentage) {
        $s = "sessao 5h: {0}%" -f [math]::Floor([double]$rl.five_hour.used_percentage)
        if ($rl.five_hour.resets_at) {
            $t = [DateTimeOffset]::FromUnixTimeSeconds([long]$rl.five_hour.resets_at).LocalDateTime.ToString("HH:mm")
            $s += " (reinicia $t)"
        }
        $parts += $s
    }
    if ($null -ne $rl.seven_day -and $null -ne $rl.seven_day.used_percentage) {
        $s = "semana: {0}%" -f [math]::Floor([double]$rl.seven_day.used_percentage)
        if ($rl.seven_day.resets_at) {
            $t = [DateTimeOffset]::FromUnixTimeSeconds([long]$rl.seven_day.resets_at).LocalDateTime.ToString("ddd HH:mm")
            $s += " (reinicia $t)"
        }
        $parts += $s
    }
}

if ($parts.Count -gt 0) {
    Write-Output ($line1 + "`n" + "Plano | " + ($parts -join " | "))
} else {
    Write-Output $line1
}
