#!/bin/bash

# URL der FritzBox
URL="$FRITZ/igdupnp/control/WANIPConn1"

# SOAP-Request
SOAP_REQUEST='<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:X_AVM_DE_GetIPv6Prefix xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1"></u:X_AVM_DE_GetIPv6Prefix>
  </s:Body>
</s:Envelope>'

# curl-Aufruf ausführen und Antwort speichern
RESPONSE=$(curl -s -k -u "$USERNAME:$PASSWORD" "$URL" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: urn:schemas-upnp-org:service:WANIPConnection:1#X_AVM_DE_GetIPv6Prefix" \
  -d "$SOAP_REQUEST")

# Den NewIPv6Prefix aus der XML-Antwort extrahieren
NEW_IPV6_PREFIX=$(echo "$RESPONSE" | grep -oP '(?<=<NewIPv6Prefix>)[^<]+')

# Ergebnis ausgeben
echo $NEW_IPV6_PREFIX
