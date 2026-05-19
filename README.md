<div align="center">

```
 ██████╗ ██╗   ██╗ ██████╗ ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ ██╗  ██╗
 ██╔══██╗██║   ██║██╔════╝ ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗╚██╗██╔╝
 ██████╔╝██║   ██║██║  ███╗███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝ ╚███╔╝
 ██╔══██╗██║   ██║██║   ██║██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗ ██╔██╗
 ██████╔╝╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║██╔╝ ██╗
 ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
```

# BugHunterX v3.0
### Advanced Bug Bounty Recon Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Termux-blue.svg)]()
[![Author](https://img.shields.io/badge/Author-vansh--builds-red.svg)](https://github.com/vansh-builds)

> ⚡ A fully automated, all-in-one bug bounty recon framework that chains 40+ community tools into 11 intelligent scanning phases — from passive recon to vulnerability confirmation to HTML report generation.

**⚠️ For authorized bug bounty programs and penetration testing only. Unauthorized use is illegal.**

</div>

---

## 📌 What is BugHunterX?

BugHunterX is a bash-based bug bounty automation framework that runs **11 sequential phases** of recon and vulnerability scanning on a target domain. Instead of running tools one by one manually, BugHunterX chains them all together, feeds output from one tool into the next, and generates a complete structured report at the end.

It was built for bug bounty hunters who want to automate the repetitive recon phase so they can focus on manual exploitation and report writing.

---

## ✨ Features

- 🔍 **Passive Recon** — WHOIS, DNS, ASN, Shodan, Censys, crt.sh, Wayback, GAU
- 🌐 **Subdomain Enumeration** — Subfinder, Amass, Assetfinder, PureDNS brute force, AlterX permutations
- 🟢 **Live Host Detection** — httpx fingerprinting, WAF detection, CDN detection, screenshots
- 🔌 **Port Scanning** — Naabu fast scan + Nmap service/version detection
- 📂 **Endpoint Discovery** — Katana, Hakrawler, GoSpider, FFUF directory/vhost/API bruteforce
- 🟨 **JavaScript Analysis** — jsluice, getJS, regex secret hunting, source map detection
- 🎯 **Parameter Discovery** — Arjun, x8, GF pattern categorization
- 💀 **Subdomain Takeover** — Subzy, Subjack, manual CNAME checking
- 🐛 **Vulnerability Scanning** — XSS, SQLi, SSRF, LFI, SSTI, Open Redirect, CORS, Host Header, CRLF, JWT, GraphQL, IDOR, Prototype Pollution
- ☢️ **Nuclei CVE Scanning** — Critical/High/Medium + 9 tag-based template groups
- 📊 **Auto Report Generation** — Full structured text report + interactive HTML report with severity cards

---

## 🛠️ Tools Used

| Category | Tools |
|----------|-------|
| Subdomain | subfinder, amass, assetfinder, dnsx, puredns, alterx, shuffledns |
| Live Detection | httpx, httprobe, cdncheck, wafw00f |
| Port Scanning | naabu, nmap |
| Crawling | katana, gospider, hakrawler, waybackurls, gau, gauplus |
| Fuzzing | ffuf, gobuster |
| Parameters | arjun, x8, gf, qsreplace, uro |
| JavaScript | getJS, jsluice, mantra |
| Vulnerabilities | dalfox, kxss, gxss, sqlmap, crlfuzz, corsme, ppmap, interactsh-client |
| Takeover | subzy, subjack |
| Secrets | trufflehog, gitleaks, s3scanner |
| CVE Scanning | nuclei |
| OSINT | uncover, asnmap, tlsx, cvemap |
| Utilities | anew, unfurl, notify, mapcidr |

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| OS | Kali Linux / Ubuntu / Parrot / Termux |
| Go | 1.21+ |
| Python | 3.8+ |
| Bash | 4.0+ |
| Tools | git, curl, wget, jq, nmap, whois |

---

## 🚀 Installation

### Kali Linux / Ubuntu / Parrot

```bash
# Step 1 — Install system dependencies
sudo apt update && sudo apt install -y git golang-go python3 python3-pip curl wget jq nmap whois dnsutils bc

# Step 2 — Clone the repo
git clone https://github.com/vansh-builds/bughunterx.git
cd bughunterx

# Step 3 — Give execute permission
chmod +x bughunt2.sh

# Step 4 — Install all tools (only needed once)
./bughunt2.sh
# When menu appears → type 6 → press Enter
# This installs 40+ Go tools, Python tools, wordlists, nuclei templates
# Takes 10-20 minutes on first run
```

### Termux (Android)

```bash
# Step 1 — Install system dependencies
pkg update && pkg install -y git golang python curl wget jq nmap whois dnsutils bc

# Step 2 — Clone the repo
git clone https://github.com/vansh-builds/bughunterx.git
cd bughunterx

# Step 3 — Give execute permission
chmod +x bughunt2.sh

# Step 4 — Install all tools
./bughunt2.sh
# When menu appears → type 6 → press Enter
```

### One-liner (Kali)

```bash
sudo apt update && sudo apt install -y git golang-go python3 python3-pip curl wget jq nmap whois && git clone https://github.com/vansh-builds/bughunterx.git && cd bughunterx && chmod +x bughunt2.sh && ./bughunt2.sh
```

---

## 📖 Usage

```bash
cd bughunterx
./bughunt2.sh
```

You will see this menu:

```
  [1] Full Scan          — All 11 phases (Recommended)
  [2] Quick Recon        — Subdomain + Live hosts + Headers
  [3] Vuln Scan Only     — Recon + all vuln checks + nuclei
  [4] JS Analysis Only   — JavaScript secrets + endpoints
  [5] Subdomain Takeover — Takeover check only
  [6] Install All Tools  — Install all dependencies
  [7] Exit
```

### Example — Full Scan

```
./bughunt2.sh

Type I_HAVE_PERMISSION to confirm authorization: I_HAVE_PERMISSION

Select Scan Mode: 1

Target domain: example.com
```

### Adding API Keys (optional but recommended)

Open `bughunt2.sh` and fill in your API keys at the top for better results:

```bash
SECURITYTRAILS_API="your_key_here"
SHODAN_API="your_key_here"
VIRUSTOTAL_API="your_key_here"
CHAOS_API="your_key_here"
```

| API | Free Tier | Get it at |
|-----|-----------|-----------|
| SecurityTrails | 50 queries/month | securitytrails.com |
| Shodan | Limited free | shodan.io |
| VirusTotal | 500 req/day | virustotal.com |
| Chaos | Free for researchers | chaos.projectdiscovery.io |

---

## 📁 Output Structure

```
~/bugbounty_results/example.com_20240519_143022/
│
├── 📄 BUGHUNTERX_REPORT.txt        ← Full text report
├── 🌐 BUGHUNTERX_REPORT.html       ← Interactive HTML report (open in browser)
│
├── findings/
│   ├── ALL_FINDINGS.txt            ← Every finding in one file
│   ├── CRITICAL.txt                ← Critical severity only
│   ├── HIGH.txt                    ← High severity only
│   ├── MEDIUM.txt
│   └── LOW.txt / INFO.txt
│
├── subdomains/
│   ├── MASTER_SUBDOMAINS.txt       ← All unique subdomains found
│   ├── passive/                    ← Per-tool passive results
│   ├── brute/                      ← Bruteforce results
│   └── permutations/               ← AlterX permutation results
│
├── live/http/
│   ├── live_urls.txt               ← All live URLs
│   ├── httpx_full.json             ← Full httpx fingerprint data
│   └── status_200/301/403...       ← URLs grouped by HTTP code
│
├── ports/
│   ├── naabu/open_ports.txt        ← Open ports
│   └── nmap/nmap_detailed.txt      ← Nmap service scan
│
├── endpoints/
│   ├── ALL_URLS_DEDUPED.txt        ← All discovered URLs deduplicated
│   └── admin/admin_panels.txt      ← Admin/login panels found
│
├── js/
│   ├── files/js_list.txt           ← All JS files found
│   ├── secrets/all_secrets.txt     ← Hardcoded secrets found in JS
│   └── sourcemaps/                 ← Exposed source maps
│
└── vulnerabilities/
    ├── xss/                        ← XSS findings
    ├── sqli/                       ← SQLi findings
    ├── ssrf/                       ← SSRF findings
    ├── lfi/                        ← LFI findings
    ├── cors/                       ← CORS findings
    ├── subdomain_takeover/         ← Takeover findings
    ├── cve/                        ← Nuclei CVE findings
    └── secrets/                    ← AWS/cloud secrets
```

---

## 🔍 Scan Phases

| Phase | Name | What it does |
|-------|------|-------------|
| 1 | Passive Recon | WHOIS, DNS records, zone transfer, SPF/DMARC, ASN, crt.sh, Shodan, Wayback, Google/GitHub dorks |
| 2 | Subdomain Enum | Subfinder + Amass + Assetfinder passive, PureDNS brute force, AlterX permutations, dnsx resolution |
| 3 | Live Hosts | httpx full fingerprint, WAF detection, CDN check, screenshots, interesting subdomain flagging |
| 4 | Port Scan | Naabu top-1000 fast scan, Nmap -sV -sC service detection, dangerous service alerting |
| 5 | Endpoint Discovery | Katana/Hakrawler/GoSpider crawl, FFUF dir/backup/API/vhost bruteforce, sensitive file checks, admin panel discovery |
| 6 | JS Analysis | JS file collection, jsluice URL/secret extraction, 15 regex secret patterns, source map detection |
| 7 | Param Discovery | Arjun + x8 hidden params, GF pattern categorization of all URLs into vuln buckets |
| 8 | Subdomain Takeover | Subzy + Subjack + manual CNAME checking against 14 cloud providers |
| 9 | Vuln Scanning | XSS (kxss+dalfox), SQLi (sqlmap), SSRF, Open Redirect, CRLF, CORS, Host Header, LFI, SSTI, GraphQL, IDOR, JWT |
| 10 | Nuclei | Critical/High/Medium + 9 tag groups: CVE, exposure, misconfig, sqli/xss/lfi/rce, takeover, panel, GraphQL, JWT, cloud |
| 11 | Report | Text report + interactive HTML report with severity cards, collapsible findings, live host table |

---

## 📸 Report Preview

The HTML report includes:
- Severity dashboard (Critical / High / Medium / Low / Info counts)
- Stats (subdomains, live hosts, endpoints, open ports)
- All findings as collapsible cards (Critical and High auto-expanded)
- Proof of concept and curl commands for each finding
- Remediation guidance for every vulnerability
- Live host table with status codes and tech stack
- Manual testing checklist

---

## ⚙️ Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `THREADS` | 50 | Concurrent threads for httpx/ffuf |
| `RATE_LIMIT` | 150 | Requests per second |
| `INTERACTSH_SERVER` | oast.pro | OOB server for blind SSRF/XSS |

---

## ⚠️ Legal Disclaimer

```
This tool is for authorized bug bounty programs and penetration testing only.
The author is not responsible for any misuse or damage caused by this tool.
Always obtain written permission before testing any target.
Unauthorized use violates the Computer Fraud and Abuse Act (CFAA) and
equivalent laws in your country.
```

---

## 👤 Author

**vansh-builds**
- GitHub: [@vansh-builds](https://github.com/vansh-builds)

---

## ⭐ Support

If this tool helped you find a bug — drop a ⭐ on the repo!
