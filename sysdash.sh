#!/usr/bin/env bash
# sysdash.sh — Dashboard simple en terminal para temperatura, CPU, batería y perfil de energía.

set -Eeuo pipefail

INTERVAL="${1:-2}"   # segundos entre refrescos (por defecto 2)

# --- Helpers ---
have() { command -v "$1" >/dev/null 2>&1; }

get_power_profile() {
  if have powerprofilesctl && systemctl is-active --quiet power-profiles-daemon.service; then
    powerprofilesctl get 2>/dev/null || echo "unknown"
  else
    echo "n/a"
  fi
}

get_turbo_state() {
  local p="/sys/devices/system/cpu/intel_pstate/no_turbo"
  if [[ -e "$p" ]]; then
    [[ "$(cat "$p")" == "0" ]] && echo "ENABLED" || echo "DISABLED"
  else
    echo "n/a"
  fi
}

get_ac_state() {
  local path=""
  for d in /sys/class/power_supply/*; do
    [[ -e "$d/type" ]] || continue
    if [[ "$(cat "$d/type")" == "Mains" && -e "$d/online" ]]; then
      path="$d/online"; break
    fi
  done
  if [[ -n "$path" ]]; then
    [[ "$(cat "$path")" == "1" ]] && echo "AC (conectado)" || echo "Batería"
  else
    echo "Desconocido"
  fi
}

get_battery() {
  if have upower; then
    local bat dev
    dev="$(upower -e 2>/dev/null | grep -m1 BAT || true)"
    if [[ -n "$dev" ]]; then
      bat="$(upower -i "$dev" 2>/dev/null)"
      local state pct
      state="$(grep -m1 'state:' <<<"$bat" | awk '{print $2}')"
      pct="$(grep -m1 'percentage:' <<<"$bat" | awk '{print $2}')"
      echo "${pct:-n/a} (${state:-n/a})"
    else
      echo "n/a"
    fi
  else
    echo "n/a"
  fi
}

get_cpu_freq() {
  # promedio simple de frecuencias reportadas por scaling_cur_freq (kHz)
  local total=0 count=0 f
  for f in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq; do
    [[ -e "$f" ]] || continue
    total=$((total + $(cat "$f")))
    count=$((count + 1))
  done
  if (( count > 0 )); then
    # a GHz con 2 decimales
    awk -v t="$total" -v c="$count" 'BEGIN{printf "%.2f GHz", (t/c)/1000000}'
  else
    echo "n/a"
  fi
}

# CPU usage con /proc/stat (diferencial entre iteraciones)
read_cpu_jiffies() {
  # shellcheck disable=SC2207
  local a=($(grep -m1 '^cpu ' /proc/stat))
  # a[1]=user a[2]=nice a[3]=system a[4]=idle a[5]=iowait a[6]=irq a[7]=softirq a[8]=steal
  local idle=$(( ${a[4]} + ${a[5]} ))
  local nonidle=$(( ${a[1]} + ${a[2]} + ${a[3]} + ${a[6]} + ${a[7]} + ${a[8]} ))
  local total=$(( idle + nonidle ))
  echo "$idle $total"
}

calc_cpu_usage() {
  local idle1 total1 idle2 total2
  read -r idle1 total1 <<<"$(read_cpu_jiffies)"
  sleep 0.5
  read -r idle2 total2 <<<"$(read_cpu_jiffies)"
  local didle=$(( idle2 - idle1 ))
  local dtotal=$(( total2 - total1 ))
  local usage
  if (( dtotal > 0 )); then
    usage=$(awk -v dI="$didle" -v dT="$dtotal" 'BEGIN{printf "%.1f", (1 - dI/dT)*100}')
  else
    usage="0.0"
  fi
  echo "${usage}%"
}

get_max_temp() {
  # Toma el máximo de thermal_zone*/temp (milicelsius)
  local t max=-100000
  for z in /sys/class/thermal/thermal_zone*/temp; do
    [[ -e "$z" ]] || continue
    t=$(cat "$z" 2>/dev/null || echo 0)
    (( t > max )) && max=$t
  done
  if (( max > -100000 )); then
    awk -v m="$max" 'BEGIN{printf "%.1f °C", m/1000}'
  else
    echo "n/a"
  fi
}

get_fans() {
  if have sensors; then
    sensors 2>/dev/null | grep -i 'fan' | head -n 3 | sed 's/^[[:space:]]*//'
  else
    echo "n/a"
  fi
}

top_cpu_processes() {
  # top 5 por %CPU (excluyendo cabeceras)
  ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==1{next} {printf "%-6s %-20s %5.1f%%\n", $1, $2, $3} NR>=6{exit}'
}

draw() {
  clear
  local now profile turbo ac batt cpuu freq tmax
  now="$(date '+%Y-%m-%d %H:%M:%S')"
  profile="$(get_power_profile)"
  turbo="$(get_turbo_state)"
  ac="$(get_ac_state)"
  batt="$(get_battery)"
  cpuu="$(calc_cpu_usage)"
  freq="$(get_cpu_freq)"
  tmax="$(get_max_temp)"

  echo "==============================================================="
  echo " SYS DASH | ${now}"
  echo "==============================================================="
  printf " Perfil energía : %s\n" "$profile"
  printf " Turbo Boost    : %s\n" "$turbo"
  printf " Alimentación   : %s | Batería: %s\n" "$ac" "$batt"
  printf " CPU uso        : %s | Frecuencia: %s | Temp máx: %s\n" "$cpuu" "$freq" "$tmax"
  echo "---------------------------------------------------------------"
  echo " Ventiladores (sensors):"
  get_fans
  echo "---------------------------------------------------------------"
  echo " Top procesos por CPU:"
  top_cpu_processes
  echo "==============================================================="
  printf " Refresco cada %ss — Sal con CTRL+C\n" "$INTERVAL"
}

# bucle principal
trap 'tput cnorm; exit 0' INT TERM
tput civis
while true; do
  draw
  sleep "$INTERVAL"
done
