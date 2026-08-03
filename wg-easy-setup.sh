#!/usr/bin/env bash
#
# wg-easy-setup.sh - interaktives Setup für wg-easy (v15) / interactive setup for wg-easy (v15)
#
# Projekt / project: https://github.com/wg-easy/wg-easy   (AGPL-3.0)
# Docs:              https://wg-easy.github.io/wg-easy/latest/
#
#   ./wg-easy-setup.sh
#
# shellcheck disable=SC2059  # M[] entries are trusted printf format strings (i18n placeholders)
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

DIR="/etc/docker/containers/wg-easy"
IMAGE="ghcr.io/wg-easy/wg-easy:15"
UILANG="de"

B=$'\033[1m'; N=$'\033[0m'; Y=$'\033[33m'; G=$'\033[32m'; R=$'\033[31m'
[[ -t 1 ]] || { B=""; N=""; Y=""; G=""; R=""; }

declare -A M

# ================================================================== Deutsch
lang_de() {
M=(
[hint_yes]="[J/n]"                [hint_no]="[j/N]"
[sel]="Auswahl"                   [sel_err]="Bitte eine Zahl zwischen 1 und"
[err]="FEHLER"
[need_root]="Bitte als root ausführen."
[need_tty]="Das Skript ist interaktiv und braucht ein Terminal."

[title]="wg-easy einrichten"
[intro1]="Ich stelle dir ein paar Fragen. Enter übernimmt jeweils den"
[intro2]="Vorschlag in eckigen Klammern."

[s1]="1. Zugriff auf die Weboberfläche"
[q_ui]="Wie soll die Oberfläche erreichbar sein?"
[ui1]="Öffentlich per HTTPS mit eigenem DNS-Namen (empfohlen)"
[ui2]="Öffentlich per HTTP auf der Server-IP"
[ui3]="Nur lokal, Zugriff über SSH-Tunnel"
[q_domain]="DNS-Name, der auf diesen Server zeigt"
[e_domain]="Ohne DNS-Namen geht diese Variante nicht."
[q_email]="E-Mail für Let's Encrypt (optional)"
[w_http]="Damit laufen Admin-Passwort und Client-Schlüssel unverschlüsselt über die Leitung."
[q_http]="Trotzdem so machen?"

[s2]="2. Verbindungsdaten"
[detecting]="Ermittle die öffentliche Adresse ..."
[q_host]="Adresse, mit der sich Clients verbinden"
[e_host]="Ohne Adresse können sich keine Clients verbinden."
[q_site]="Standort-Nummer (1-99) - daraus wird das Tunnelnetz gebildet"
[site_nets]="Ergibt: IPv4 %s und IPv6 %s"
[q_customnet]="Netze lieber selbst festlegen?"
[q_v4cidr]="IPv4-Tunnelnetz (CIDR)"
[q_v6cidr]="IPv6-Tunnelnetz (CIDR)"
[e_cidr]="Das sieht nicht wie eine gueltige CIDR-Angabe aus."
[l_net]="Tunnelnetz"
[cidr_warn1]="Achtung: Die Tunnelnetze werden nur beim allerersten Start eines Containers uebernommen."
[cidr_warn2]="Hier existiert schon eine Datenbank, die neuen Netze wuerden also ignoriert."
[q_reset]="Datenbank zuruecksetzen? Alle vorhandenen Clients dieses Servers gehen dabei verloren."
[reset_done]="Datenbank zurueckgesetzt, die neuen Netze greifen jetzt."
[q_wgport]="WireGuard-Port (UDP)"
[q_uiport]="Port der Weboberfläche (TCP)"
[q_uiport_l]="Lokaler Port der Weboberfläche (TCP)"
[e_port]="Port muss eine Zahl sein."

[s3]="3. Zugangsdaten und DNS"
[q_user]="Benutzername für die Oberfläche"
[q_genpw]="Passwort automatisch erzeugen?"
[q_dns]="DNS-Server für die Clients"
[pw]="Passwort"                   [pw_rep]="Wiederholen"
[pw_diff]="Stimmt nicht überein, nochmal."
[pw_short]="Mindestens 12 Zeichen bitte - wg-easy prüft das selbst nicht."

[summary]="Zusammenfassung"
[l_ui]="Oberfläche"               [l_client]="Client-Adresse"
[l_user]="Benutzer"               [l_pw]="Passwort"
[l_dns]="Client-DNS"              [l_files]="Dateien"
[unenc]="unverschlüsselt"
[caddy_cert]="Caddy holt das Zertifikat"
[localonly]="nur localhost:%s, Zugriff per SSH-Tunnel"
[open_ports]="Beim Hoster freizugeben:"
[q_apply]="So einrichten?"
[aborted]="Abgebrochen."

[old_wg]="Altes wg-quick@wg0 gefunden - wird gestoppt (belegt sonst den Port)."
[old_nft]="Altes nftables-Regelwerk gefunden - wird entfernt (blockt sonst Docker)."
[old_files]="Alte WireGuard-Dateien liegen jetzt in /root/wg-setup-alt/"
[nat1]="Lokale Adresse %s und Außen-IP %s unterscheiden sich."
[nat2]="Der Server steht hinter NAT - der Hoster muss den WireGuard-Port weiterleiten."
[dock_ok]="Docker ist bereits installiert."
[dock_inst]="Docker wird installiert, das dauert einen Moment ..."
[dock_miss]="Docker-Compose-Plugin fehlt. Siehe https://docs.docker.com/engine/install/"
[writing]="Konfiguration nach %s schreiben ..."
[starting]="Container starten ..."
[not_running]="Container läuft nicht (Status: %s). Letzte Logzeilen:"
[start_fail]="Start fehlgeschlagen."

[done]="Fertig - wg-easy läuft."
[caddy1]="Caddy holt gerade das Zertifikat. Voraussetzung: %s zeigt"
[caddy2]="auf diesen Server und TCP 80/443 sind von außen erreichbar."
[ssh1]="Zugriff per SSH-Tunnel von deinem Rechner:"
[ssh2]="Danach im Browser: http://127.0.0.1:%s"
[rerun1]="Für Status, Logs oder Änderungen einfach wieder starten:"

[menu]="wg-easy - Verwaltung"
[m_state]="Container"             [m_host]="Host"           [m_port]="Port"
[q_menu]="Was möchtest du tun?"
[m1]="Status anzeigen"            [m2]="Logs anzeigen"
[m3]="Neu starten"                [m4]="Auf neueste Version aktualisieren"
[m5]="Einstellungen ändern"       [m6]="Zugangsdaten anzeigen"
[m7]="Diagnose ausführen"         [m8]="Deinstallieren"
[m9]="Beenden"
[nft_active]="Es ist ein nftables-Regelwerk mit 'policy drop' aktiv. Das blockiert sehr wahrscheinlich die Weboberfläche."
[q_flush]="Regelwerk jetzt leeren? (Docker baut seine eigenen Regeln danach neu auf)"
[d_title]="Diagnose"
[d_ports]="Veröffentlichte Ports"
[d_ips]="Adressen dieses Servers"
[d_ext]="von außen sichtbar"
[d_local_ok]="Die Oberfläche antwortet lokal auf dem Server (HTTP %s)."
[d_outside]="Sie ist also da. Wenn sie von außen nicht erreichbar ist, filtert etwas davor - Hoster-Firewall oder Security Group."
[d_local_fail]="Die Oberfläche antwortet lokal nicht (HTTP %s) - dann liegt es am Container, nicht am Netz."
[d_nftdrop]="Achtung, INPUT-Kette mit 'policy drop' aktiv:"
[d_acme1]="Let's Encrypt konnte den Server von außen nicht erreichen (Timeout auf Port 80 und 443)."
[d_acme2]="Das heißt: eingehender Verkehr wird vor dem Server gefiltert. Bitte beim Hoster bzw. in der Security Group TCP 80, TCP 443 und UDP 51820 freigeben."
[d_logs]="Letzte Logzeilen"
[d_hint]="Tipp: Läuft die Oberfläche lokal, kommst du jederzeit per SSH-Tunnel dran:"
[no_ports]="keine passenden Ports"
[restarted]="Neu gestartet."
[updating]="Aktualisiere ..."     [updated]="Erledigt."
[q_uninst]="Was soll entfernt werden?"
[u1]="Nur den Container (Clients bleiben erhalten)"
[u2]="Alles inklusive Clients und Schlüssel"
[u3]="Doch nichts"
[u_conf]="Wirklich alles löschen? Das ist endgültig."
[u_done1]="Container entfernt."   [u_done2]="Alles entfernt."
[absent]="nicht vorhanden"
[e_domain_fmt]="Das sieht nicht wie ein gueltiger DNS-Name aus."
[e_email_fmt]="Das sieht nicht wie eine gueltige E-Mail-Adresse aus."
[e_dns_fmt]="Bitte kommagetrennte IP-Adressen angeben (z. B. 1.1.1.1,1.0.0.1)."
[dns_custom]="Eigener DNS-Server"
[no_ipv6]="Der Host hat kein aktives IPv6 - der Tunnel wird ohne IPv6 eingerichtet."
[ipv6_off]="IPv6 aus"
[compose_fail]="Docker konnte die Images nicht laden oder den Container nicht starten."
[docker_dl]="Docker-Installationsskript konnte nicht geladen werden."
)
}

# ================================================================== English
lang_en() {
M=(
[hint_yes]="[Y/n]"                [hint_no]="[y/N]"
[sel]="Choice"                    [sel_err]="Please enter a number between 1 and"
[err]="ERROR"
[need_root]="Please run as root."
[need_tty]="This script is interactive and needs a terminal."

[title]="Set up wg-easy"
[intro1]="I'll ask you a few questions. Press Enter to accept the"
[intro2]="suggestion shown in square brackets."

[s1]="1. Web interface access"
[q_ui]="How should the interface be reachable?"
[ui1]="Public via HTTPS with your own DNS name (recommended)"
[ui2]="Public via plain HTTP on the server IP"
[ui3]="Local only, access through an SSH tunnel"
[q_domain]="DNS name pointing to this server"
[e_domain]="This option needs a DNS name."
[q_email]="Email for Let's Encrypt (optional)"
[w_http]="Admin password and client keys will travel unencrypted over the wire."
[q_http]="Continue anyway?"

[s2]="2. Connection details"
[detecting]="Detecting the public address ..."
[q_host]="Address clients will connect to"
[e_host]="Clients cannot connect without an address."
[q_site]="Site number (1-99) - the tunnel network is derived from it"
[site_nets]="Results in: IPv4 %s and IPv6 %s"
[q_customnet]="Rather define the networks yourself?"
[q_v4cidr]="IPv4 tunnel network (CIDR)"
[q_v6cidr]="IPv6 tunnel network (CIDR)"
[e_cidr]="That does not look like a valid CIDR."
[l_net]="Tunnel network"
[cidr_warn1]="Careful: tunnel networks are only applied on the very first start of a container."
[cidr_warn2]="A database already exists here, so the new networks would be ignored."
[q_reset]="Reset the database? All existing clients on this server will be lost."
[reset_done]="Database reset, the new networks are in effect now."
[q_wgport]="WireGuard port (UDP)"
[q_uiport]="Web interface port (TCP)"
[q_uiport_l]="Local web interface port (TCP)"
[e_port]="Port must be a number."

[s3]="3. Credentials and DNS"
[q_user]="Username for the interface"
[q_genpw]="Generate a password automatically?"
[q_dns]="DNS servers for the clients"
[pw]="Password"                   [pw_rep]="Repeat"
[pw_diff]="They don't match, try again."
[pw_short]="At least 12 characters please - wg-easy does not check this itself."

[summary]="Summary"
[l_ui]="Interface"                [l_client]="Client address"
[l_user]="Username"               [l_pw]="Password"
[l_dns]="Client DNS"              [l_files]="Files"
[unenc]="unencrypted"
[caddy_cert]="Caddy obtains the certificate"
[localonly]="localhost:%s only, access through an SSH tunnel"
[open_ports]="Open these at your host:"
[q_apply]="Set it up like this?"
[aborted]="Cancelled."

[old_wg]="Found an old wg-quick@wg0 - stopping it (it would occupy the port)."
[old_nft]="Found an old nftables ruleset - removing it (it would block Docker)."
[old_files]="Old WireGuard files moved to /root/wg-setup-alt/"
[nat1]="Local address %s and external IP %s differ."
[nat2]="The server is behind NAT - your host must forward the WireGuard port."
[dock_ok]="Docker is already installed."
[dock_inst]="Installing Docker, this takes a moment ..."
[dock_miss]="Docker Compose plugin missing. See https://docs.docker.com/engine/install/"
[writing]="Writing configuration to %s ..."
[starting]="Starting containers ..."
[not_running]="Container is not running (status: %s). Last log lines:"
[start_fail]="Startup failed."

[done]="Done - wg-easy is running."
[caddy1]="Caddy is fetching the certificate. Requirements: %s points"
[caddy2]="to this server and TCP 80/443 are reachable from outside."
[ssh1]="Access through an SSH tunnel from your machine:"
[ssh2]="Then open in your browser: http://127.0.0.1:%s"
[rerun1]="For status, logs or changes just run it again:"

[menu]="wg-easy - management"
[m_state]="Container"             [m_host]="Host"           [m_port]="Port"
[q_menu]="What would you like to do?"
[m1]="Show status"                [m2]="Show logs"
[m3]="Restart"                    [m4]="Update to the latest version"
[m5]="Change settings"            [m6]="Show credentials"
[m7]="Run diagnostics"            [m8]="Uninstall"
[m9]="Quit"
[nft_active]="An nftables ruleset with 'policy drop' is active. That is very likely blocking the web interface."
[q_flush]="Flush the ruleset now? (Docker rebuilds its own rules afterwards)"
[d_title]="Diagnostics"
[d_ports]="Published ports"
[d_ips]="Addresses of this server"
[d_ext]="visible from outside"
[d_local_ok]="The interface responds locally on the server (HTTP %s)."
[d_outside]="So it is up. If it is unreachable from outside, something in front is filtering - host firewall or security group."
[d_local_fail]="The interface does not respond locally (HTTP %s) - so the container is the problem, not the network."
[d_nftdrop]="Careful, INPUT chain with 'policy drop' is active:"
[d_acme1]="Let's Encrypt could not reach this server from outside (timeout on ports 80 and 443)."
[d_acme2]="That means inbound traffic is filtered in front of the server. Please open TCP 80, TCP 443 and UDP 51820 at your host or in the security group."
[d_logs]="Last log lines"
[d_hint]="Tip: if it runs locally you can always reach it through an SSH tunnel:"
[no_ports]="no matching ports"
[restarted]="Restarted."
[updating]="Updating ..."         [updated]="Done."
[q_uninst]="What should be removed?"
[u1]="Container only (clients are kept)"
[u2]="Everything including clients and keys"
[u3]="Nothing after all"
[u_conf]="Really delete everything? This cannot be undone."
[u_done1]="Container removed."    [u_done2]="Everything removed."
[absent]="not present"
[e_domain_fmt]="That does not look like a valid DNS name."
[e_email_fmt]="That does not look like a valid email address."
[e_dns_fmt]="Please enter comma-separated IP addresses (e.g. 1.1.1.1,1.0.0.1)."
[dns_custom]="Custom DNS server"
[no_ipv6]="This host has no active IPv6 - setting up the tunnel without IPv6."
[ipv6_off]="IPv6 off"
[compose_fail]="Docker could not pull the images or start the container."
[docker_dl]="Could not download the Docker installation script."
)
}

die()  { echo "${R}${M[err]:-ERROR}:${N} $*" >&2; exit 1; }
info() { echo "${G}>>${N} $*"; }
warn() { echo "${Y}!!${N} $*" >&2; }
line() { echo "------------------------------------------------------------"; }

# ============================================================ Eingabehilfen
ask() {
  local prompt="$1" def="${2:-}" ans
  if [[ -n "$def" ]]; then
    read -r -p "  ${prompt} [${def}]: " ans || true
  else
    read -r -p "  ${prompt}: " ans || true
  fi
  echo "${ans:-$def}"
}

ask_yes() {                       # ask_yes "Frage" yes|no  -> 0 = ja/yes
  local prompt="$1" def="${2:-yes}" ans hint
  [[ "$def" == "yes" ]] && hint="${M[hint_yes]}" || hint="${M[hint_no]}"
  read -r -p "  ${prompt} ${hint}: " ans || true
  if [[ -z "$ans" ]]; then [[ "$def" == "yes" ]]; return $?; fi
  [[ "${ans,,}" =~ ^(j|ja|y|yes)$ ]]
}

ask_secret() {
  local pw1 pw2
  while true; do
    read -r -s -p "  ${M[pw]}: " pw1 || true; echo >&2
    read -r -s -p "  ${M[pw_rep]}: " pw2 || true; echo >&2
    if [[ "$pw1" != "$pw2" ]]; then
      echo "  ${M[pw_diff]}" >&2
    elif [[ ${#pw1} -lt 12 ]]; then
      echo "  ${M[pw_short]}" >&2
    else
      echo "$pw1"; return 0
    fi
  done
}

choose() {                        # choose "Titel" "A" "B" ... -> Index (1-based)
  local title="$1"; shift
  local opts=("$@") i ans
  echo "  ${title}" >&2
  for i in "${!opts[@]}"; do echo "    $((i+1))) ${opts[$i]}" >&2; done
  while true; do
    read -r -p "  ${M[sel]} [1]: " ans || true
    ans="${ans:-1}"
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 && ans <= ${#opts[@]} )); then
      echo "$ans"; return 0
    fi
    echo "  ${M[sel_err]} ${#opts[@]}." >&2
  done
}

gen_pw() { ( set +o pipefail; LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24 ); }

# Docker Compose interpoliert $ auch in .env-Werten. Daher beim Schreiben
# $ -> $$ maskieren und beim Lesen wieder $$ -> $ (sonst zerlegt Compose z. B.
# Passwoerter, die ein $ enthalten).
esc_env() { local s="$1"; printf '%s' "${s//$/\$\$}"; }
envget() {
  [[ -f "${DIR}/.env" ]] || return 0
  local v
  v="$(sed -n "s/^$1=//p" "${DIR}/.env" 2>/dev/null | head -1)" || true
  printf '%s' "${v//\$\$/\$}"
}

valid_domain() { [[ "$1" =~ ^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,}$ ]]; }
valid_email()  { [[ "$1" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]]; }
valid_dns() {
  local list="$1" ip; [[ -n "$list" ]] || return 1
  local -a parts; IFS=',' read -ra parts <<< "$list" || true
  for ip in "${parts[@]}"; do
    ip="${ip// /}"
    [[ "$ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] && continue
    [[ "$ip" == *:* && "$ip" =~ ^[0-9A-Fa-f:]+$ ]] && continue
    return 1
  done
  return 0
}
ipv6_available() {
  [[ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ]] || return 1
  [[ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)" == "0" ]]
}

# ============================================================= Sprachauswahl
pick_language() {
  local def ans
  def="$(envget UI_LANG)"; def="${def:-de}"
  echo
  line
  echo "${B} Sprache / Language${N}"
  line
  echo "    1) Deutsch"
  echo "    2) English"
  local d=1; [[ "$def" == "en" ]] && d=2
  read -r -p "  Auswahl / Choice [${d}]: " ans || true
  ans="${ans:-$d}"
  case "$ans" in
    2|en|EN|english|English) UILANG="en"; lang_en ;;
    *)                       UILANG="de"; lang_de ;;
  esac
}

# ====================================================== Altlasten aufräumen
cleanup_old() {
  local touched=0
  if systemctl list-units --all 2>/dev/null | grep -q 'wg-quick@wg0'; then
    warn "${M[old_wg]}"
    systemctl disable --now wg-quick@wg0 >/dev/null 2>&1 || true
    touched=1
  fi
  if [[ -f /etc/nftables.conf ]] && grep -q 'wg-setup.sh' /etc/nftables.conf 2>/dev/null; then
    warn "${M[old_nft]}"
    if [[ -f /etc/nftables.conf.wg-setup-backup ]]; then
      mv /etc/nftables.conf.wg-setup-backup /etc/nftables.conf
    else
      rm -f /etc/nftables.conf
      systemctl disable --now nftables >/dev/null 2>&1 || true
    fi
    nft flush ruleset 2>/dev/null || true
    touched=1
  fi
  if [[ -f /etc/wireguard/wg-setup.env ]]; then
    mkdir -p /root/wg-setup-alt
    mv /etc/wireguard/* /root/wg-setup-alt/ 2>/dev/null || true
    info "${M[old_files]}"
    touched=1
  fi
  if [[ $touched -eq 1 ]] && command -v docker >/dev/null 2>&1; then
    systemctl restart docker >/dev/null 2>&1 || true
  fi

  # Regelwerk kann auch ohne Datei noch im Speicher aktiv sein.
  # Nur die INPUT-Kette ist hier kritisch - Dockers FORWARD-Drop ist normal und gewollt.
  if nft list ruleset 2>/dev/null | grep -qE 'hook input.*policy drop'; then
    echo
    warn "${M[nft_active]}"
    nft list ruleset 2>/dev/null | grep -E 'hook input.*policy drop' | sed 's/^/    /' || true
    echo
    if ask_yes "${M[q_flush]}" no; then
      nft flush ruleset 2>/dev/null || true
      if command -v docker >/dev/null 2>&1; then
        systemctl restart docker >/dev/null 2>&1 || true
      fi
    fi
  fi
  return 0
}

http_code() {
  curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$1" 2>/dev/null || echo "000"
}

check_local() {                   # check_local <port> ; 0 = antwortet
  local code="$1"
  [[ "$code" =~ ^(200|301|302|303|307|308|401|403)$ ]]
}

install_docker() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    info "${M[dock_ok]}"; return 0
  fi
  info "${M[dock_inst]}"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq curl ca-certificates >/dev/null
  # Skript erst laden, dann ausfuehren - so wird ein abgebrochener Download
  # nicht halb ausgefuehrt (statt Pipe direkt in die Shell).
  local get_docker; get_docker="$(mktemp)"
  if ! curl -fsSL https://get.docker.com -o "$get_docker"; then
    rm -f "$get_docker"; die "${M[docker_dl]}"
  fi
  sh "$get_docker"
  rm -f "$get_docker"
  systemctl enable --now docker >/dev/null 2>&1 || true
  docker compose version >/dev/null 2>&1 || die "${M[dock_miss]}"
}

detect_ip() {
  local ext local_ip
  ext="$(curl -4 -s --max-time 8 https://api.ipify.org 2>/dev/null || true)"
  local_ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')"
  if [[ -n "$ext" && -n "$local_ip" && "$ext" != "$local_ip" ]]; then
    warn "$(printf "${M[nat1]}" "$local_ip" "$ext")"
    warn "${M[nat2]}"
  fi
  echo "${ext:-$local_ip}"
}

# ================================================================ Assistent
wizard() {
  local ui_mode="" domain="" le_email="" host="" wg_port="" ui_port=""
  local admin_user="" admin_pw="" dns="" ui_bind="127.0.0.1"
  local site="" v4cidr="" v6cidr=""

  line
  echo "${B} ${M[title]}${N}"
  line
  echo
  echo " ${M[intro1]}"
  echo " ${M[intro2]}"
  echo
  line
  echo "${B} ${M[s1]}${N}"
  echo

  ui_mode="$(choose "${M[q_ui]}" "${M[ui1]}" "${M[ui2]}" "${M[ui3]}")"

  case "$ui_mode" in
    1) echo
       domain="$(ask "${M[q_domain]}" "$(envget DOMAIN)")"
       [[ -n "$domain" ]] || die "${M[e_domain]}"
       valid_domain "$domain" || die "${M[e_domain_fmt]}"
       le_email="$(ask "${M[q_email]}" "$(envget LE_EMAIL)")"
       [[ -z "$le_email" ]] || valid_email "$le_email" || die "${M[e_email_fmt]}" ;;
    2) ui_bind="0.0.0.0"; echo
       warn "${M[w_http]}"
       ask_yes "${M[q_http]}" no || { echo; wizard; return; } ;;
    3) ui_bind="127.0.0.1" ;;
  esac

  echo; line
  echo "${B} ${M[s2]}${N}"
  echo
  echo "  ${M[detecting]}"
  local detected; detected="$(detect_ip)"
  [[ -n "$domain" ]] && detected="$domain"
  host="$(ask "${M[q_host]}" "${detected:-$(envget INIT_HOST)}")"
  [[ -n "$host" ]] || die "${M[e_host]}"

  local def_port; def_port="$(envget WG_PORT)"
  wg_port="$(ask "${M[q_wgport]}" "${def_port:-51820}")"
  [[ "$wg_port" =~ ^[0-9]+$ ]] || die "${M[e_port]}"

  # Tunnelnetz - pro Standort eindeutig, sonst ueberschneiden sich die Routen
  local def_site; def_site="$(envget SITE_NO)"
  while true; do
    site="$(ask "${M[q_site]}" "${def_site:-1}")"
    [[ "$site" =~ ^[0-9]+$ ]] && (( site >= 1 && site <= 99 )) && break
    echo "  ${M[e_port]}"
  done
  v4cidr="10.8.${site}.0/24"
  v6cidr="fd08:0:${site}::/64"
  printf "  ${M[site_nets]}\n" "$v4cidr" "$v6cidr"
  if ask_yes "${M[q_customnet]}" no; then
    v4cidr="$(ask "${M[q_v4cidr]}" "$v4cidr")"
    [[ "$v4cidr" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$ ]] || die "${M[e_cidr]}"
    v6cidr="$(ask "${M[q_v6cidr]}" "$v6cidr")"
    [[ "$v6cidr" =~ ^[0-9a-fA-F:]+/[0-9]{1,3}$ ]] || die "${M[e_cidr]}"
  fi

  # Ohne aktives IPv6 auf dem Host wuerde der Container beim Start scheitern -
  # dann ganz ohne IPv6 einrichten.
  if [[ -n "$v6cidr" ]] && ! ipv6_available; then
    warn "${M[no_ipv6]}"
    v6cidr=""
  fi

  ui_port="51821"
  if [[ -z "$domain" ]]; then
    if [[ "$ui_bind" == "0.0.0.0" ]]; then
      ui_port="$(ask "${M[q_uiport]}" "51821")"
    else
      ui_port="$(ask "${M[q_uiport_l]}" "51821")"
    fi
    [[ "$ui_port" =~ ^[0-9]+$ ]] || die "${M[e_port]}"
  fi

  echo; line
  echo "${B} ${M[s3]}${N}"
  echo
  local def_user; def_user="$(envget INIT_USERNAME)"
  admin_user="$(ask "${M[q_user]}" "${def_user:-admin}")"
  [[ -n "$admin_user" ]] || admin_user="admin"

  if ask_yes "${M[q_genpw]}" yes; then admin_pw="$(gen_pw)"; else admin_pw="$(ask_secret)"; fi

  local def_dns dns_sel
  def_dns="$(envget INIT_DNS)"
  dns_sel="$(choose "${M[q_dns]}" \
    "Cloudflare (1.1.1.1, 1.0.0.1)" \
    "Quad9 (9.9.9.9, 149.112.112.112)" \
    "Google (8.8.8.8, 8.8.4.4)" \
    "AdGuard (94.140.14.14, 94.140.15.15)" \
    "${M[dns_custom]}")"
  case "$dns_sel" in
    1) dns="1.1.1.1,1.0.0.1" ;;
    2) dns="9.9.9.9,149.112.112.112" ;;
    3) dns="8.8.8.8,8.8.4.4" ;;
    4) dns="94.140.14.14,94.140.15.15" ;;
    5) while true; do
         dns="$(ask "${M[q_dns]}" "${def_dns:-1.1.1.1,1.0.0.1}")"
         valid_dns "$dns" && break
         echo "  ${M[e_dns_fmt]}"
       done ;;
  esac

  echo; line
  echo "${B} ${M[summary]}${N}"
  line
  case "$ui_mode" in
    1) printf "  %s: https://%s (%s)\n" "${M[l_ui]}" "$domain" "${M[caddy_cert]}" ;;
    2) printf "  %s: http://%s:%s  ${Y}%s${N}\n" "${M[l_ui]}" "$host" "$ui_port" "${M[unenc]}" ;;
    3) printf "  %s: ${M[localonly]}\n" "${M[l_ui]}" "$ui_port" ;;
  esac
  printf "  %s: %s\n" "${M[l_client]}" "$host:$wg_port/udp"
  printf "  %s: %s\n" "${M[l_user]}" "$admin_user"
  printf "  %s: %s\n" "${M[l_dns]}" "$dns"
  printf "  %s: %s + %s\n" "${M[l_net]}" "$v4cidr" "${v6cidr:-${M[ipv6_off]}}"
  echo
  local ports="UDP ${wg_port}"
  case "$ui_mode" in
    1) ports="${ports}, TCP 80, TCP 443" ;;
    2) ports="${ports}, TCP ${ui_port}" ;;
  esac
  echo "  ${M[open_ports]} ${ports}"
  echo; line
  ask_yes "${M[q_apply]}" yes || { info "${M[aborted]}"; exit 0; }

  apply "$ui_mode" "$domain" "$le_email" "$host" "$wg_port" "$ui_port" \
        "$admin_user" "$admin_pw" "$dns" "$ui_bind" "$v4cidr" "$v6cidr" "$site"
}

# ================================================================ Ausführen
apply() {
  local ui_mode="$1" domain="$2" le_email="$3" host="$4" wg_port="$5" ui_port="$6"
  local admin_user="$7" admin_pw="$8" dns="$9" ui_bind="${10}"
  local v4cidr="${11}" v6cidr="${12}" site="${13}"
  local old_v4; old_v4="$(envget INIT_IPV4_CIDR)"

  echo
  cleanup_old
  install_docker

  info "$(printf "${M[writing]}" "$DIR")"
  install -d -m 700 "$DIR"

  local ui_publish="      - \"\${UI_BIND}:\${UI_PORT}:51821/tcp\""
  local insecure="true" caddy_service="" caddy_volumes=""

  # IPv6-Bausteine nur einbauen, wenn ein IPv6-Tunnelnetz gesetzt ist. Auf Hosts
  # ohne aktives IPv6 wuerde der Container sonst nicht starten.
  local net_ipv6_enable="    enable_ipv6: true"
  local net_ipv6_subnet="        - subnet: fdcc:ad94:bacf:61a3::/64"
  local svc_ipv6_addr="        ipv6_address: fdcc:ad94:bacf:61a3::2a"
  local ipv6_sysctls="      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv6.conf.all.forwarding=1
      - net.ipv6.conf.default.forwarding=1"
  if [[ -z "$v6cidr" ]]; then
    net_ipv6_enable=""; net_ipv6_subnet=""; svc_ipv6_addr=""; ipv6_sysctls=""
  fi

  if [[ -n "$domain" ]]; then
    ui_publish=""
    insecure="false"
    caddy_volumes="  caddy_data:
  caddy_config:"
    caddy_service="
  caddy:
    image: caddy:2-alpine
    container_name: wg-easy-caddy
    restart: unless-stopped
    ports:
      - \"80:80/tcp\"
      - \"443:443/tcp\"
      - \"443:443/udp\"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - wg
    depends_on:
      - wg-easy"
    {
      [[ -n "$le_email" ]] && printf '{\n  email %s\n}\n\n' "$le_email"
      printf '%s {\n  reverse_proxy wg-easy:51821\n  encode gzip\n}\n' "$domain"
    } > "${DIR}/Caddyfile"
    chmod 644 "${DIR}/Caddyfile"
  else
    rm -f "${DIR}/Caddyfile"
  fi

  cat > "${DIR}/docker-compose.yml" <<COMPOSE
# Generated by wg-easy-setup.sh - template: github.com/wg-easy/wg-easy
volumes:
  etc_wireguard:
${caddy_volumes}

services:
  wg-easy:
    image: ${IMAGE}
    container_name: wg-easy
    environment:
      - INSECURE=${insecure}
      - INIT_ENABLED=true
      - INIT_USERNAME=\${INIT_USERNAME}
      - INIT_PASSWORD=\${INIT_PASSWORD}
      - INIT_HOST=\${INIT_HOST}
      - INIT_PORT=\${INIT_PORT}
      - INIT_DNS=\${INIT_DNS}
      - INIT_IPV4_CIDR=\${INIT_IPV4_CIDR}
      - INIT_IPV6_CIDR=\${INIT_IPV6_CIDR}
    networks:
      wg:
        ipv4_address: 10.42.42.42
${svc_ipv6_addr}
    volumes:
      - etc_wireguard:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    ports:
      - "\${WG_PORT}:\${WG_PORT}/udp"
${ui_publish}
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
${ipv6_sysctls}
${caddy_service}

networks:
  wg:
    driver: bridge
${net_ipv6_enable}
    ipam:
      driver: default
      config:
        - subnet: 10.42.42.0/24
${net_ipv6_subnet}
COMPOSE

  umask 077
  {
    echo "INIT_USERNAME=$(esc_env "$admin_user")"
    echo "INIT_PASSWORD=$(esc_env "$admin_pw")"
    echo "INIT_HOST=$(esc_env "$host")"
    echo "INIT_PORT=$(esc_env "$wg_port")"
    echo "INIT_DNS=$(esc_env "$dns")"
    echo "INIT_IPV4_CIDR=$(esc_env "$v4cidr")"
    echo "INIT_IPV6_CIDR=$(esc_env "$v6cidr")"
    echo "SITE_NO=$(esc_env "$site")"
    echo "WG_PORT=$(esc_env "$wg_port")"
    echo "UI_PORT=$(esc_env "$ui_port")"
    echo "UI_BIND=$(esc_env "$ui_bind")"
    echo "DOMAIN=$(esc_env "$domain")"
    echo "LE_EMAIL=$(esc_env "$le_email")"
    echo "UI_LANG=$(esc_env "$UILANG")"
  } > "${DIR}/.env"
  chmod 600 "${DIR}/.env"

  info "${M[starting]}"

  # INIT_* wirkt nur beim ersten Start. Existiert schon eine Datenbank,
  # wuerden geaenderte Tunnelnetze stillschweigend ignoriert.
  if [[ -n "$old_v4" && "$old_v4" != "$v4cidr" ]] || \
     { [[ -z "$old_v4" ]] && docker volume ls --format '{{.Name}}' 2>/dev/null | grep -q 'etc_wireguard'; }; then
    echo
    warn "${M[cidr_warn1]}"
    echo "  ${M[cidr_warn2]}"
    echo
    if ask_yes "${M[q_reset]}" no; then
      ( cd "$DIR" && docker compose down -v ) >/dev/null 2>&1 || true
      info "${M[reset_done]}"
    fi
  fi

  if ! ( cd "$DIR" && docker compose pull -q && docker compose up -d ); then
    ( cd "$DIR" && docker compose logs --tail 40 ) || true
    die "${M[compose_fail]}"
  fi

  # Auf langsamen Hostern braucht der erste Start etwas - bis ~30s auf 'running' warten.
  local state="" i
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    state="$(docker inspect -f '{{.State.Status}}' wg-easy 2>/dev/null || echo '?')"
    [[ "$state" == "running" ]] && break
    sleep 2
  done
  if [[ "$state" != "running" ]]; then
    warn "$(printf "${M[not_running]}" "$state")"
    ( cd "$DIR" && docker compose logs --tail 40 ) || true
    die "${M[start_fail]}"
  fi

  local url="http://127.0.0.1:${ui_port}"
  [[ "$ui_bind" == "0.0.0.0" ]] && url="http://${host}:${ui_port}"
  [[ -n "$domain" ]] && url="https://${domain}"

  echo; line
  echo "${B}${G} ${M[done]}${N}"
  line
  printf "  %s: %s\n" "${M[l_ui]}"     "$url"
  printf "  %s: %s\n" "${M[l_user]}"   "$admin_user"
  printf "  %s: %s\n" "${M[l_pw]}"     "$admin_pw"
  printf "  %s: %s:%s/udp\n" "${M[l_client]}" "$host" "$wg_port"
  printf "  %s: %s\n" "${M[l_files]}"  "$DIR"
  echo
  if [[ -n "$domain" ]]; then
    printf "  ${M[caddy1]}\n" "$domain"
    echo "  ${M[caddy2]}"
  elif [[ "$ui_bind" == "127.0.0.1" ]]; then
    echo "  ${M[ssh1]}"
    echo "    ssh -L ${ui_port}:127.0.0.1:${ui_port} root@${host}"
    printf "  ${M[ssh2]}\n" "$ui_port"
  fi
  echo
  echo "  ${M[rerun1]}"
  echo "    ./wg-easy-setup.sh"
  line

  # Prüfen, ob die Oberfläche lokal überhaupt antwortet
  local turl tcode
  if [[ -n "$domain" ]]; then turl="http://127.0.0.1:80"; else turl="http://127.0.0.1:${ui_port}"; fi
  tcode="$(http_code "$turl")"
  echo
  if check_local "$tcode"; then
    info "$(printf "${M[d_local_ok]}" "$tcode")"
    echo "  ${M[d_outside]}"
  else
    warn "$(printf "${M[d_local_fail]}" "$tcode")"
  fi
}

diagnose() {
  local uiport dom code url ext
  uiport="$(envget UI_PORT)"; dom="$(envget DOMAIN)"

  echo; line
  echo "${B} ${M[d_title]}${N}"
  line
  echo
  ( cd "$DIR" && docker compose ps ) || true

  echo
  echo "  ${M[d_ports]}:"
  docker port wg-easy 2>/dev/null | sed 's/^/    /' || true
  docker port wg-easy-caddy 2>/dev/null | sed 's/^/    /' || true

  echo
  echo "  ${M[d_ips]}:"
  ip -4 -brief addr show scope global 2>/dev/null | sed 's/^/    /' || true
  ext="$(curl -4 -s --max-time 6 https://api.ipify.org 2>/dev/null || true)"
  [[ -n "$ext" ]] && echo "    ${M[d_ext]}: ${ext}"

  echo
  if [[ -n "$dom" ]]; then url="http://127.0.0.1:80"; else url="http://127.0.0.1:${uiport}"; fi
  code="$(http_code "$url")"
  if check_local "$code"; then
    info "$(printf "${M[d_local_ok]}" "$code")"
    echo "  ${M[d_outside]}"
    if [[ -z "$dom" ]]; then
      echo
      echo "  ${M[d_hint]}"
      echo "    ssh -L ${uiport}:127.0.0.1:${uiport} root@$(envget INIT_HOST)"
    fi
  else
    warn "$(printf "${M[d_local_fail]}" "$code")"
  fi

  if nft list ruleset 2>/dev/null | grep -qE 'hook input.*policy drop'; then
    echo
    warn "${M[d_nftdrop]}"
    nft list ruleset 2>/dev/null | grep -E 'hook input.*policy drop' | sed 's/^/    /' || true
  fi

  # Caddy meldet blockierte ACME-Challenges - eindeutiger Beweis für Filterung davor
  if ( cd "$DIR" && docker compose logs --tail 200 2>/dev/null ) | grep -q 'likely firewall problem'; then
    echo
    warn "${M[d_acme1]}"
    echo "  ${M[d_acme2]}"
  fi

  echo
  echo "  ${M[d_logs]}:"
  ( cd "$DIR" && docker compose logs --tail 30 ) || true
  line
}

# ==================================================================== Menü
menu() {
  while true; do
    echo; line
    echo "${B} ${M[menu]}${N}"
    line
    local state
    state="$(docker inspect -f '{{.State.Status}}' wg-easy 2>/dev/null || echo "${M[absent]}")"
    echo "  ${M[m_state]}: ${state}   ${M[m_host]}: $(envget INIT_HOST)   ${M[m_port]}: $(envget WG_PORT)/udp"
    echo
    local sel
    sel="$(choose "${M[q_menu]}" "${M[m1]}" "${M[m2]}" "${M[m3]}" "${M[m4]}" \
                  "${M[m5]}" "${M[m6]}" "${M[m7]}" "${M[m8]}" "${M[m9]}")"
    case "$sel" in
      1) echo; ( cd "$DIR" && docker compose ps )
         echo; ss -lntup 2>/dev/null | grep -E "$(envget WG_PORT)|$(envget UI_PORT)|:80 |:443 " \
              || echo "  ${M[no_ports]}" ;;
      2) echo; ( cd "$DIR" && docker compose logs --tail 60 ) ;;
      3) ( cd "$DIR" && docker compose restart ) && info "${M[restarted]}" ;;
      4) info "${M[updating]}"; ( cd "$DIR" && docker compose pull && docker compose up -d ) \
           && info "${M[updated]}" ;;
      5) echo; wizard; return ;;
      6) echo
         local d; d="$(envget DOMAIN)"
         printf "  %s: %s\n" "${M[l_ui]}" \
           "$( [[ -n "$d" ]] && echo "https://${d}" || echo "http://$(envget INIT_HOST):$(envget UI_PORT)" )"
         printf "  %s: %s\n" "${M[l_user]}" "$(envget INIT_USERNAME)"
         printf "  %s: %s\n" "${M[l_pw]}"   "$(envget INIT_PASSWORD)" ;;
      7) diagnose ;;
      8) echo
         local what
         what="$(choose "${M[q_uninst]}" "${M[u1]}" "${M[u2]}" "${M[u3]}")"
         case "$what" in
           1) ( cd "$DIR" && docker compose down ) && info "${M[u_done1]}" ;;
           2) if ask_yes "${M[u_conf]}" no; then
                ( cd "$DIR" && docker compose down -v ) && rm -rf "$DIR" && info "${M[u_done2]}"
                exit 0
              fi ;;
           *) : ;;
         esac ;;
      9) exit 0 ;;
    esac
  done
}

# ==================================================================== Start
lang_de
[[ $EUID -eq 0 ]] || die "${M[need_root]} / Please run as root."
[[ -t 0 ]] || die "${M[need_tty]} / Interactive terminal required."

pick_language

if [[ -f "${DIR}/docker-compose.yml" ]]; then
  menu
else
  wizard
fi