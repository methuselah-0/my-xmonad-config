#!/run/current-system/profile/bin/bash
setTemp(){
    if [[ -f /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp2_input ]] ; then
        temp1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp2_input)"
    elif [[ -f /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp2_input ]] ; then
        temp1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp2_input)"
    elif [[ -f /sys/devices/platform/coretemp.0/hwmon/hwmon0/temp1_input ]] ; then
        temp1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon0/temp1_input)"
    fi
    segmentTemp="Temp: $(expr "$temp1" / 1000)C"
    # cat /proc/acpi/ibm/thermal | cut -d ' ' -f 2
}
setNet() {
    helperNet
    #local iconUp="$preIcon$postIcon"
    #local iconDown="$preIcon$postIcon"
    local iconUp="Up:"
    local iconDown="Down:"
    segmentNet="$labelColor $iconUp $valueColor$TX_text $iconDown $valueColor$RX_text"
}
setBattery(){
    local percent=$(bc <<<"scale=2; $(cat /sys/class/power_supply/BAT0/energy_now)/$(cat /sys/class/power_supply/BAT0/energy_full)")
    segmentBattery="Battery: ${percent#.}%"
}
helperNet() {
    local interface=$(iw dev | grep Interface | awk '{print $2}')

    if [ "$interface" ]; then

        # Read first datapoint
        read TX_prev < /sys/class/net/$interface/statistics/tx_bytes
        read RX_prev < /sys/class/net/$interface/statistics/rx_bytes

        sleep 1

        # Read second datapoint

        read TX_curr < /sys/class/net/$interface/statistics/tx_bytes
        read RX_curr < /sys/class/net/$interface/statistics/rx_bytes

        # compute
        local TX_diff=$((TX_curr-TX_prev))
        local RX_diff=$((RX_curr-RX_prev))

        # printout var
        TX_text="$(echo "scale=1; $TX_diff/1024" | bc | awk '{printf "%.1f", $0}')kb/s"
        RX_text="$(echo "scale=1; $RX_diff/1024" | bc | awk '{printf "%.1f", $0}')kb/s"
    fi;
}
setCPU() {
    local icon="$preIcon$icon$postIcon"

    helperCPU
    local value=$cpu_util

    segmentCPU="$icon $labelColor CPU: $valueColor${value}%"
}
helperCPU() {
    # Read /proc/stat file (for first datapoint)
    read cpu user nice system idle iowait irq softirq steal guest< /proc/stat

    # compute active and total utilizations
    local cpu_active_prev=$((user+system+nice+softirq+steal))
    local cpu_total_prev=$((user+system+nice+softirq+steal+idle+iowait))

    # echo 'cpu_active_prev = '.cpu_active_prev

    sleep 1

    # Read /proc/stat file (for second datapoint)
    read cpu user nice system idle iowait irq softirq steal guest< /proc/stat

    # compute active and total utilizations
    local cpu_active_cur=$((user+system+nice+softirq+steal))
    local cpu_total_cur=$((user+system+nice+softirq+steal+idle+iowait))

    # compute CPU utilization (%)
    cpu_util=$((100*( cpu_active_cur-cpu_active_prev ) / (cpu_total_cur-cpu_total_prev) ))
}
