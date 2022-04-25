#!/bin/bash
echo "Script to install oled and leds python scripts"

tmpFolder="/tmp"
bbioLink="https://github.com/adafruit/adafruit-beaglebone-io-python.git"
scriptsLink="https://github.com/SergioPrinci/EP0152-Scripts.git"

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
        apt install python3-pip -y
fi

if $(git --version > /dev/null);
then
        echo "Git found!"
else
        echo "Git not found, installing it..."
        apt install git -y
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
pip install setuptools wheel -q
pip install pi-ina219 -q
pip install Adafruit-SSD1306 -q
pip install smbus Pillow -q

echo "Cloning BBIO repo..."
cd $tmpFolder
git clone $bbioLink -q
cd adafruit-beaglebone-io-python
python3 setup.py -q install

echo "Downloading scripts..."
git clone $scriptsLink -q
cd EP0152-Scripts
mkdir $HOME/Scripts
mv *.py $HOME/Scripts

echo "Modifying rc.local..."
rm /etc/rc.local
echo -e "#!/bin/sh -e\npython3 $HOME/Scripts/leds.py\npython3 $HOME/Scripts/oled.py\nexit" > /etc/rc.local
chmod +x /etc/rc.local

echo "All done!"
echo "Can I reboot your machine? (y/n)"
read;
if [ $REPLY == "y" ]
then
        reboot
fi

exit 0
