# Rouge process monitor 
A rouge process monitor for MacOS. Checks whether process has been running at 80% for 10 secoonds consistetly. 
Tested minimally on `GNU bash, version 3.2.57(1)-release (arm64-apple-darwin23)` MacOS `14.5 (23F79)`.

### To run at launch: 
Create a file named com.user.cpu_monitor.plist in ~/Library/LaunchAgents/.
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.cpu_monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/monitor_cpu.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```
then execute
`launchctl load ~/Library/LaunchAgents/com.user.cpu_monitor.plist`