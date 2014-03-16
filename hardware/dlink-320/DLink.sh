#Сводный скрипт. Можно поменять необходимы параметры и вставить в CLI DLink'а

# задание типа используемого модема
type_router='GPRS'
#type_router='CDMA'

#case $type_router in
#CDMA)
#echo "CDMA-mode" >> /usr/tmp/syslog.log
# тип модема, может принимать значения или gprs или  cdma - этот параметр зависит от того, какой у вас модем и стандарт сети
#nvram set modem=cdma

#---------------------------------------------------------
# параметры, определяемые оператором
#
# точка доступа оператора для gprs-модемов, для SkyLink не используется 
nvram set apn=internet
# имя пользователя для подключения 
nvram set username=
# пароль для подключения 
nvram set password=
# номер набора
nvram set dialnumber=*99***1#

#---------------------------------------------------------
# параметры, определяемые модемом (в линуксе можно получить командой lsusb)
# 
# Vendor ID модема 
nvram set vend=0x19d2
# Product ID модема
nvram set prod=0x0031
# номер порта модема. Опытным путём
nvram set port=2

#---------------------------------------------------------
# параметры, определяемые типом используемого модема (как правило, не нужны)
# 
# дополнительная строка инициализации 
#nvram set atinit=ATZ
#;;
#GPRS)
#echo "GPRS-mode" >> /usr/tmp/syslog.log
# тип модема, может принимать значения или gprs или  cdma - этот параметр зависит от того, какой у вас модем и стандарт сети
nvram set modem=gprs
#---------------------------------------------------------
# общиме параметры 
#
# номер порта модема. Максимальная 921600
nvram set portspeed=921600
# рамер пакета MTU. Обычно равен 1492;
nvram set mtu=1492
# рамер пакета MRU. Обычно равен 1492;
nvram set mru=1492
# адрес узла для тестирования наличия связи (я это не использую)
#nvram set pingsite=8.8.8.8

#######################################################################################################
# синтезируем скрипт modem.sh
#    отвечает за подключение модема
#######################################################################################################


echo 'kill -9 $(ps|grep pppd|awk -F'"' ' '"'{print $1}'"'"') 2>/dev/null' >> /usr/local/sbin/modem.sh
echo 'mkdir /tmp/ppp/' >> /usr/local/sbin/modem.sh
echo 'mkdir /tmp/ppp/peers/' >> /usr/local/sbin/modem.sh
echo 'apn=$(nvram get apn)' >> /usr/local/sbin/modem.sh
echo 'dialnumber=$(nvram get dialnumber)' >> /usr/local/sbin/modem.sh
echo 'modem=$(nvram get modem)' >> /usr/local/sbin/modem.sh
echo 'username=$(nvram get username)' >> /usr/local/sbin/modem.sh
echo 'port=$(nvram get port)' >> /usr/local/sbin/modem.sh
echo 'portspeed=$(nvram get portspeed)' >> /usr/local/sbin/modem.sh
echo 'password=$(nvram get password)' >> /usr/local/sbin/modem.sh
echo 'vend=$(nvram get vend)' >> /usr/local/sbin/modem.sh
echo 'prod=$(nvram get prod)' >> /usr/local/sbin/modem.sh
echo 'mtu=$(nvram get mtu)' >> /usr/local/sbin/modem.sh
echo 'mru=$(nvram get mru)' >> /usr/local/sbin/modem.sh
echo 'atinit=$(nvram get atinit)' >> /usr/local/sbin/modem.sh
echo 'if [ "$vend" == "" -o "$prod" == "" ]; then' >> /usr/local/sbin/modem.sh
echo ' insmod acm' >> /usr/local/sbin/modem.sh
echo ' insmod usbserial' >> /usr/local/sbin/modem.sh
echo ' insmod option' >> /usr/local/sbin/modem.sh
echo ' insmod pl2303' >> /usr/local/sbin/modem.sh
echo ' insmod ftdi_sio' >> /usr/local/sbin/modem.sh
echo 'else' >> /usr/local/sbin/modem.sh
echo ' insmod usbserial vendor=$vend product=$prod maxSize=4096' >> /usr/local/sbin/modem.sh
echo 'fi' >> /usr/local/sbin/modem.sh
echo 'sleep 15' >> /usr/local/sbin/modem.sh
echo 'usbdev=$(cat /proc/bus/usb/devpath | grep -o "/.*" | awk -F '"'m' '"'{print $1}'"'"')' >> /usr/local/sbin/modem.sh
echo 'echo "'"'' ''"'" > /tmp/ppp/peers/cdma.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'' 'ATZ'"'" >> /tmp/ppp/peers/cdma.chat' >> /usr/local/sbin/modem.sh
echo 'echo "$atinit" >> /tmp/ppp/peers/cdma.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'OK' 'ATD #777'"'" >> /tmp/ppp/peers/cdma.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'CONNECT' ''"'" >> /tmp/ppp/peers/cdma.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'' ''"'" > /tmp/ppp/peers/gprs.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'' 'ATZ'"'" >> /tmp/ppp/peers/gprs.chat' >> /usr/local/sbin/modem.sh
echo 'echo "$atinit" >> /tmp/ppp/peers/cdma.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'' '"'AT+CGDCONT=1,\"IP\",\"$apn\"'"'"'" >> /tmp/ppp/peers/gprs.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'OK' '"'ATD$dialnumber'"'"'" >> /tmp/ppp/peers/gprs.chat' >> /usr/local/sbin/modem.sh
echo 'echo "'"'CONNECT' ''"'" >> /tmp/ppp/peers/gprs.chat' >> /usr/local/sbin/modem.sh
echo 'echo "debug" > /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'if [ "$usbdev" == "/dev/usb/ac" ]; then' >> /usr/local/sbin/modem.sh
echo ' echo "/dev/usb/acm/$port" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'else' >> /usr/local/sbin/modem.sh
echo ' echo "/dev/usb/tts/$port" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'fi' >> /usr/local/sbin/modem.sh
echo 'echo "$portspeed" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "crtscts" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "noipdefault" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "ipcp-accept-local" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "lcp-echo-interval 60" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "lcp-echo-failure 6" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "mtu $mtu" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "mru $mru" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "usepeerdns" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "noauth" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "nodetach" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "persist" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "user '"'"'$username'"'"'" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "password '"'"'$password'"'"'" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'echo "connect \"/usr/sbin/chat -s -S -V -t 60 -f /tmp/ppp/peers/$modem.chat 2>/tmp/chat.log\"" >> /tmp/ppp/peers/$modem' >> /usr/local/sbin/modem.sh
echo 'pppd call $modem >> /tmp/chat.log' >> /usr/local/sbin/modem.sh

#Делаем его исполняемым
chmod +x /usr/local/sbin/modem.sh


#######################################################################################################
# синтезируем скрипт post-boot
#    автозапускается после запуска 
#######################################################################################################


echo '#!/bin/sh' > /usr/local/sbin/post-boot
echo '/usr/local/sbin/ledctl status off' >> /usr/local/sbin/post-boot
echo '/usr/local/sbin/ledctl print off' >> /usr/local/sbin/post-boot
echo 'ipcp-accept-remote' >> /usr/local/sbin/post-boot
echo '/usr/local/sbin/test-connect &' >> /usr/local/sbin/post-boot
echo 'sleep 30' >> /usr/local/sbin/post-boot
#Добавляем тот самый роут во внутреннюю сеть
echo 'route add -net 172.16.0.0 netmask 255.255.0.0 gw 172.16.106.1'>> /usr/local/sbin/post-boot
echo 'echo "Running modem.sh" >> /usr/tmp/syslog.log' >> /usr/local/sbin/post-boot
echo '/usr/local/sbin/modem.sh &' >> /usr/local/sbin/post-boot
echo 'sleep 30' >> /usr/local/sbin/post-boot
echo 'q='"'"'status'"'" >> /usr/local/sbin/post-boot
echo 'b='"'"'statusbad'"'" >> /usr/local/sbin/post-boot
echo 'pingsite=$(nvram get pingsite)' >> /usr/local/sbin/post-boot
#Скрипт постоянной проверки связи и ребута железки. Учитывая, что у нас другая схема, делать этого не будем.
#правда теперь нельзя вытащить модем, потому что после того, как его вставишь, он уже не заработает - надо перезагрузить длинк
#echo 'while true; do' >> /usr/local/sbin/post-boot
#echo '   if (! ping -c 3  $pingsite >/dev/null 2>&1) then' >> /usr/local/sbin/post-boot
#echo '      /usr/local/sbin/ledctl status off' >> /usr/local/sbin/post-boot
#echo '      killall -15 pppd' >> /usr/local/sbin/post-boot
#echo '      killall -9 pppd' >> /usr/local/sbin/post-boot
#echo '      killall -9 chat' >> /usr/local/sbin/post-boot
#echo '      rmmod usbserial' >> /usr/local/sbin/post-boot
#echo '      sleep 10' >> /usr/local/sbin/post-boot
#echo '      if [ -n "'"'"'pidof modem.sh'"'"'" ] ; then' >> /usr/local/sbin/post-boot
#echo '         killall -9  modem.sh' >> /usr/local/sbin/post-boot
#echo '         killall -15 modem.sh' >> /usr/local/sbin/post-boot
#echo '      fi' >> /usr/local/sbin/post-boot
#echo '      echo "Running modem.sh" >> /usr/tmp/syslog.log' >> /usr/local/sbin/post-boot
#echo '      /usr/local/sbin/modem.sh &' >> /usr/local/sbin/post-boot
#echo '      sleep 90' >> /usr/local/sbin/post-boot
#echo '      if (! ping -c 3  $pingsite >/dev/null 2>&1) then' >> /usr/local/sbin/post-boot
#echo '         sleep 120' >> /usr/local/sbin/post-boot
#echo '         reboot' >> /usr/local/sbin/post-boot
#echo '      fi' >> /usr/local/sbin/post-boot
#echo '   else' >> /usr/local/sbin/post-boot
#echo '      /usr/local/sbin/ledctl status on' >> /usr/local/sbin/post-boot
#echo '      echo "Vse OK"' >> /usr/local/sbin/post-boot
#echo '      sleep 30' >> /usr/local/sbin/post-boot
#echo '   fi' >> /usr/local/sbin/post-boot
#echo 'done' >> /usr/local/sbin/post-boot

#Запускаем скрипт с проверкой доступности локальной сети
echo 'echo "Running pingtest.sh" >> /usr/tmp/syslog.log' >> /usr/local/sbin/post-boot
echo '/usr/local/sbin/pingtest.sh &' >> /usr/local/sbin/post-boot

chmod +x /usr/local/sbin/post-boot


#######################################################################################################
# синтезируем скрипт ez-setup.sh
#    обработка нажатия кнопки EZ
#######################################################################################################
##Не используем
#echo '#!/bin/sh' >> /usr/local/sbin/ez-setup
#echo 'echo "EZ-press" >> /usr/tmp/syslog.log' >> /usr/local/sbin/ez-setup
#echo 'killall' >> /usr/local/sbin/ez-setup
#echo 'killall -15 pppd;' >> /usr/local/sbin/ez-setup
#echo 'killall -9 pppd;' >> /usr/local/sbin/ez-setup
#echo 'killall -9 chat' >> /usr/local/sbin/ez-setup

#chmod +x /usr/local/sbin/ez-setup


#######################################################################################################
# синтезируем скрипт ledctl
#    скрипт управления светодиодами
#######################################################################################################

echo '#!/bin/sh' > /usr/local/sbin/ledctl
echo 'GPIO_OUT=/dev/gpio/out' >> /usr/local/sbin/ledctl
echo 'GPIO_OUTEN=/dev/gpio/outen' >> /usr/local/sbin/ledctl
echo 'OUTEN=$'"'"'\77'"'" >> /usr/local/sbin/ledctl
echo 'echo -e -n "$OUTEN\0\0\0" > $GPIO_OUTEN' >> /usr/local/sbin/ledctl
echo 'LED_WLAN=1' >> /usr/local/sbin/ledctl
echo 'LED_WLAN_INVERTED=0' >> /usr/local/sbin/ledctl
echo 'LED_STATUS=2' >> /usr/local/sbin/ledctl
echo 'LED_STATUS_INVERTED=0' >> /usr/local/sbin/ledctl
echo 'LED_RED=8' >> /usr/local/sbin/ledctl
echo 'LED_RED_INVERTED=1' >> /usr/local/sbin/ledctl
echo 'LED_BLUE=16' >> /usr/local/sbin/ledctl
echo 'LED_BLUE_INVERTED=1' >> /usr/local/sbin/ledctl
echo 'LED_PRINT=32' >> /usr/local/sbin/ledctl
echo 'LED_PRINT_INVERTED=0' >> /usr/local/sbin/ledctl
echo 'RETSTATE=' >> /usr/local/sbin/ledctl
echo 'getstate() {' >> /usr/local/sbin/ledctl
echo '    RETSTATE=$(printf "%d" "'"'"'`head /dev/gpio/out -c4`")' >> /usr/local/sbin/ledctl
echo '}' >> /usr/local/sbin/ledctl
echo 'getstate' >> /usr/local/sbin/ledctl
echo 'INIT_STATE=$RETSTATE' >> /usr/local/sbin/ledctl
echo 'INVERTED=0' >> /usr/local/sbin/ledctl
echo 'case $1 in' >> /usr/local/sbin/ledctl
echo '    wlan)' >> /usr/local/sbin/ledctl
echo '        BITMASK=$LED_WLAN' >> /usr/local/sbin/ledctl
echo '        INVERTED=$LED_WLAN_INVERTED' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    status)' >> /usr/local/sbin/ledctl
echo '        BITMASK=$LED_STATUS' >> /usr/local/sbin/ledctl
echo '        INVERTED=$LED_STATUS_INVERTED' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    print)' >> /usr/local/sbin/ledctl
echo '        BITMASK=$LED_PRINT' >> /usr/local/sbin/ledctl
echo '        INVERTED=$LED_PRINT_INVERTED' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    red)' >> /usr/local/sbin/ledctl
echo '        BITMASK=$LED_RED' >> /usr/local/sbin/ledctl
echo '        INVERTED=$LED_RED_INVERTED' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '  blue)' >> /usr/local/sbin/ledctl
echo '        BITMASK=$LED_BLUE' >> /usr/local/sbin/ledctl
echo '        INVERTED=$LED_BLUE_INVERTED' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    *)' >> /usr/local/sbin/ledctl
echo '        exit 1' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo 'esac' >> /usr/local/sbin/ledctl
echo 'if [[ $2 == '"'"'toggle'"'"' ]]' >> /usr/local/sbin/ledctl
echo 'then' >> /usr/local/sbin/ledctl
echo '    FINAL_STATE=$(($INIT_STATE^$BITMASK))' >> /usr/local/sbin/ledctl
echo 'else' >> /usr/local/sbin/ledctl
echo '    FINAL_STATE=$(($INIT_STATE|$BITMASK))' >> /usr/local/sbin/ledctl
echo 'fi' >> /usr/local/sbin/ledctl
echo 'case $2 in' >> /usr/local/sbin/ledctl
echo '    on)' >> /usr/local/sbin/ledctl
echo '        if [[ $INVERTED == 1 ]]' >> /usr/local/sbin/ledctl
echo '        then' >> /usr/local/sbin/ledctl
echo '            FINAL_STATE=$(($FINAL_STATE^$BITMASK))' >> /usr/local/sbin/ledctl
echo '        fi' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    off)' >> /usr/local/sbin/ledctl
echo '        if [[ $INVERTED != 1 ]]' >> /usr/local/sbin/ledctl
echo '    then' >> /usr/local/sbin/ledctl
echo '            FINAL_STATE=$(($FINAL_STATE^$BITMASK))' >> /usr/local/sbin/ledctl
echo '        fi' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    toggle)' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo '    *)' >> /usr/local/sbin/ledctl
echo '        exit 1' >> /usr/local/sbin/ledctl
echo '    ;;' >> /usr/local/sbin/ledctl
echo 'esac' >> /usr/local/sbin/ledctl
echo 'FINAL_STATE_OCT=$(printf "%o" $FINAL_STATE)' >> /usr/local/sbin/ledctl
echo 'echo -e -n "\\$FINAL_STATE_OCT\0\0\0" > $GPIO_OUT' >> /usr/local/sbin/ledctl
echo 'exit 0' >> /usr/local/sbin/ledctl

chmod +x /usr/local/sbin/ledctl



#######################################################################################################
# синтезируем скрипт test-connect
#    скрипт проверки состояния канала связи и управления внешней индикацией
#######################################################################################################
##Не используем
#echo 'port=$(nvram get port)' > /usr/local/sbin/test-connect
#echo 'while true; do' >> /usr/local/sbin/test-connect
#echo '  if [ -e /dev/usb/tts/$port ]; then' >> /usr/local/sbin/test-connect
#echo '    /tmp/local/sbin/ledctl print on' >> /usr/local/sbin/test-connect
#echo '  else' >> /usr/local/sbin/test-connect
#echo '    /usr/local/sbin/ledctl print off' >> /usr/local/sbin/test-connect
#echo '    /usr/local/sbin/ledctl status off' >> /usr/local/sbin/test-connect
#echo '  fi' >> /usr/local/sbin/test-connect
#echo '  if [ -e "`pidof pppd`" ] ; then' >> /usr/local/sbin/test-connect
#echo '    /usr/local/sbin/ledctl status off' >> /usr/local/sbin/test-connect
#echo '  fi' >> /usr/local/sbin/test-connect
#echo '  sleep 1' >> /usr/local/sbin/test-connect
#echo 'done' >> /usr/local/sbin/test-connect

#chmod +x /usr/local/sbin/test-connect


#######################################################################################################
# синтезируем скрипт pingtest.sh
#    скрипт управления маршрутами
#######################################################################################################


echo "#!/bin/bash">/usr/local/sbin/pingtest.sh
#Бесконечный цикл
echo "while true ">>/usr/local/sbin/pingtest.sh
echo "do">>/usr/local/sbin/pingtest.sh
echo "if ping -c 1 -s 1 -W 1 -I vlan1 172.16.5.3">>/usr/local/sbin/pingtest.sh
echo "then">>/usr/local/sbin/pingtest.sh
#Добавляем дефолт роут в локальную сеть, если узел доступен. Если его не было, добавится, если был сругнётся - ну и пусть
echo "    route add default gw 172.16.106.1">>/usr/local/sbin/pingtest.sh
#Правим правила NAT, vlan1 - интерфейс WAN
echo "    iptables -t nat -A POSTROUTING -o vlan1 -j MASQUERADE">>/usr/local/sbin/pingtest.sh
echo "else">>/usr/local/sbin/pingtest.sh
#Удаляем дефолт роут в локальную сеть, если узел недоступен. Поскольку есть второй дефолт роут через модем, он и будет отрабатывать
#Если он был, удалится, если не было сругнётся - ну и пусть
echo "    route del default gw 172.16.106.1">>/usr/local/sbin/pingtest.sh
#Правим правила NAT
echo "    iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE">>/usr/local/sbin/pingtest.sh
echo "fi">>/usr/local/sbin/pingtest.sh
#Каждые две секунды на исполнение
echo "sleep 2 ">>/usr/local/sbin/pingtest.sh
echo "done">>/usr/local/sbin/pingtest.sh



#######################################################################################################
# заполнение списка файлов для сохранения
#######################################################################################################

echo "/usr/local/sbin/modem.sh" > /usr/local/.files
echo "/usr/local/sbin/post-boot" >> /usr/local/.files
#echo "/usr/local/sbin/ez-setup" >> /usr/local/.files
echo "/usr/local/sbin/ledctl" >> /usr/local/.files
#echo "/usr/local/sbin/test-connect" >> /usr/local/.files
echo "/usr/local/sbin/pingtest.sh" >> /usr/local/.files

#######################################################################################################
# сохранение фалов и параметров с перезагрузкой
#######################################################################################################

nvram commit 
flashfs enable
flashfs save
flashfs commit
reboot
