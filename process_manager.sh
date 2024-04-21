#!/bin/bash


while true; do
    clear
    echo " $(printf '%0.1s' "-"{1..90})";
    echo -n " ";
    echo -n "$(printf '%-10s' PID)";
    echo -n "$(printf '%-10s' USER)";
    echo -n "$(printf '%-20s' COMMAND)";
    echo -n "$(printf '%-15s' CPU)";
    echo -n "$(printf '%-15s' MEMORY)";
    echo -n "$(printf '%-15s' READ)";
    echo -n "$(printf '%-15s' WRITE)";
    echo;
    echo " $(printf '%0.1s' "-"{1..90})";
   

    clock_ticks=$(getconf CLK_TCK)

    for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            pid=$(basename "$pid")
            
            comm=$(awk 'NR==1 {print $1}' "/proc/$pid/comm")
            user=$(ls -l /proc/$pid/comm | awk '{print $4}')
            mem=$(grep -E "VmRSS" /proc/$pid/status | cut -f 2)
            rc=$(sudo grep -E "read_bytes:" /proc/$pid/io | tr -cd '0-9')
            rw=$(sudo grep -E "write_bytes:" /proc/$pid/io | tr -cd '0-9')

            if [ -n "$comm" ]; then
                utime=$(awk '{print $14}' "/proc/$pid/stat")
                stime=$(awk '{print $15}' "/proc/$pid/stat")
                total_time=$((utime + stime))
                uptime=$(awk '{print $1}' "/proc/uptime")
                starttime=$(awk '{print $22}' "/proc/$pid/stat")

                cpu_usage=$(echo "scale=2; ($total_time / $clock_ticks / ($uptime - ($starttime / $clock_ticks))) * 100" | bc)
               
                printf "%-10s %-10s %-20s %-10s %-15s %-15s %-15s\n" "$pid" "$user" "$comm" "$cpu_usage" "$mem" "$rc" "$rw"
            fi
        fi
    done | sort -k4rn | head -n 15
 
    sleep 10
done
