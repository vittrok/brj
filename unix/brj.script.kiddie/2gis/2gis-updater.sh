#!/bin/sh
gisDir=/volume1/programs/2gis
logDir=$gisDir/2gis-updater-logs/
useLog=false
silent=false
logFile=$logDir/$(date +%Y-%m-%d).log
if [ "$1" == "--l" ] ||  [ "$2" == "--l" ] 
then
	useLog=true
	if !(test -d $logDir)
	then
		mkdir $logDir
	fi
	if test -f $logFile
	then
		rm $logFile
	fi
fi
if [ "$1" == "--s" ] || [ "$2" == "--s" ] 
then
	silent=true
fi

GetPackage() {
	Write -n "Updating $1... "
	if !(test -d $gisDir/tmp)
	then
		mkdir $gisDir/tmp
	fi
	cd $gisDir/tmp
	Write -n "Geting filename... "
	packageFile=$(curl -s -I  http://www.2gis.ru/distributive/$1/last/linux/ | grep -o -E '[A-Za-z0-9_\.\-]*\.zip')
	if [ -z "$packageFile" ] 
	then
		Write -e "\\033[31mError getting filename!\\033[0m"
		return
	fi
	if test -f $gisDir/old/$packageFile
	then
		Write -e "\\033[33mAlready updated.\\033[0m"
		return
	fi
	Write -n "Downloading file $packageFile... "
	rm -R $gisDir/tmp/* 2> /dev/null
	wget -q  http://download.2gis.ru/arhives/$packageFile
	if !(test -f $packageFile)
	then
		Write -e "\\033[31mError downloading file!\\033[0m"
		return
	fi
	Write -n "Unzipping... "
	unzip -q -o $packageFile
	Write -n "Updating files... "
	if !(test -d $gisDir/old)
	then
		mkdir $gisDir/old
	fi
	cp -R $gisDir/tmp/2gis/3.0/* $gisDir 2> /dev/null
	rm $gisDir/old/*$1* 2> /dev/null
	cp $packageFile $gisDir/old 2> /dev/null
	Write -n "Cleaning... "
	rm -R $gisDir/tmp/* 2> /dev/null
	Write -e "\\033[32mUpdated!\\033[0m"
}
Write() {
	if !($silent)
	then
		echo $@
	fi
	if $useLog 
	then
		echo $@ >> $logFile
	fi
}

Write $(date)
GetPackage shell
Write -n "Get cities..."
cities=$(wget -q -O- http://nizhnevartovsk.2gis.ru/how-get/linux/ | sed -n 's|^.*href="http://\(\w\+\)\.2gis\.ru/how-get/linux/".*$|\1|p')
Write -e "\\033[32mDone!\\033[0m"
for city in $cities
do
	GetPackage $city
done
Write -e "\\033[32mDone!\\033[0m"