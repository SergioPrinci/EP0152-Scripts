#!/bin/bash
echo "Script to install oled and leds python scripts."

echo "Updating repos..."
apt -qq update

echo "Installing or updating dependencies..."
apt -qq install build-essential python3-dev python3-pip -y

tmpFolder="/tmp"

if [ "$EUID" -ne 0 ]
then
        echo "Please run as root"
        exit
fi

if $(pip --version > /dev/null);
then
        echo "Pip found!"
else
        echo "Pip not found, installing it..."
        apt -qq install python3-pip -y
fi

if $(git --version > /dev/null);
then
        echo "Git found!"
else
        echo "Git not found, installing it..."
        apt -qq install git -y
fi

echo "Making sure you enabled I2C..."
if [ $(raspi-config nonint get_i2c) == 1 ]
then
        echo "I2C not enabled! Enabling it..."
        raspi-config nonint do_i2c 0
else
        echo "I2C enabled!"
fi

echo "Installing pip libraries..."
pip3 install setuptools wheel -q
pip3 install pi-ina219 -q
pip3 install Adafruit-SSD1306 -q
pip3 install smbus Pillow -q
pip3 install Adafruit_BBIO -q

echo "Moving scripts..."
if [ -f oled.py && -f leds.py]; then
        mkdir $HOME/Scripts
        mv *.py $HOME/Scripts
fi

echo "Appending edits to rc.local..."
echo -e "#!/bin/sh -e\npython3 $HOME/Scripts/leds.py\npython3 $HOME/Scripts/oled.py\nexit" >> /etc/rc.local
if [ -x /etc/rc.local ]; then 
        chmod +x /etc/rc.local
fi

echo "All done!"
echo "Can I reboot your machine? (y/n)"
read;
if [ $REPLY == "y" ]
then
        reboot
fi

exit 0
