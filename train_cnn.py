import cv2
import os
import matplotlib.pyplot as plt
import numpy as np
import random
import pickle
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

IMG_SIZE = 224

def create_training_Data():
    training_Data = []
    # img_array = cv2.imread("C:/Users/Miggy/Downloads/Desktop/EyeDataSet/CloseEye/s0001_00573_0_0_0_0_0_01.png", cv2.IMREAD_GRAYSCALE)
    # C:\Users\Miggy\OneDrive\Desktop
    Datadirectory = "C:/Users/Miggy/OneDrive/Desktop/EyeDataSet/"
    Classes = ["CloseEye","OpenEye"]
    for category in Classes:
        path = os.path.join(Datadirectory, category)
        class_num = Classes.index(category)
        for img in os.listdir(path):
            img_array = cv2.imread(os.path.join(path,img), cv2.IMREAD_GRAYSCALE)
            backtorgb = cv2.cvtColor(img_array, cv2.COLOR_GRAY2RGB)
            new_array = cv2.resize(backtorgb, (IMG_SIZE,IMG_SIZE))
            training_Data.append([new_array,class_num])
    return training_Data



training_Data = create_training_Data()
random.shuffle(training_Data)
X = []
y = []
for features,label in training_Data:
    X.append(features)
    y.append(label)    
    
X = np.array(X).reshape(-1, IMG_SIZE, IMG_SIZE, 3)
X = X/255.0
Y= np.array(y)

# # -- pickle save
# pickle_out = open("X.pickle","wb")
# pickle.dump(X, pickle_out)
# pickle_out.close()

# pickle_out = open("Y.pickle","wb")
# pickle.dump(Y, pickle_out)
# pickle_out.close()


# # -- pickle load
# pickle_in = open("X.pickle","rb")
# X = pickle.load(pickle_in)
# pickle_in = open("Y.pickle","rb")
# Y = pickle.load(pickle_in)

model = tf.keras.applications.mobilenet.MobileNet()
base_input = model.layers[0].input
base_output = model.layers[-4].output
Flat_layer= layers.Flatten()(base_output)
final_output = layers.Dense(1)(Flat_layer)
final_output = layers.Activation('sigmoid')(final_output)

new_model = keras.Model(inputs = base_input, outputs= final_output)
new_model.compile(loss="binary_crossentropy", optimizer = "adam", metrics = ["accuracy"])
new_model.fit(X,Y, epochs = 1,validation_split = 0.1)
new_model.save('latest_cnntest.h5')

