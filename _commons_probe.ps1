$instruments = [ordered]@{
  'Metzenbaum'=@('Metzenbaum scissors');
  'Mayo'=@('Mayo scissors');
  'Adson atraumática'=@('Adson forceps without teeth','Adson dressing forceps');
  'Adson traumática'=@('Adson toothed forceps','Adson tissue forceps');
  'Adson dente de rato'=@('Adson forceps 1x2 teeth','Adson rat tooth forceps');
  'Anatômica forceps'=@('Dressing forceps','anatomical forceps');
  'Dente de rato forceps'=@('Toothed forceps','rat tooth forceps');
  'Halstead'=@('Halsted mosquito forceps','mosquito hemostat');
  'Kelly'=@('Kelly forceps','Kelly clamp');
  'Crile'=@('Crile forceps','Crile hemostatic clamp');
  'Mixter'=@('Mixter forceps','right angle clamp');
  'Kocher'=@('Kocher forceps','Ochsner forceps');
  'Farabeuf'=@('Farabeuf retractor');
  'Válvula Maleável'=@('Malleable retractor','Ribbon retractor');
  'Doyen'=@('Doyen retractor','Doyen intestinal clamp');
  'Deaver'=@('Deaver retractor');
  'Gosset'=@('Gosset retractor');
  'Balfour'=@('Balfour retractor');
  'Finochietto'=@('Finochietto retractor','rib spreader');
  'Adson retractor'=@('Adson retractor');
  'Backaus'=@('Backhaus towel clamp');
  'Clamp Intestinal'=@('Intestinal clamp','Doyen intestinal clamp');
  'Saca-Bocado'=@('Rongeur','bone rongeur');
  'Duval'=@('Duval forceps','Pennington forceps');
  'Allis'=@('Allis forceps','Allis tissue forceps');
  'Babcock'=@('Babcock forceps');
  'Cureta de Siemens'=@('Sims uterine curette','uterine curette');
  'Potts'=@('Potts scissors','Pott scissors');
  'Satinsky'=@('Satinsky clamp');
  'Collins'=@('Collin speculum','Collins speculum');
  'Mayo-Hegar'=@('Mayo-Hegar needle holder');
  'Mathieu'=@('Mathieu needle holder')
}

$all = [ordered]@{}
foreach ($name in $instruments.Keys) {
  $seen = @{}
  $list = @()
  foreach ($q in $instruments[$name]) {
    $uri = 'https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=12&prop=imageinfo&iiprop=url|extmetadata&gsrsearch=' + [uri]::EscapeDataString($q)
    try {
      $resp = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 30
    } catch {
      continue
    }
    if ($resp.query.pages) {
      foreach ($p in $resp.query.pages.PSObject.Properties.Value) {
        $ii = $p.imageinfo[0]
        if (-not $ii) { continue }
        $url = $ii.url
        if (-not $url) { continue }
        if ($url -notmatch '\.(jpg|jpeg|png|webp)$') { continue }
        if ($seen.ContainsKey($url)) { continue }
        $seen[$url] = $true
        $lic = ''
        if ($ii.extmetadata -and $ii.extmetadata.LicenseShortName) { $lic = $ii.extmetadata.LicenseShortName.value }
        $desc = ''
        if ($ii.extmetadata -and $ii.extmetadata.ImageDescription) { $desc = $ii.extmetadata.ImageDescription.value }
        $list += [pscustomobject]@{
          title = $p.title
          url = $url
          license = $lic
          desc = $desc
        }
      }
    }
  }
  $all[$name] = @($list | Select-Object -First 12)
}

$json = $all | ConvertTo-Json -Depth 8
Set-Content -Path .\_commons_candidates.json -Value $json -Encoding UTF8
Write-Output 'Wrote _commons_candidates.json'
