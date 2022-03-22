import logging
import datetime
import dlib
import time
from yawn_detector import *
from helper import *
from ear_calculate import *
from cnn import *

logging.basicConfig(level=logging.INFO)
BUFFER = 8


def main():
    logging.info("[{}] -- Setting up dependencies ...".format(datetime.datetime.now()))
    detector = dlib.get_frontal_face_detector()  				#dlib's face detector (uses HOG)
    predictor = dlib.shape_predictor('facial_landmarks.dat')	#dlib's pretrained model to recognise facial features (uses regression trees)
    #--------------------------------------------------------
    logging.info("[{}] -- Loading trained model ...".format(datetime.datetime.now()))
    model = load_model('drowsyv3.hd5')							#Trained model for predicting state of the eyes
    #--------------------------------------------------------
    logging.info("[{}] -- Setting up GPIO board ...".format(datetime.datetime.now()))
    setgpio() #uncomment for jetson nano
    #--------------------------------------------------------
    logging.info("[{}] -- Opening camera ...".format(datetime.datetime.now()))
    #cam=cv2.VideoCapture(0)
    
    cam=cv2.VideoCapture(gstreamer_pipeline(flip_method=6), cv2.CAP_GSTREAMER)
    while True:
        cef = 0 # cef - closed eye frames
        f = 0
        d_state = "n/a"
        t_start = time.process_time()
        for j in range(BUFFER):
            
            ret,image = cam.read()
            image = resize(image, width=500)
            cnn_image=image.copy()
            gray = cv2.cvtColor(cnn_image, cv2.COLOR_BGR2GRAY)				#Gray input for CNN
            brighter_image = increase_brightness(image)
            equalized_image = histogram_equalization(brighter_image)
            faces = detector(equalized_image, 1)
            for (i, face) in enumerate(faces):
                facial_features = predictor(equalized_image, face)
                facial_features = shape_to_np(facial_features)
                left_eye_ear,right_eye_ear = get_eyes(facial_features) #Just for drawing
                right_eye_cnn = reshape_eye(gray, eye_points=right_eye_ear)
                left_eye_cnn = reshape_eye(gray, eye_points=left_eye_ear)
                eye_state_cnn = predict(model,left_eye_cnn,right_eye_cnn) #output: "open" / "close"
                
                if eye_state_cnn <=0.02:
                    cef += 1
                logging.info(" -- eye_state_cnn: {}".format(eye_state_cnn))
            if j == BUFFER-1: #buffer full
                if cef >= 5:
                    cef = 0
                    d_state = "innatentive"
                    # ring()
                else:
                    d_state = "neutral"
        t_end = time.process_time() - t_start
        logging.info(" -- Driver state: ({}), closed-eye frames: {}, time elapsed: {:.2f}".format(d_state,cef,t_end))
        logging.info(" -- current mean frames/second proccesed: {:.2f}/s".format(BUFFER/t_end))


#         if cv2.waitKey(1) & 0xFF == ord('q'):
#             break




if __name__ == "__main__":
    main()
