#!/bin/bash

source env.sh

# Neue IPv6-Adresse
NEW_IP=$(./calc-ipv6 "$(./get-prefix.sh)" "$SUFFIX")
NEW_IPV6="$NEW_IP"/56

# Alte IPv6-Adresse abfragen
OLD_IPV6=$(ip -6 addr show dev "$INTERFACE" | grep -oP 'inet6 \K[^\s]+' | head -n 1)

# Prüfen, ob eine IPv6-Adresse gefunden wurde
if [ -z "$OLD_IPV6" ]; then
    echo "Keine IPv6-Adresse gefunden auf $INTERFACE"
    exit 1
fi

# Überen, ob sich die IPv6-Adresse geändert hat
if [ "$NEW_IPV6" == "$OLD_IPV6" ]; then
    echo "Die IPv6-Adresse hat sich nicht geändert."

    bash post-hook.sh

    exit 0
fi

# Alte IPv6-Adresse entfernen
echo "Entferne alte IPv6-Adresse: $OLD_IPV6"
ip -6 addr del "$OLD_IPV6" dev "$INTERFACE"

# Neue IPv6-Adresse zuweisen
echo "Weise neue IPv6-Adresse zu: $NEW_IPV6"
ip -6 addr add "$NEW_IPV6" dev "$INTERFACE"

# Überprüfen, ob die neue IPv6-Adresse gesetzt wurde
ip -6 addr show dev "$INTERFACE"

echo "IPv6-Adresse erfolgreich geändert."

# Abfrage der DNS-Record-ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?name=$DNS_NAME" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

# Überprüfen, ob der DNS-Record existiert
if [ "$RECORD_ID" == "null" ]; then
  echo "DNS-Record $DNS_NAME nicht gefunden!"
  exit 1
fi

# DNS-Record aktualisieren
echo "Aktualisiere DNS-Record für $DNS_NAME auf IP $NEW_IP..."

UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"AAAA\",\"name\":\"$DNS_NAME\",\"content\":\"$NEW_IP\",\"ttl\":120,\"proxied\":false}")

# Überprüfen, ob das Update erfolgreich war
if echo "$UPDATE_RESPONSE" | jq -e '.success' > /dev/null; then
  echo "DNS-Record erfolgreich aktualisiert!"
else
  echo "Fehler beim Aktualisieren des DNS-Records!"
  echo "Antwort von Cloudflare: $UPDATE_RESPONSE"
  exit 1
fi

bash post-hook.sh
