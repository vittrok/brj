@echo off
net stop "teamviewer 5"
net stop "teamviewer6"
net stop "teamviewer7"
net stop "teamviewer8"
taskkill /f /im teamviewer*
nircmdc closeprocess TeamViewer.exe
nircmdc closeprocess TeamViewer_Service.exe
nircmdc closeprocess tv_w32.exe
nircmdc closeprocess tv_x64.exe
nircmdc regdelval "HKEY_CURRENT_USER\Software\TeamViewer\Version5" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\Software\TeamViewer\Version5" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\Software\Wow6432Node\TeamViewer\Version5" "ClientID"
nircmdc regdelval "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\Software\TeamViewer\Version5.1" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\Software\Wow6432Node\TeamViewer\Version5.1" "ClientID"
nircmdc regdelval "HKEY_CURRENT_USER\Software\TeamViewer\Version6" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\Software\TeamViewer\Version6" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\Software\Wow6432Node\TeamViewer\Version6" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TeamViewer\Version7" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version7" "ClientID"
nircmdc regdelval "HKEY_CURRENT_USER\SOFTWARE\TeamViewer\Version7" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TeamViewer\Version8" "ClientID"
nircmdc regdelval "HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version8" "ClientID"
nircmdc regdelval "HKEY_CURRENT_USER\SOFTWARE\TeamViewer\Version8" "ClientID"
nircmdc setfilefoldertime "%programfiles%" now now
if exist "%ProgramFiles%\TeamViewer\Version8\TeamViewer.exe" nircmdc exec show "%ProgramFiles%\TeamViewer\Version8\TeamViewer.exe"
if exist "%ProgramFiles(x86)%\TeamViewer\Version8\TeamViewer.exe" nircmdc exec show "%ProgramFiles(x86)%\TeamViewer\Version8\TeamViewer.exe"
if exist "%ProgramFiles%\TeamViewer\Version7\TeamViewer.exe" nircmdc exec show "%ProgramFiles%\TeamViewer\Version7\TeamViewer.exe"
if exist "%ProgramFiles(x86)%\TeamViewer\Version7\TeamViewer.exe" nircmdc exec show "%ProgramFiles(x86)%\TeamViewer\Version7\TeamViewer.exe"
if exist "%ProgramFiles%\TeamViewer\Version6\TeamViewer.exe" nircmdc exec show "%ProgramFiles%\TeamViewer\Version6\TeamViewer.exe"
if exist "%ProgramFiles(x86)%\TeamViewer\Version6\TeamViewer.exe" nircmdc exec show  "%ProgramFiles(x86)%\TeamViewer\Version6\TeamViewer.exe"
if exist "%ProgramFiles%\TeamViewer\Version5\TeamViewer.exe" nircmdc exec show "%ProgramFiles%\TeamViewer\Version5\TeamViewer.exe"
if exist "%ProgramFiles(x86)%\TeamViewer\Version5\TeamViewer.exe" nircmdc exec show "%ProgramFiles(x86)%\TeamViewer\Version5\TeamViewer.exe"
nircmdc wait 10000
net start "TeamViewer8"
net start "TeamViewer7"
net start  "teamviewer6"
net start  "teamviewer 5"
