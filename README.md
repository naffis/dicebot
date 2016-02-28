# DiceBot

Uses OpenCV, Python, Ruby, and a Raspberry Pi to listen for tweeted requests to spin a physical dice roller, count the pips on the dice, then tweet back the results. 


### spin the wheel

    sudo python spin.py

### take a still image named image.jpg, wait 0 ms, no preview, 640x480

    raspistill -o dice.jpg -n -t 0 -w 640 -h 480

### count dice pips in image

    ./count dice.jpg 




