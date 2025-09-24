#!/bin/bash
echo "Script to install oled and leds python scripts."

echo "Updating repos..."
apt -qq update && apt -qq upgrade

echo "Installing or updating dependencies..."
apt -qq install build-essential python3-dev python3-pip python3-numpy raspi-config -y

tmpFolder="/tmp"
cd $tmpFolder

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
if [ $(raspi-config nonint get_i2c) -eq 1 ]
then
        echo "I2C not enabled! Enabling it..."
        raspi-config nonint do_i2c 0
else
        echo "I2C enabled!"
fi

echo "Installing Python libraries through apt..."
apt -qq install python3-setuptools python3-wheel \
        python3-smbus python3-pil -y
echo "Installing Python libraries through pip... (no other alternatives!)"
pip3 install pi-ina219 adafruit-circuitpython-ssd1306 Adafruit-Blinka -q --break-system-package --disable-pip-version-check --root-user-action=ignore
echo "Installing Adafruit_BBIO by compiling from source..."
git clone https://github.com/adafruit/adafruit-beaglebone-io-python.git
cd adafruit-beaglebone-io-python
pip install .
cd ..

echo "Moving scripts..."
mkdir $HOME/Scripts
mv *.py $HOME/Scripts


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
