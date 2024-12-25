if pgrep -x "6tunnel" > /dev/null && [ "$NEW_IPV6" == "$OLD_IPV6" ]; then
    echo "6tunnel läuft bereits."
else
    echo "6tunnel wird neu gestartet."
    killall 6tunnel
    6tunnel -6 -l $NEW_IP 25565 192.168.178.58 25565
    6tunnel -6 -l $NEW_IP 25564 192.168.178.58 25564
    6tunnel -6 -l $NEW_IP 25563 192.168.178.58 25563
    6tunnel -6 -l $NEW_IP 25561 192.168.178.58 25561
fi
