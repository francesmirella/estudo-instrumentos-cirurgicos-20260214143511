import requests, json, re

instruments = {
"Metzenbaum":"Metzenbaum scissors",
"Mayo":"Mayo scissors",
"Adson atraumática":"Adson forceps without teeth",
"Adson traumática":"Adson forceps toothed",
"Adson dente de rato":"Adson forceps 1x2 teeth",
"Anatômica forceps":"Dressing forceps",
"Dente de rato forceps":"Toothed forceps",
"Halstead":"Halsted mosquito forceps",
"Kelly":"Kelly forceps",
"Crile":"Crile forceps",
"Mixter":"Mixter forceps",
"Kocher":"Kocher forceps",
"Farabeuf":"Farabeuf retractor",
"Válvula Maleável":"Malleable retractor",
"Doyen":"Doyen retractor",
"Deaver":"Deaver retractor",
"Gosset":"Gosset retractor",
"Balfour":"Balfour retractor",
"Finochietto":"Finochietto retractor",
"Adson retractor":"Adson retractor",
"Backaus":"Backhaus towel clamp",
"Clamp Intestinal":"Intestinal clamp",
"Saca-Bocado":"Rongeur",
"Duval":"Duval forceps",
"Allis":"Allis forceps",
"Babcock":"Babcock forceps",
"Cureta de Siemens":"Sims uterine curette",
"Potts":"Potts scissors",
"Satinsky":"Satinsky clamp",
"Collins":"Collin speculum",
"Mayo-Hegar":"Mayo-Hegar needle holder",
"Mathieu":"Mathieu needle holder"
}

S = requests.Session()
api = "https://commons.wikimedia.org/w/api.php"

def search_files(q):
    params = {
        "action":"query","format":"json","generator":"search","gsrsearch":q,
        "gsrnamespace":6,"gsrlimit":10,
        "prop":"imageinfo","iiprop":"url|extmetadata"
    }
    data = S.get(api, params=params, timeout=30).json()
    pages = data.get("query", {}).get("pages", {})
    out = []
    for p in pages.values():
        title = p.get("title", "")
        ii = (p.get("imageinfo") or [{}])[0]
        url = ii.get("url")
        if not url:
            continue
        if not re.search(r"\.(jpg|jpeg|png|webp)$", url, re.I):
            continue
        meta = ii.get("extmetadata", {})
        lic = (meta.get("LicenseShortName", {}) or {}).get("value", "")
        desc = (meta.get("ImageDescription", {}) or {}).get("value", "")
        desc = re.sub("<[^<]+?>", "", desc)[:180]
        out.append({"title": title, "url": url, "license": lic, "desc": desc})
    return out

res = {k: search_files(v)[:6] for k,v in instruments.items()}
print(json.dumps(res, ensure_ascii=False, indent=2))
