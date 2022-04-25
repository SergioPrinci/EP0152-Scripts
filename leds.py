import RPi.GPIO as GPIO
import time 

# BCM Number of LED indicators
leds = [5, 6, 13, 19]

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

for i in range(len(leds)):
    GPIO.setup(leds[i], GPIO.OUT)
for led in leds:
    GPIO.output(led, HIGH)
