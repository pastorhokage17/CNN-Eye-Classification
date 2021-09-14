# from test_cnn import IMG_SIZE
import sys
import cv2
import os
import matplotlib.pyplot as plt
import numpy as np
import random
import pickle
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
# from test_cnn import IMG_SIZE
IMG_SIZE = 224
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def Predict():    
    #try:
    img = cv2.imread("C:/Users/Miggy/OneDrive/Desktop/EyeDataSet/CloseEye/s0001_00576_0_0_0_0_0_01.png", cv2.IMREAD_GRAYSCALE)
    b2rgb = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
    img = cv2.resize(b2rgb, (IMG_SIZE,IMG_SIZE))
    input = np.array(img).reshape(1, IMG_SIZE, IMG_SIZE, 3)
    input = input/255.0

    test_model =  tf.keras.models.load_model('latest_cnntest.h5')
    predict = test_model.predict(input)
    #plt.close(img)
    # if predict > 0.8:
    #     print("Open eye/s found with confidence of {0:.2f}%".format(predict[0][0]*100))
    # else:
    #     print("Closed eye/s found with confidence of {0:.2f}%".format((1-predict[0][0])*100))        
    #except:
        #print("Try checking the spelling of the image path.")
    #Draw(test_model)
    VideoDemo(test_model)

def Draw(eyestate_model):
    roi_eyes = None
    img0 = cv2.imread("IMG_20210914_100804.jpg")
    plt.imshow(img0)
    faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')
    gray = cv2.cvtColor(img0, cv2.COLOR_BGR2GRAY)
    eyes = eye_cascade.detectMultiScale(gray,1.1,4)
    for  x,y,w,h in eyes:
        roi_gray = gray[y:y+h, x:x+w]
        roi_color = img0[y:y+h, x:x+w]
        gray_eyes = eye_cascade.detectMultiScale(roi_gray)
    if len(gray_eyes) == 0:
        print("No eyes detected.")
    else:
        for(ex,ey,ew,eh) in gray_eyes:
            roi_eyes = roi_color[ey:ey+eh, ex:ex+ew]
    eye_area = cv2.resize(roi_eyes,(224,224))
    eye_area = np.expand_dims(eye_area,axis=0)
    eye_area = eye_area/255.0 # detected, isolated eye area within the image
    
    outimg = cv2.cvtColor(img0, cv2.COLOR_BGR2RGB)
    
    #plt.savefig('eyesdetect.png')
    eyestate_model.predict(outimg) #using trained model to detect eyestate of the eyes
    plt.imshow(outimg)
    #cv2.rectangle(img0, (x,y), (x+w, y+h), (0, 255, 0), 2)

    # outimg = cv2.cvtColor(img0, cv2.COLOR_BGR2RGB)
    # plt.imshow(outimg)
    # plt.savefig('eyesdetect.png')

def VideoDemo(eyestate_model):
    path = "haarcascade_frontalface_default.xml"    
    faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        cap = cv2.VideoCapture(1)
    if not cap.isOpened():
        raise IOError("Cannot open webcam")

    
    while True:
        eyes_roi = None
        ret,frame = cap.read()
        eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        eyes = eye_cascade.detectMultiScale(gray,1.1,4)
        for x,y,w,h in eyes: 
            roi_gray = gray[y:y+h, x:x+w]
            roi_color = frame[y:y+h, x:x+w]
            cv2.rectangle(frame, (x,y), (x+w, y+h), (0, 255, 0), 2)
            eyess = eye_cascade.detectMultiScale(roi_gray)
            if len(eyess) == 0:
                print("eyes are not detected")
            else:
                for (ex,ey,ew,eh) in eyess:
                    eyes_roi = roi_color[ey: ey+eh, ex:ex + ew]
        try:
            final_image = cv2.resize(eyes_roi, (224,224))
            final_image = np.expand_dims(final_image,axis =0)
            final_image = final_image/255.0

            Predictions = eyestate_model.predict(final_image)
            if (Predictions > 0.5):
                status = "Open Eyes"
            else:
                status = "Close Eyes"

            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            print(faceCascade.empty())
            faces = faceCascade.detectMultiScale(gray,1.1,4)

            for(x, y, w, h) in faces:
                cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 255, 0), 2)

            font = cv2.FONT_HERSHEY_SIMPLEX

            cv2.putText(frame, status, (50,50), font, 3, (0, 0, 255), 2, cv2.LINE_4)
            cv2.imshow('Drowsiness Detection Tutorial', frame)
        except:
            cv2.imshow('Drowsiness Detection Tutorial', frame)

        if cv2.waitKey(2) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    

def main():
    #VideoDemo(tf.keras.models.load_model('latest_cnntest.h5'))
    Draw(tf.keras.models.load_model('latest_cnntest.h5'))

main()
    #C:/Users/Miggy/OneDrive/Desktop/EyeDataSet/CloseEye/s0001_00576_0_0_0_0_0_01.png
    #C:/Users/Miggy/OneDrive/Desktop/EyeDataSet/OpenEye/s0001_01848_0_0_1_0_0_01.png
    #C:/Users/Miggy/OneDrive/Desktop/EyeDataSet/CloseEye/s0001_00792_0_0_0_0_0_01.png
    # plt.imshow(img, cmap = "gray")
    
    