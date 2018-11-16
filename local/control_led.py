
import requests
import time
import RPi.GPIO as GPIO
import datetime

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(True)
GPIO.setup(18, GPIO.OUT)

if __name__ == '__main__':
    try:
        while (True):
            with requests.get("https://still-crag-29020.herokuapp.com/") as url:

                if "1" in url.text:
                    print("LED on " , datetime.datetime.now())
                    GPIO.output(18, GPIO.HIGH)
                if "0" in url.text:
                    print("LED off " , datetime.datetime.now())
                    GPIO.output(18, GPIO.LOW)

    except KeyboardInterrupt:
        GPIO.cleanup()
        print("ctrl+c")
