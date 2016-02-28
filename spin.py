import RPi.GPIO as gpio
import time
gpio.setmode(gpio.BOARD)

gpio.setup(13, gpio.OUT)
gpio.setup(15, gpio.OUT)


gpio.output(13, True)
gpio.output(15, False)
time.sleep(0.50)
gpio.output(13, False)
gpio.output(15, False)
time.sleep(1)
gpio.cleanup()
