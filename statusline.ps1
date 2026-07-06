$json = $input | Out-String
$data = $json | ConvertFrom-Json

$model = $data.model.display_name
$pct = [math]::Floor([double]$data.context_window.used_percentage)
$inTok = $data.context_window.total_input_tokens
$outTok = $data.context_window.total_output_tokens
$cost = $data.cost.total_cost_usd

$barWidth = 10
$filled = [math]::Floor($pct * $barWidth / 100)
$empty = $barWidth - $filled
$bar = ("#" * $filled) + ("-" * $empty)

Write-Output ("[{0}] {1} {2}% | tokens in:{3} out:{4} | custo: `${5:N2}" -f $model, $bar, $pct, $inTok, $outTok, $cost)
