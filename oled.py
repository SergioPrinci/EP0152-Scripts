import time
import subprocess
import smbus
import Adafruit_SSD1306 as ssd1306
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

BUS = 1
ADDR = 0x3C
RST = None

oled = ssd1306.SSD1306_128_32(rst=RST, i2c_address=ADDR)

oled.begin()
oled.clear()
oled.display()

width = oled.width
height = oled.height
image = Image.new('1', (width, height))

draw = ImageDraw.Draw(image)

draw.rectangle((0,0,width,height), outline=0, fill=0)

font = ImageFont.load_default()

padding = -2
top = padding
bottom = height - padding
x = 2

def resources():
    draw.rectangle((0,0,width,height), outline=0, fill=0)
    cmd = "hostname -I | cut -d\' \' -f1"
    ip = subprocess.check_output(cmd, shell=True).decode('utf-8')
    ip = "Ip: " + ip

    cmd = """top -bn1 | grep load | awk '{printf "CPU Load: %.2f%%", $(NF-2)}'"""
    cpu = subprocess.check_output(cmd, shell=True).decode('utf-8')

    cmd = "free -m | awk 'NR==2{printf \"Mem: %s/%s MB\", $3, $2, $3*100/$2 }'"
    mem = subprocess.check_output(cmd, shell=True).decode('utf-8')

    cmd = "vcgencmd measure_temp"
    temp = subprocess.check_output(cmd, shell=True).decode('utf-8')
    temp = temp.replace("temp=", "Temp: ")

    draw.text((x, top), "{}".format(ip), font=font, fill=255)
    draw.text((x, top+8), "{}".format(cpu), font=font, fill=255)
    draw.text((x, top+16), "{}".format(mem), font=font, fill=255)
    draw.text((x, top+25), "{}".format(temp), font=font, fill=255)

    oled.image(image)
    oled.display()
    time.sleep(2)

def datetime():
    draw.rectangle((0,0,width,height), outline=0, fill=0)

    cmd = "date '+%a %d %b %Y'"
    date = subprocess.check_output(cmd, shell=True).decode('utf-8')
    cmd = "date '+%H:%m'"
    hour = subprocess.check_output(cmd, shell=True).decode('utf-8')
    cmd = "uptime -p"
    uptime = subprocess.check_output(cmd, shell=True).decode('utf-8')
    uptime = uptime.replace("up", "")

    draw.text((x+18, top+4), "{}".format(date), font=font, fill=255)
    draw.text((x+44, top+12), "{}".format(hour), font=font, fill=255)
    if uptime.__len__() > 12:
        draw.text((x, top+20), "Up:{}".format(uptime), font=font, fill=255)
    else:
        draw.text((x+12, top+20), "Uptime:{}".format(uptime), font=font, fill=255)

    oled.image(image)
    oled.display()
    time.sleep(3)

while True:
    for _ in range(5):
        resources()
    datetime()
