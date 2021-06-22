#import pandas as pd
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import Flatten
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.models import Sequential, save_model, load_model
from keras.layers.convolutional import Conv2D
from keras.layers.convolutional import MaxPooling2D
from keras import backend as K
from keras.utils import np_utils
#from sklearn.model_selection import train_test_split
import numpy as np
#import matplotlib.pyplot as plt
#import seaborn as sns
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.applications.imagenet_utils import decode_predictions
from keras.preprocessing import image
import image
import os
from PIL import Image
import matplotlib.pyplot as plt
import PIL.ImageOps


# Import the model

model = load_model('./saved_model/')


# Load the images created from the shiny app

imageList = []

path = '../www/pictures_to_predict/'

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



samples_to_predict = np.array(imageList)



# Predict the images


predictions = model.predict(samples_to_predict)

classes = np.argmax(predictions, axis = 1)

output_labels = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']


result = [output_labels[i] for i in classes]

print(result)