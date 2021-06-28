import os
import pickle
import numpy as np
import torch
import nibabel
import torch
import torch.nn as nn
import torch.nn.functional as F


def pickling(file,path):
    pickle.dump(file,open(path,'wb'))
def unpickling(path):
    file_return=pickle.load(open(path,'rb'))
    return file_return

def dice_score(pred,gt, ep= 1e-4):
    sh1,sh2,sh2,C = pred.shape
#     print(pred.shape)
#     print(gt.shape)
    score_list = []
    for i in range(C-1):
        num = 2*(np.sum(pred[:,:,:,i]*gt[:,:,:,i])) + ep
        denom = np.sum(pred[:,:,:,i] + gt[:,:,:,i]) + ep
        score = num/denom
        score_list.append(score)
    count = np.sum(np.transpose(gt,axes = (1,0,2,3)).reshape(C,-1),axis = 1)
    return score_list,count

def load_data(path, mgz = False):

    t1_img_nii = nibabel.load(path)
    orig = conform(t1_img_nii, 1)
    nibabel.save(orig, os.path.join('/root/DeepNI', 'orig.mgz'))
    t1_img_nii = nibabel.MGHImage.from_filename('/root/DeepNI/orig.mgz')
    affine_map = t1_img_nii.affine
    t1_img, orientation = orient_correctly(t1_img_nii)
    sh1, sh2, sh3 = t1_img.shape
    
    
    dir1_pad = (256 - sh1)//2
        
    dir2_pad = (256 - sh2)//2
     
    dir3_pad = (256 - sh3)//2
    
        
#     t1_img = np.pad(t1_img,((dir1_pad,dir1_pad + sh1%2),(dir2_pad,dir2_pad + sh2%2),(dir3_pad,dir3_pad + sh3%2)), \
#                     mode = 'constant',constant_values = 0.0)
    return t1_img,orientation, dir1_pad,sh1,dir2_pad,sh2, dir3_pad, sh3, affine_map

def orient_correctly(img_nii):
    orientation = nibabel.io_orientation(img_nii.affine)
    try:
        img_new = nibabel.as_closest_canonical(img_nii, True).get_data().astype(float)
    except:
        img_new = nibabel.as_closest_canonical(img_nii, False).get_data().astype(float)
    img_trans = np.transpose(img_new, (0,2,1))
    img_flip = np.flip(img_trans,0)
    img_flip = np.flip(img_flip,1)
    return img_flip, orientation

def orient_to_ras(image):
    img_flip = np.flip(image,0)
    img_flip = np.flip(img_flip,1)
    if image.ndim > 3:
        img_trans = np.transpose(img_flip,(0,2,1,3))
    else:
        img_trans = np.transpose(img_flip,(0,2,1))
    return img_trans

def back_to_original_4_pred(image,orientation, dir1_pad,sh1, dir2_pad,sh2, dir3_pad,sh3):
    if dir1_pad < 0:
        image = np.pad(image,((-dir1_pad,-dir1_pad- sh1%2),(0,0),(0,0)),mode = 'constant',constant_values = 0.0)
    else:
        image = image[dir1_pad:dir1_pad+sh1,:,:]
        
    if dir2_pad < 0:
        image = np.pad(image,((0,0),(-dir2_pad,-dir2_pad - sh2%2),(0,0)),mode = 'constant',constant_values = 0.0)
    else:
        image = image[:,dir2_pad:dir2_pad+sh2,:]
        
    if dir3_pad < 0:
        image = np.pad(image,((0,0),(0,0),(-dir3_pad,-dir3_pad- sh3%2)),mode = 'constant',constant_values = 0.0)
    else:
        image = image[:,:,dir3_pad:dir3_pad+sh3]
    
#     img_unpadded = image[dir1_pad:dir1_pad+sh1,dir2_pad:dir2_pad+sh2,dir3_pad:dir3_pad+sh3]
    img_ras = orient_to_ras(image)
    img_orig_orient = np.transpose(img_ras, orientation[:,0].astype(int))
    for k,i in enumerate(orientation[:,1]):
        if i == -1.0:
            img_orig_orient = np.flip(img_orig_orient,k)
    
    return img_orig_orient

def back_to_original_4_prob(image,orientation, dir1_pad,sh1, dir2_pad,sh2, dir3_pad,sh3):
    if dir1_pad < 0:
        image = np.pad(image,((-dir1_pad,-dir1_pad- sh1%2),(0,0),(0,0),(0,0)),mode = 'constant',constant_values = 0.0)
    else:
        image = image[dir1_pad:dir1_pad+sh1,:,:,:]
        
    if dir2_pad < 0:
        image = np.pad(image,((0,0),(-dir2_pad,-dir2_pad - sh2%2),(0,0),(0,0)),mode = 'constant',constant_values = 0.0)
    else:
        image = image[:,dir2_pad:dir2_pad+sh2,:,:]
        
    if dir3_pad < 0:
        image = np.pad(image,((0,0),(0,0),(-dir3_pad,-dir3_pad- sh3%2),(0,0)),mode = 'constant',constant_values = 0.0)
    else:
        image = image[:,:,dir3_pad:dir3_pad+sh3,:]
#     img_unpadded = image[dir1_pad:dir1_pad+sh1,dir2_pad:dir2_pad+sh2,dir3_pad:dir3_pad+sh3,:]
    img_ras = orient_to_ras(image)
    transpose_axis = orientation[:,0].astype(int)
    transpose_axis = np.append(transpose_axis, 3)
    img_orig_orient = np.transpose(img_ras, transpose_axis)
    for k,i in enumerate(orientation[:,1]):
        if i == -1.0:
            img_orig_orient = np.flip(img_orig_orient,k)
    
    return img_orig_orient

def create_one_hot_seg(image,num_seg):
    p = F.softmax(image,dim = 1)
    p_maxim = (torch.max(p, dim=1)[1]).cpu().data.numpy()
    img = []
    for seg in range(num_seg):
        masked = np.expand_dims((p_maxim==seg).astype(float),axis = 1)
        img.append(masked)
    return np.concatenate(img,axis = 1)
    
def map_image(img, out_affine, out_shape, ras2ras=np.array([[1.0, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]),
              order=1):
    """
    Function to map image to new voxel space (RAS orientation)
    :param nibabel.MGHImage img: the src 3D image with data and affine set
    :param np.ndarray out_affine: trg image affine
    :param np.ndarray out_shape: the trg shape information
    :param np.ndarray ras2ras: ras2ras an additional maping that should be applied (default=id to just reslice)
    :param int order: order of interpolation (0=nearest,1=linear(default),2=quadratic,3=cubic)
    :return: mapped Image data array
    """
    from scipy.ndimage import affine_transform
    from numpy.linalg import inv

    # compute vox2vox from src to trg
    vox2vox = inv(out_affine) @ ras2ras @ img.affine

    # here we apply the inverse vox2vox (to pull back the src info to the target image)
    new_data = affine_transform(img.get_data(), inv(vox2vox), output_shape=out_shape, order=order)
    return new_data


def getscale(data, dst_min, dst_max, f_low=0.0, f_high=0.999):
    """
    Function to get offset and scale of image intensities to robustly rescale to range dst_min..dst_max.
    Equivalent to how mri_convert conforms images.
    :param np.ndarray data: Image data (intensity values)
    :param float dst_min: future minimal intensity value
    :param float dst_max: future maximal intensity value
    :param f_low: robust cropping at low end (0.0 no cropping)
    :param f_high: robust cropping at higher end (0.999 crop one thousandths of high intensity voxels)
    :return: returns (adjusted) src_min and scale factor
    """
    # get min and max from source
    src_min = np.min(data)
    src_max = np.max(data)

    if src_min < 0.0:
        sys.exit('ERROR: Min value in input is below 0.0!')

    print("Input:    min: " + format(src_min) + "  max: " + format(src_max))

    if f_low == 0.0 and f_high == 1.0:
        return src_min, 1.0

    # compute non-zeros and total vox num
    nz = (np.abs(data) >= 1e-15).sum()
    voxnum = data.shape[0] * data.shape[1] * data.shape[2]

    # compute histogram
    histosize = 1000
    bin_size = (src_max - src_min) / histosize
    hist, bin_edges = np.histogram(data, histosize)

    # compute cummulative sum
    cs = np.concatenate(([0], np.cumsum(hist)))

    # get lower limit
    nth = int(f_low * voxnum)
    idx = np.where(cs < nth)

    if len(idx[0]) > 0:
        idx = idx[0][-1] + 1

    else:
        idx = 0

    src_min = idx * bin_size + src_min

    # print("bin min: "+format(idx)+"  nth: "+format(nth)+"  passed: "+format(cs[idx])+"\n")
    # get upper limit
    nth = voxnum - int((1.0 - f_high) * nz)
    idx = np.where(cs >= nth)

    if len(idx[0]) > 0:
        idx = idx[0][0] - 2

    else:
        print('ERROR: rescale upper bound not found')

    src_max = idx * bin_size + src_min
    # print("bin max: "+format(idx)+"  nth: "+format(nth)+"  passed: "+format(voxnum-cs[idx])+"\n")

    # scale
    if src_min == src_max:
        scale = 1.0

    else:
        scale = (dst_max - dst_min) / (src_max - src_min)

    print("rescale:  min: " + format(src_min) + "  max: " + format(src_max) + "  scale: " + format(scale))

    return src_min, scale


def scalecrop(data, dst_min, dst_max, src_min, scale):
    """
    Function to crop the intensity ranges to specific min and max values
    :param np.ndarray data: Image data (intensity values)
    :param float dst_min: future minimal intensity value
    :param float dst_max: future maximal intensity value
    :param float src_min: minimal value to consider from source (crops below)
    :param float scale: scale value by which source will be shifted
    :return: scaled Image data array
    """
    data_new = dst_min + scale * (data - src_min)

    # clip
    data_new = np.clip(data_new, dst_min, dst_max)
    print("Output:   min: " + format(data_new.min()) + "  max: " + format(data_new.max()))

    return data_new


def rescale(data, dst_min, dst_max, f_low=0.0, f_high=0.999):
    """
    Function to rescale image intensity values (0-255)
    :param np.ndarray data: Image data (intensity values)
    :param float dst_min: future minimal intensity value
    :param float dst_max: future maximal intensity value
    :param f_low: robust cropping at low end (0.0 no cropping)
    :param f_high: robust cropping at higher end (0.999 crop one thousandths of high intensity voxels)
    :return: returns scaled Image data array
    """
    src_min, scale = getscale(data, dst_min, dst_max, f_low, f_high)
    data_new = scalecrop(data, dst_min, dst_max, src_min, scale)
    return data_new


def conform(img, order=1):
    """
    Python version of mri_convert -c, which turns image intensity values into UCHAR, reslices images to standard position, fills up
    slices to standard 256x256x256 format and enforces 1 mm isotropic voxel sizes.
    Difference to mri_convert -c is that we first interpolate (float image), and then rescale to uchar. mri_convert is
    doing it the other way. However, we compute the scale factor from the input to be more similar again
    :param nibabel.MGHImage img: loaded source image
    :param int order: interpolation order (0=nearest,1=linear(default),2=quadratic,3=cubic)
    :return:nibabel.MGHImage new_img: conformed image
    """
    from nibabel.freesurfer.mghformat import MGHHeader

    cwidth = 256
    csize = 1
    h1 = MGHHeader.from_header(img.header)  # may copy some parameters if input was MGH format

    h1.set_data_shape([cwidth, cwidth, cwidth, 1])
    h1.set_zooms([csize, csize, csize])
    h1['Mdc'] = [[-1, 0, 0], [0, 0, -1], [0, 1, 0]]
    h1['fov'] = cwidth
    h1['Pxyz_c'] = img.affine.dot(np.hstack((np.array(img.shape[:3]) / 2.0, [1])))[:3]

    # from_header does not compute Pxyz_c (and probably others) when importing from nii
    # Pxyz is the center of the image in world coords

    # get scale for conversion on original input before mapping to be more similar to mri_convert
    src_min, scale = getscale(img.get_data(), 0, 255)

    mapped_data = map_image(img, h1.get_affine(), h1.get_data_shape(), order=order)
    # print("max: "+format(np.max(mapped_data)))

    if not img.get_data_dtype() == np.dtype(np.uint8):

        if np.max(mapped_data) > 255:
            mapped_data = scalecrop(mapped_data, 0, 255, src_min, scale)

    new_data = np.uint8(np.rint(mapped_data))
    new_img = nibabel.MGHImage(new_data, h1.get_affine(), h1)

    # make sure we store uchar
    new_img.set_data_dtype(np.uint8)

    return new_img

