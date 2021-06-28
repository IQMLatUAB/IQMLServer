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
    image_A = []
    image_B = []


    for i in range(55,105):
 
        img1 = Image.open('./Datasets/Demo_datasets/Brain_GT_demo/GT_MRI_' + str(i) + '.png')
        img1 = img1.resize((192,192))
        img1 = np.array(img1).astype(np.float32)
        img1=img1/255.0
        img1 = np.reshape(img1, [192,192,1])
        img1 = img1[np.newaxis,...]
        if img1 is not None:
            image_A.append(img1)
        img2 = Image.open('./Datasets/Demo_datasets/Brain_In_demo/' + str(i) + '.png')
        img2 = img2.resize((192,192))
        img2 = np.array(img2).astype(np.float32)
        img2=img2/255.0

        img2 = np.reshape(img2, [192,192,1])
        img2 = img2[np.newaxis,...]
        if img2 is not None:
            image_B.append(img2)
            
        
    return image_A,image_B


def batch_generator2(imgs1,imgs2):
  n_imgs = min(len(imgs1), len(imgs2))
  ind = random.sample(range(n_imgs),n_imgs)
  for i in ind:
    yield imgs1[i], imgs2[i]


#load the dataset
ds_Xin, ds_Yout = load_images_and_resize()

def Inference(ds_Xin, ds_Yout):
  img_x = []
  img_y = []
  img_pred = []
  i = 0
  for X, Y in batch_generator2(ds_Xin, ds_Yout):

    
    Y_fake_pred = sess.run([Y_fake],feed_dict={X_real: X})


    y_real = np.reshape(X, [192,192])
    img_y.append(y_real)

    x_real = np.reshape(Y, [192,192])
    img_x.append(x_real)

    y_fake = np.reshape(Y_fake_pred, [192,192])
    img_pred.append(y_fake)
    y_fake_img = Image.fromarray((y_fake*255).astype(np.uint8))
    y_fake_img.save('./Datasets/Demo_datasets/Brain_Out/Pred_' + str(i+55) + '.png')

    i = i+1
    
  return img_x, img_y, img_pred


#Inference Step
img_IN, img_GT, img_pred = Inference(ds_Xin,ds_Yout)

#@title Display the Inference results (random images each run)
fig = plt.figure(figsize=(12, 8))
r = 2
x = random.sample(range(len(img_IN)),len(img_IN))
fig.add_subplot(r,3,1)
plt.imshow(img_IN[x[0]],cmap='gray')
plt.gca().set_title('Inhomogeneity')
fig.add_subplot(r,3,2)
plt.imshow(img_pred[x[0]],cmap='gray')
plt.gca().set_title('Predicted')
fig.add_subplot(r,3,3)
plt.imshow(img_GT[x[0]],cmap='gray')
plt.gca().set_title('Ground Truth')
fig.add_subplot(r,3,4)
plt.imshow(img_IN[x[1]],cmap='gray')
plt.gca().set_title('Inhomogeneity')
fig.add_subplot(r,3,5)
plt.imshow(img_pred[x[1]],cmap='gray')
plt.gca().set_title('Predicted')
fig.add_subplot(r,3,6)
plt.imshow(img_GT[x[1]],cmap='gray')
plt.gca().set_title('Ground Truth')

plt.show()

print('The code finished in successful way!')
