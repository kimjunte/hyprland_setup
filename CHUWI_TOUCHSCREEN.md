# Chuwi Touchscreen & Screen Sharing Setup (Hyprland / Omarchy)

Fixes for the Chuwi laptop: touch input rotation and screen sharing orientation on a rotated DSI-1 display.

---

## 1. Touch Input Fix

### Problem
Display uses `transform = 3` (270°). Without calibration, touch is 90° off and mirrored.
Hyprland's `transform` in the `device {}` block has no effect — fix must be at the libinput/udev level.

### Fix

**Create udev calibration rule:**
```bash
echo 'SUBSYSTEM=="input", ATTRS{name}=="Goodix Capacitive TouchScreen", ENV{LIBINPUT_CALIBRATION_MATRIX}="0 1 0 -1 0 1"' | sudo tee /etc/udev/rules.d/99-touchscreen-calibration.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```
Reboot after applying.

**Map touchscreen to display in `~/.config/hypr/input.conf`:**
```ini
device {
  name = goodix-capacitive-touchscreen
  output = DSI-1
}
```

**Notes:**
- Device name in Hyprland: `goodix-capacitive-touchscreen-1`
- Monitor: `DSI-1` at `1200x1920@50Hz`, `transform = 3`
- Calibration matrix `0 1 0 -1 0 1` = 90° CW rotation + Y-axis flip

---

## 2. Screen Sharing Fix

### Problem
Screen sharing in browsers (Meet, Teams) shows the screen rotated. This is a known upstream bug in
`xdg-desktop-portal-hyprland` — WebRTC ignores `SPA_META_VideoTransform` metadata entirely.
Tracked at: https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/292

### Fix A — Share a Tab (easiest)
In the Meet/Teams share dialog, choose **"Chromium Tab"** instead of "Entire Screen".
Tab capture bypasses the display transform and shows content correctly.

### Fix B — Patched XDPH fork
Build and install a community fork with a "Force software transform" option:

```bash
git clone --recursive https://github.com/fixing-things-enjoyer/xdg-desktop-portal-hyprland -b rotated-display-contingency
cd xdg-desktop-portal-hyprland
cmake -DCMAKE_INSTALL_LIBEXECDIR=/usr/lib -DCMAKE_INSTALL_PREFIX=/usr -B build
cmake --build build
sudo cmake --install build
systemctl --user daemon-reload && systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal
```

Then update `~/.config/hypr/xdph.conf`:
```ini
screencopy {
  custom_picker_binary = hyprland-share-picker
  allow_token_by_default = true
}
```

### Fix for "Out of Buffers" crash
Add `bitdepth, 10` to the monitor line in `~/.config/hypr/monitors.conf`:
```ini
monitor = ,1920x1080@60,auto,1, transform, 3, bitdepth, 10
```
