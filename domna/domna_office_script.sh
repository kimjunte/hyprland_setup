nmcli connection add \
  type wifi \
  ifname wlan0 \
  con-name halkin-clients \
  ssid "Halkin-WiFi Clients" \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap peap \
  802-1x.phase2-auth mschapv2 \
  802-1x.identity "Domna" \
  802-1x.password "Digger5Edge4Attic" \
  connection.autoconnect yes
