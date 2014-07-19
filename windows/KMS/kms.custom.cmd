@echo off
cscript //H:cscript
slmgr /skms ololoev.djigurda.ru:1666

:: Windows 8.1 Enterprise MHF9N-XY6XB-WVXMC-BTDCT-MKKG7
slmgr /ipk MHF9N-XY6XB-WVXMC-BTDCT-MKKG7

:: Windows 7 Enterprise
:: slmgr /ipk 33PXH-7Y6KF-2VJC9-XBBR8-HVTHH

slmgr /ato
slmgr /dli
slmgr /dlv
