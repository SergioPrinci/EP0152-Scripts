#!/bin/sh
echo "Script to install oled and leds python scripts"

tmpFolder="/tmp"
bbioLink="https://github.com/adafruit/adafruit-beaglebone-io-python.git"
oledLink="https://github.com/SergioPrinci/EP0152-Scripts.git"

if [ $EUID -ne 0 ]
then
        echo "Please run as root"
        exit
fi

if $(pip --version > /dev/null);
then
        echo "Pip found!"
else
        echo "Pip not found, installing it..."
        apt install python3-pip
fi

if $(git --version > /dev/null);
then
        echo "Git found!"
else
        echo "Git not found, installing it..."
        apt install git
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
python3-pip install setuptools wheel -q
python3-pip install pi-ina219 -q
python3-pip install Adafruit-SSD1306 -q

echo "Cloning BBIO repo..."
cd $tmpFolder
git clone $bbioLink -q
cd adafruit-beaglebone-io-python
python3 setup.py install

echo "Downloading scripts..."
git clone $scriptsLink -q
cd RPiFEBP
mkdir $HOME/Scripts
mv oled.py $HOME/Scripts/*.py

echo "Modifying rc.local..."
rm /etc/rc.local
echo "#!/bin/sh -e\npython $HOME/Scripts/leds.py\npython $HOME/Scripts/oled.py\nexit" > /etc/rc.local
chmod +x /etc/rc.local

echo "All done!"
echo "Can I reboot your machine? (y/n)"
read;
if [ $REPLY == "y" ]
then
        reboot
fi

exit 0
