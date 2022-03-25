#from asyncio.proactor_events import constants
from threading import Thread
from helper import *
import dlib
import logging
from ear_calculate import *
from cnn import *
import time
BUFFER = 8

def cnn_calculate(image, closed, counter,results):
    image = resize(image, width=500)
    cnn_image=image.copy()
    gray = cv2.cvtColor(cnn_image, cv2.COLOR_BGR2GRAY)                #Gray input for CNN
    brighter_image = increase_brightness(image)
    equalized_image = histogram_equalization(brighter_image)
    faces = detector(equalized_image, 1)
    for (i, face) in enumerate(faces):
        facial_features = predictor(equalized_image, face)
        facial_features = shape_to_np(facial_features)
        ear=calculate_ear(facial_features)
        left_eye_ear,right_eye_ear = get_eyes(facial_features)
        right_eye_cnn = reshape_eye(gray, eye_points=right_eye_ear)
        left_eye_cnn = reshape_eye(gray, eye_points=left_eye_ear)
        eye_state_cnn = predict(model,left_eye_cnn,right_eye_cnn)
        if eye_state_cnn == "close":
            closed += 1
    if results[1] == None:
        if len(faces) == 1:
            state = "attentive"
        else: #-----------------> apparently when no faces is detected, N/A state
            state = "N/A"        
    else:
        state = results[1]
        
    if counter == BUFFER-1: #if and only if buffer is full, then update state 
        if len(faces) == 0:
            state = "N/A"
        elif closed >= 5:
            closed = 0
            state = "innatentive"
            # ring()
        else:
            state = "attentive"
    results[0] = len(faces)
    results[1] = state
    results[2] = closed



logging.info("Setting up dependencies...")
detector = dlib.get_frontal_face_detector()                  #dlib's face detector (uses HOG)
predictor = dlib.shape_predictor('facial_landmarks.dat')    #dlib's pretrained model to recognise facial features (uses regression trees)
logging.info("Loading trained model...")
model = load_model('drowsyv3.hd5')                            #Trained model for predicting state of the eyes
logging.info("Setting up Jetson GPIO...")
# setgpio()

logging.info("Opening camera...")
cam=cv2.VideoCapture(gstreamer_pipeline(flip_method=6), cv2.CAP_GSTREAMER)
#cam = cv2.VideoCapture(0)
fps = cam.get(cv2.CAP_PROP_FPS)
if cam.isOpened():
    logging.info('Camera On...')
    results = [None]*3
    threads = [None]*2
    try:
        run = True
        while run:
            results[2] = 0
            t_start = time.process_time()
            for j in range(BUFFER):
                ret,image = cam.read()
                try:
                    if results[1] == None:
                        cnn_calculate(image,0,j,results)
                        message(fps, results[0], results[1], results[2], BUFFER)
                        
                    else:
                        threads[0] = Thread(target = cnn_calculate, args=(image,results[2],j,results))
                        threads[0].start()
                        if j == BUFFER-1:
                            threads[1] = Thread(target = message, args=(fps, results[0], results[1], results[2], BUFFER))
                            threads[1].start()
                            for l in range(len(threads)):
                                threads[l].join()
                        else:
                            threads[0].join()
                except:
                    logging.info("An exception has been thrown during runtime ...")
                    run = False
                    break
            if not(run):
                break    
            t_end = time.process_time() - t_start
            logging.info(" -- current mean frames/second proccesed: {:.2f}/s".format(BUFFER/t_end))
    finally:
        cam.release()
        logging.info('Interrupted. Closing Program...')
        time.sleep(0.5)
else:
    logging.info('Camera not found.')
