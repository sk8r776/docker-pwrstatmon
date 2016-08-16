#!/bin/bash

#This script gets the current power information
#from the main UPS

#The time we are going to sleep between readings
sleeptime=5

#Prepare to start the loop and warn the user
echo "Press [CTRL+C] to stop..."
while :
do

	#Get the current dump of the stats
	upsstats=`pwrstat -status`
	
	#Lets try to find the lines we are looking for
	while read -r line; do
		#Check if we have the line we are looking for
		if [[ $line == *"State."* ]]
		then
		  state=$line
		fi
		if [[ $line == *"Power Supply by"* ]]
		then
		  supply=$line
		fi
		if [[ $line == *"Utility Voltage"* ]]
		then
		  involts=$line
		fi
		if [[ $line == *"Output Voltage"* ]]
		then
		  outvolts=$line
		fi
		if [[ $line == *"Battery Capacity"* ]]
		then
		  capacity=$line
		fi
		if [[ $line == *"Remaining Runtime"* ]]
		then
		  runtime=$line
		fi
		if [[ $line == *"Load."* ]]
		then
		  load=$line
		fi
		if [[ $line == *"Line Interaction"* ]]
		then
		  interaction=$line
		fi
	done <<< "$upsstats"
	
	#Remove the long string of .s
	state=$(echo $state | tr -s '[.]')
	supply=$(echo $supply | tr -s '[.]')
	involts=$(echo $involts | tr -s '[.]')
	outvolts=$(echo $outvolts | tr -s '[.]')
	capacity=$(echo $capacity | tr -s '[.]')
	runtime=$(echo $runtime | tr -s '[.]')
	load=$(echo $load | tr -s '[.]')
	interaction=$(echo $interaction | tr -s '[.]')
	
	#Lets parse out thevalues from the strings
	#First split on the .
	IFS='.' read -ra statearr <<< "$state"
	state=${statearr[1]}
	IFS='.' read -ra supplyarr <<< "$supply"
	supply=${supplyarr[1]}
	IFS='.' read -ra involtsarr <<< "$involts"
	involts=${involtsarr[1]}
	IFS='.' read -ra outvoltsarr <<< "$outvolts"
	outvolts=${outvoltsarr[1]}
	IFS='.' read -ra capacityarr <<< "$capacity"
	capacity=${capacityarr[1]}
	IFS='.' read -ra runtimearr <<< "$runtime"
	runtime=${runtimearr[1]}
	IFS='.' read -ra loadarr <<< "$load"
	load=${loadarr[1]}
	IFS='.' read -ra interactionarr <<< "$interaction"
	interaction=${interactionarr[1]}
	
	#We need an extra split for the load
	IFS='(' read -ra loadarr <<< "$load"
	loadwatt=${loadarr[0]}
	loadpercent=${loadarr[1]}
	
	#Remove unneeded spaces
	state=$(echo $state | xargs)
	supply=$(echo $supply | xargs)
	involts=$(echo $involts | xargs)
	outvolts=$(echo $outvolts | xargs)
	capacity=$(echo $capacity | xargs)
	runtime=$(echo $runtime | xargs)
	loadwatt=$(echo $loadwatt | xargs)
	loadpercent=$(echo $loadpercent | xargs)
	interaction=$(echo $interaction | xargs)
	
	#Now we just strip off some of the unneeded
	#info from the end of the strings
	involts=`echo $involts |awk {'print $1'}`
	outvolts=`echo $outvolts |awk {'print $1'}`
	runtime=`echo $runtime |awk {'print $1'}`
	capacity=`echo $capacity |awk {'print $1'}`
	loadwatt=`echo $loadwatt |awk {'print $1'}`
	loadpercent=`echo $loadpercent |awk {'print $1'}`
	
	#Convert State to a 0 or a 1
	# 1 = Normal
	# 0 = Error
	if [ "$state" = "Normal" ]; then
		state=1
	else
		state=0
	fi

	#Convert Utility Power to a 0 or a 1
	# 1 = Utility Power
	# 0 = Battery
	if [ "$supply" = "Utility Power" ]; then
		supply=1
	else
		supply=0
	fi

	echo "$state"
	echo "$supply"
	echo "$involts"
	echo "$outvolts"
	echo "$runtime"
	echo "$capacity"
	echo "$loadwatt"
	echo "$loadpercent"
	echo "$interaction"
	
	#Finally we can write it to the database
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=state value=$state"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=supply value=$supply"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=involts value=$involts"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=outvolts value=$outvolts"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=runtime value=$runtime"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=capacity value=$capacity"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=loadwatt value=$loadwatt"
	curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=loadpercent value=$loadpercent"
	#curl -i -XPOST 'http://172.16.103.2:8086/write?db=NetworkDevices' --data-binary "BBU,ups=ESSOS,metric=interaction value=$interaction"
	
	#Wait for a bit before checking again
	sleep "$sleeptime"
	
done