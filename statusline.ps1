$json = $input | Out-String
$data = $json | ConvertFrom-Json

# --- Line 1: model, context window bar, tokens and session cost ---
$model = $data.model.display_name
$pct = [math]::Floor([double]$data.context_window.used_percentage)
$inTok = $data.context_window.total_input_tokens
$outTok = $data.context_window.total_output_tokens
$cost = $data.cost.total_cost_usd

$barWidth = 10
$filled = [math]::Floor($pct * $barWidth / 100)
$empty = $barWidth - $filled
$bar = ("#" * $filled) + ("-" * $empty)

$line1 = ("[{0}] {1} {2}% | tokens in:{3} out:{4} | custo: `${5:N2}" -f $model, $bar, $pct, $inTok, $outTok, $cost)

# --- Line 2: plan usage limits (Claude.ai Pro/Max only, after first API response) ---
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
