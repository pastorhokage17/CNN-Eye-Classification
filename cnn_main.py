#from asyncio.proactor_events import constants
from threading import Thread
from helper import *
import dlib
from ear_calculate import *
from cnn import *

detector = dlib.get_frontal_face_detector()  				#dlib's face detector (uses HOG)
predictor = dlib.shape_predictor('facial_landmarks.dat')	#dlib's pretrained model to recognise facial features (uses regression trees)
model = load_model('drowsyv3.hd5')							#Trained model for predicting state of the eyes
setgpio()
BUFFER = 11

def cnn_calculate(image, closed, counter,results):
	image = resize(image, width=500)
	cnn_image=image.copy()
	gray = cv2.cvtColor(cnn_image, cv2.COLOR_BGR2GRAY)				#Gray input for CNN
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
		if eyestate(eye_state_cnn) == "close":
			closed += 1
	if results[1] == None:
		if len(faces) == 1:
			state = "attentive"
		else: #-----------------> apparently when no faces is detected, N/A state
			state = "N/A"		
	else:
		state = results[1]
		
	if state == "innatentive":
		ring()
		
	if counter == BUFFER-1: #if and only if buffer is full, then update state 
		if len(faces) == 0:
			state = "N/A"
		elif closed >= 8:
			closed = 0
			state = "innatentive"
			ring()
		else:
			state = "attentive"
	results[0] = len(faces)
	results[1] = state
	results[2] = closed


cam=cv2.VideoCapture(gstreamer_pipeline(flip_method=6), cv2.CAP_GSTREAMER)
fps = cam.get(cv2.CAP_PROP_FPS)
if cam.isOpened():
	logging.info('Camera On...')
	results = [None]*3
	threads = [None]*2
	try:
		while True:
			results[2] = 0
		# k = 0		#counter knina
			for j in range(BUFFER):
				ret,image = cam.read()
				try:
					if results[1] == None:
						#threads[0] = Thread(target = cnn_calculate, args=(image,closed,j,results))
						cnn_calculate(image,0,j,results)
						message(fps, results[0], results[1], results[2], BUFFER)
						# k += 1			

					else:
						cnn_calculate(image,results[2],j,results)
						message(fps, results[0], results[1], results[2], BUFFER)
						# threads[0] = Thread(target = cnn_calculate, args=(image,results[2],j,results))
						# threads[0].start()
						# threads[1] = Thread(target = message, args=(fps, results[0], results[1], results[2], BUFFER))
						# threads[1].start()
						# for l in range(len(threads)):
						# 	threads[l].join()
				except:
					logging.info('No Image/Faces found.')
	finally:
		cam.release()
		logging.info('Interrupted. Closing Program...')
		time.sleep(0.5)
else:
	logging.info('Camera not found.')
