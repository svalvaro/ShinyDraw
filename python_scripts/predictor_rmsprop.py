from tensorflow.keras.models import load_model
import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.preprocessing.image import img_to_array
from keras.preprocessing import image
import image
import os
from PIL import Image
import matplotlib.pyplot as plt
import PIL.ImageOps
import warnings
import logging 


# Supress messages

warnings.filterwarnings('ignore')

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # FATAL
logging.getLogger('tensorflow').setLevel(logging.FATAL)


# Import the trained model

model = load_model('../ShinyDraw/python_scripts/model_rmsprop/')
    

# Load the images created from the shiny app and 
# transform them into grey and 28 x 28 pixels

imageList = []

path = '../ShinyDraw/www/pictures_to_predict/'

size = 28,28

for file in os.listdir(path):
    f_img = path + file
    img = Image.open(f_img)
    
    img = img.convert('L')
    img = PIL.ImageOps.invert(img)
    
    
    img.thumbnail(size, Image.ANTIALIAS)
    
    
    img = img_to_array(img).astype('float32')

    img = img / 255
    
    
    imageList.append(img)


# put the samples into an array

samples_to_predict = np.array(imageList)



# Predict the images


predictions = model.predict(samples_to_predict)

classes = np.argmax(predictions, axis = 1)

output_labels = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']


result = [output_labels[i] for i in classes]
