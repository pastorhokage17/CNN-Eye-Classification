import cv2
import math
import logging
import time
import RPi.GPIO as GPIO
import numpy as np



logging.basicConfig(level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')
IMG_SIZE = (24,24)


def resize(image, width=None, height=None, inter=cv2.INTER_AREA):
	dim = None
	(h, w) = image.shape[:2]
	dim = (h,width)

	# resize the image
	resized = cv2.resize(image, dim, interpolation=inter)

	return resized

def reshape_eye(img, eye_points):
	x1, y1 = np.amin(eye_points, axis=0)
	x2, y2 = np.amax(eye_points, axis=0)
	cx, cy = (x1 + x2) / 2, (y1 + y2) / 2

	w = (x2 - x1) * 2.3
	h = w * IMG_SIZE[1] / IMG_SIZE[0]

	margin_x, margin_y = w / 2, h / 2

	min_x, min_y = int(cx - margin_x), int(cy - margin_y)
	max_x, max_y = int(cx + margin_x), int(cy + margin_y)

	eye_rect = np.rint([min_x, min_y, max_x, max_y]).astype(np.int)

	eye_img = img[eye_rect[1]:eye_rect[3], eye_rect[0]:eye_rect[2]]
	eye_img = cv2.resize(eye_img, dsize=IMG_SIZE)
	eye_img = eye_img.reshape((1, IMG_SIZE[1], IMG_SIZE[0], 1)).astype(np.float32) 
	return eye_img

def histogram_equalization(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return cv2.equalizeHist(gray) 

def increase_brightness(img, value=30):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)

    lim = 255 - value
    v[v > lim] = 255
    v[v <= lim] += value

    final_hsv = cv2.merge((h, s, v))
    img = cv2.cvtColor(final_hsv, cv2.COLOR_HSV2BGR)
    return img

def rect_to_bb(rect):
	# Converts the bounding box predicted by dlib to the OpenCv's (x, y, w, h) format
	x = rect.left()
	y = rect.top()
	w = rect.right() - x
	h = rect.bottom() - y

	return (x, y, w, h)

def shape_to_np(shape, dtype="int"):
	coords = np.zeros((shape.num_parts, 2), dtype=dtype)
	# Converts points of interest from (x,y) to [x y] format 
	for i in range(0, shape.num_parts):
		coords[i] = (shape.part(i).x, shape.part(i).y)

	return coords

def distance(a,b):
	x1,y1=a
	x2,y2=b
	return math.sqrt((abs(x1-x2)**2)+(abs(y1-y2)**2))

def gstreamer_pipeline(
    capture_width=1640,
    capture_height=1232,
    display_width=820,
    display_height=616,
    framerate=30,
    flip_method=0,
):
    return (
        "nvarguscamerasrc ! "
        "video/x-raw(memory:NVMM), "
        "width=(int)%d, height=(int)%d, "
        "format=(string)NV12, framerate=(fraction)%d/1 ! "
        "nvvidconv flip-method=%d ! "
        "video/x-raw, width=(int)%d, height=(int)%d, format=(string)BGRx ! "
        "videoconvert ! "
        "video/x-raw, format=(string)BGR ! appsink"
        % (
            capture_width,
            capture_height,
            framerate,
            flip_method,
            display_width,
            display_height,
        )
    )


def message(fps, faces, eyestate, a, b):
    logging.info('FPS: {}, Faces: {}, Eye State: {}, Buffer: {}/{}'.format(fps, faces, eyestate,a,b))
    #logging.info('FPS: {}, Faces: {}, Eye State: {}, Buffer: {}/{}'.format(fps, len(faces), state, closed, BUFFER))
    

def setgpio():
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(12,GPIO.OUT)
    GPIO.output(12,GPIO.HIGH) #no ring when high

def ring():
    GPIO.output(12,GPIO.LOW)
    time.sleep(0.2)
    GPIO.output(12,GPIO.HIGH)
    time.sleep(0.2)
    GPIO.output(12,GPIO.LOW)
    time.sleep(0.2)
    GPIO.output(12,GPIO.HIGH)

