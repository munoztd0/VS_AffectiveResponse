#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 21 13:24:15 2019

@author: evapool

Creates accuracy maps minus chance maps for every subject (H0: accuracy=50%) to 
do a quick second level analysis

last modified by David on 2020

"""
def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

import sys

from mvpa2.suite import *
from pymvpaw import *
import matplotlib.pyplot as plt
from mvpa2.measures.searchlight import sphere_searchlight
import mvpa_utils_pav
from sh import gunzip
from nilearn import image ## was missing this line!


import os
# import utilities
homedir = os.path.expanduser('~/REWOD/')
#add utils to path
sys.path.insert(0, homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
os.chdir(homedir+'CODE/ANALYSIS/fMRI/MVPA/PYmvpa')
import mvpa_utils

# ---------------------------- Script arguments
##subj = '01'
subj = str(sys.argv[1])
#task = 'hedonic'
task = str(sys.argv[2])
##model = 'MVPA-01'
model = str(sys.argv[3])
runs2use = 1 ##??


print 'subject id: ', subj

print 'smell VS no smell MVPA'


# subj = '01'
# runs2use = 1
# model  = 'MVPA-02'
# task= 'hedonic'


#----------------------------- get fds 

#which ds to use and which mask to use
glm_ds_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/output/tstat_all_trials_4D.nii'
#mask_name = homedir+'DERIVATIVES/PREPROC/sub-'+subj+'/ses-second/anat/sub-'+subj+'_ses-second_run-01_T1w_reoriented_brain_mask.nii'
mask_name = homedir+'DERIVATIVES/ANALYSIS/GLM/'+task+'/GLM-01/sub-'+subj+'/output/mask.nii'


#customize how trials should were labeled as classes for classifier
#timing files 1
if model == 'MVPA-01':
    class_dict = {
            'empty' : 0,
            'chocolate' : 1,
            'neutral' : 1,  #watcha
        }
if model == 'MVPA-02':
    class_dict = {
        'empty' : 0,
        'chocolate' : 1,
    }

#use make_targets and class_dict for timing files 1, and use make_targets2 and classdict2 for timing files 2
fds = mvpa_utils.make_targets(subj, glm_ds_file, mask_name, runs2use, class_dict, homedir, model, task)

fds_inv = remove_invariant_features(fds) ##

# ---------------------------- load the hdf5 data 

vector_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell'
scores_per_voxel = h5load(vector_file)

# ---------------------------- substract the chance level

corrected_per_voxel = scores_per_voxel - 0.5

# ---------------------------- save
corrected_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_corrected'

h5save(corrected_file,corrected_per_voxel)
nimg = map2nifti(fds_inv, corrected_per_voxel)
nii_file = corrected_file+'.nii.gz'
nimg.to_filename(nii_file)

# ----------------------------- smooth for the spm t-test analysis
corrected_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_corrected.nii.gz'

smooth_map = image.smooth_img(corrected_file, fwhm=4) ##!was 8
smooth_file = homedir+'DERIVATIVES/ANALYSIS/MVPA/'+task+'/'+model+'/sub-'+subj+'/mvpa/svm_smell_nosmell_corrected_smoothed.nii.gz'
smooth_map.to_filename(smooth_file)
#unzip for spm analysis
gunzip(smooth_file)

print 'end - smell VS no smell MVPA'

