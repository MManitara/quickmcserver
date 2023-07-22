#!/bin/bash

#Ask for server name
read -p "Please enter server name: " name
#Ask for vanilla or paper
read -p "[v]anilla or [p]aper? " jar
#Ask enforce secure profile
read -p "Do you wish to enforce secure profile? (y/n) " secureProf
#Ask online
read -p "Will your server only accept premium players? (y/n) " online
#Ask port
read -p "Do you wish to change the default port? Default: 25565 (y/n) " changePort
#Ask RAM
read -p "Please enter the amount of dedotated wam to a server in gigabytes (G)" ram
if [ $changePort == "y" ]; then
	#Ask for port
	read -p "Please input port number: " portNum
fi
#Download jar files from sources
dlVanFiles () {
	wget https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar
	echo "#!/bin/sh" >> start.sh
	echo "java -Xmx${ram}G -Xms${ram}G -jar server.jar nogui" >> start.sh
	chmod +x start.sh
	./start.sh
}
dlPapFiles () {
	wget https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/84/downloads/paper-1.20.1-84.jar
	echo "#!/bin/sh" >> start.sh
	echo "java -Xmx${ram}G -Xms${ram}G -jar paper-1.20.1-84.jar nogui" >> start.sh
	chmod +x start.sh
	./start.sh
}
#Create server dir and copy files into it
if [ -z "$name" ]; then
	read -p "ERROR: Please specify server name: " name
fi
mkdir $name/
cd ~/$name/
if  [ -z "$jar" ]; then
	read -p "ERROR: Please specify server jar: (v/p)"
fi
if [ $jar == "v" ]; then
	dlVanFiles
	else
	if [ $jar == "p" ]; then
		dlPapFiles
	fi
fi
sleep 3
#Automatically accept the EULA
echo "Waiting for the eula.txt file..."
sed -i "s/false/true/" eula.txt
sleep 3
echo "EULA accepted succesfully!"
sleep 1
#Boot server and install config files
echo "***The server will now boot for a second time,"
echo "let it fully boot then close it again to finish configuration.***"
read -p "(Enter)"
echo "Booting up the server..."
./start.sh
#Finish config
if [ $secureProf == "n" ]; then
	sed -i "s/enforce-secure-profile=true/enfore-secure-profile=false/" server.properties
	echo "enforce-secure-profile is set to: FALSE"
	else
	echo "enforce-secure-profile is set to: TRUE"
fi
sleep 1
if [ $online == "n" ]; then
	sed -i "s/online-mode=true/online-mode=false/" server.properties
	echo "online is set to: FALSE"
	else
	echo "online is set to: TRUE"
fi
sleep 1
if [ $changePort == "y" ]; then
	sed -i "s/server-port=25565/server-port=$portNum/" server.properties
	echo "server-port is set to: " $portNum
	else
	echo "server-port is set to: DEFAULT (25565)"
fi
sleep 1
echo "Server configuration has finished! Do you wish to boot the server now?"
read -p "(y/n)" bootnow
if [ $bootnow == "y" ]; then
	echo "If you intend to play with friends, make sure you have port '25565' (or the one you set during config) forwarded on your network!"
	sleep 1
	echo "Starting server..."
	sleep 2
	./start.sh
	else
	echo "Use the ./start.sh command to boot up your server when you wish to play on it!"
fi






