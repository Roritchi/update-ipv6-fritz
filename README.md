# Update IPv6 based on fritz.box Prefix

This Script asks your local fritz.box for the currently used IPv6 Prefix, then calculates your new IPv6, based on your previous IP and the new Prefix and then updates your local IP and Cloudflare Record.
This was made for a Proxmox LXC Container which runs in a German Network with rotating IPv6 Prefixes. I have to set a static IP for the Container, because otherwise he will only get a local IP and isn't reachable from the Internet, but he also cant ask for his global IP over the Internet, because no IPv6 Traffic works, while an incorrect static IPv6 is set.

There may still be a bug with the prefix length and the length is currently not configurable.
This will change in the next version, but you can also just change the values in the source code and then recompile.

Main Function:
```bash
# Remove old IPv6-Address
ip -6 addr del "$OLD_IPV6" dev "$INTERFACE"

# Add new IPv6-Address
ip -6 addr add "$NEW_IPV6" dev "$INTERFACE"

UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"AAAA\",\"name\":\"$DNS_NAME\",\"content\":\"$NEW_IP\",\"ttl\":120,\"proxied\":false}")
```
