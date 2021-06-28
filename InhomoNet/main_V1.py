# tensorflow_version 1.x
import tensorflow as tf
print(tf.__version__)

import numpy as np
import os
os.environ[ 'MPLCONFIGDIR' ] = '/tmp/'
import matplotlib
import matplotlib.pyplot as plt
import tensorflow.keras.layers as tfl
import tensorflow.contrib.layers as tf_cl
from PIL import Image
import concurrent.futures
import glob
from cv2 import imwrite
import cv2
import random

sess=tf.compat.v1.Session()    
# restore weights
saver = tf.compat.v1.train.import_meta_graph('./inhomonet/model_final.ckpt.meta')


saver.restore(sess,tf.train.latest_checkpoint('./inhomonet'))
 

graph = tf.compat.v1.get_default_graph()
Y_real = graph.get_tensor_by_name('Y:0')
X_real = graph.get_tensor_by_name('X:0')

Y_fake = graph.get_tensor_by_name('G_xy/conv2d_78/Relu:0')

def load_images_and_resize():

    image_B = []


    for i in range(len([name for name in os.listdir('./data') if os.path.isfile(os.path.join('./data', name))])):
        img2 = Image.open('./data/' + str(i+1) + '.png')
        img2 = img2.resize((192,192))
        img2 = np.array(img2).astype(np.float32)
        img2=img2/255.0

        img2 = np.reshape(img2, [192,192,1])
        img2 = img2[np.newaxis,...]
        if img2 is not None:
            image_B.append(img2)
    	
            
    return image_B        



def batch_generator2(imgs2):
  n_imgs = len(imgs2)
  ind = random.sample(range(n_imgs),n_imgs)
  for i in ind:
    yield imgs2[i]


#load the dataset
ds_Yout = load_images_and_resize()

def Inference(ds_Yout):
  img_x = []
  img_pred = []
  i = 0
  for i in range(len(ds_Yout)):

    
    Y_fake_pred = sess.run([Y_fake],feed_dict={X_real: ds_Yout[i]})


    x_real = np.reshape(ds_Yout[i], [192,192])
    img_x.append(x_real)
    x_real_img = Image.fromarray((x_real*255).astype(np.uint8))
    x_real_img.save('./orig/' + str(i+1) + '.png')
    y_fake = np.reshape(Y_fake_pred, [192,192])
    img_pred.append(y_fake)
    y_fake_img = Image.fromarray((y_fake*255).astype(np.uint8))
    y_fake_img.save('./output/' + str(i+1) + '.png')

    i = i+1
    
  return img_x, img_pred


#Inference Step
img_IN, img_pred = Inference(ds_Yout)

#@title Display the Inference results (random images each run)
fig = plt.figure(figsize=(12, 8))
r = 2
x = random.sample(range(len(img_IN)),len(img_IN))
fig.add_subplot(r,2,1)
plt.imshow(img_IN[x[0]],cmap='gray')
plt.gca().set_title('Inhomogeneity')
fig.add_subplot(r,2,2)
plt.imshow(img_pred[x[0]],cmap='gray')
plt.gca().set_title('Predicted')

fig.add_subplot(r,2,3)
plt.imshow(img_IN[x[1]],cmap='gray')
plt.gca().set_title('Inhomogeneity')
fig.add_subplot(r,2,4)
plt.imshow(img_pred[x[1]],cmap='gray')
plt.gca().set_title('Predicted')


plt.show()

print('The code finished in successful way!')
