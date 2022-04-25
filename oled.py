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
x = 0

def resources():
    draw.rectangle((0,0,width,height), outline=0, fill=0)
    cmd = "hostname -I | cut -d\' \' -f1" 
    ip = subprocess.check_output(cmd, shell=True)

    cmd = """top -bn1 | grep load | awk "{printf \'CPU Load: %.2f\', $(NF-2)}""""
    cpu = subprocess.check_output(cmd, shell=True)

    cmd = "free -m | awk 'NR==2{printf \"Mem: %s/%s MB\", $3, $2, $3*100/$2 }'"
    mem = subprocess.check_output(cmd, shell=True)

    cmd = "vcgencmd measure_temp"
    temp = subprocess.check_output(cmd, shell=True)

    draw.text((x, top), "IP: {}".format(ip.decode('utf-8')), font=font, fill=255)
    draw.text((x, top+8), "{}".format(cpu.decode('utf-8')), font=font, fill=255)
    draw.text((x, top+16), "{}".format(mem.decode('utf-8')), font=font, fill=255)
    draw.text((x, top+25), "{}".format(temp.decode('utf-8')), font=font, fill=255)

    oled.image(image)
    oled.display()
    time.sleep(2)

def datetime():
    cmd = "date '+%a %d %b %Y'"
    date = subprocess.check_output(cmd, shell=True)
    draw.text((x, top), "{}".format(date.decode('utf-8')), font=font, fill=255)
    time.sleep(3)

while True:
    for _ in range(5):
        resources()
    datetime()
    
    
