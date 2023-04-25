# -*- coding: utf-8 -*-
"""
Created on Sat Apr  1 17:49:10 2023

@author: chris
"""
# imports ---------------------------------------------------------------------
import os
import scipy.io
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.svm import SVC
from matplotlib import pyplot as plt
from sklearn.metrics import f1_score
from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier


#Some plotting functions-------------------------------------------------------


def plot_results(matrix,xlabels,ylabels,titleStr):
    
    fig, ax = plt.subplots()
    fig.figure.set_dpi(300)
    im = plt.imshow(matrix)
    plt.clim(0,1)
    cbar = fig.colorbar(im, ax=ax, extend='both')
    cbar.minorticks_on()
    ax.set_xticks(np.arange(len(xlabels)))
    ax.set_yticks(np.arange(len(ylabels)))

    ax.set_xticklabels(xlabels)
    ax.set_yticklabels(ylabels)
        

    plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
             rotation_mode="anchor")
    fig.tight_layout()
    plt.grid(None) 
    plt.title(titleStr)
    plt.xlabel('Neurons included in the model')
    plt.show()



def line_plot_results(means,errs,xlabels,legend_labels,titleStr):
    
    fig, ax = plt.subplots()
    fig.figure.set_dpi(300)
    x = np.arange(0,means.shape[1],1)
 
    
    for i in range(means.shape[0]):
        ax.errorbar(x, means[i,:], yerr=errs[i,:], fmt='-o',label='Inline label')
    
    ax.legend(legend_labels)
    ax.set_xticks(np.arange(len(xlabels)))
    ax.set_yticks(np.arange(0,1,0.1))

    ax.set_xticklabels(xlabels)

    plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
             rotation_mode="anchor")
    fig.tight_layout()
    plt.title(titleStr)
    plt.xlabel('Neurons included in the model')
    plt.ylabel('F1 score')
    plt.show()



#Variables---------------------------------------------------------------------


scrambleIt = False; # If this is set to True, the scrambled lable control is performed 

    

  
# these are the xlabels for the graphs. Note that the activity vectors are progessively
# added to the model. Meaning that the third entry is not AWCON alone but the concatenated
# activities of AWA, ASH, and AWCON.             
labelList = ('AWA','ASH','AWCON','AWB','AWCOFF','ASJ','ADL','ASER','ASI','URX','ASK','ASEL','AVA','AVE')
nrnNums = ('1','2','3','4','5','6','7','8','9','10','11','12','13','14')  


# the following tuples list 10 independent splits within the individuals saved as matfiles. the 6 odor exchange trials each animals were randomly allocated to 
# a training batch and a test batch. activity vectors within both the training and the test batch are then averaged to obtain a mean activity vector per animal
#The variable x_T contains activity vectors and the variable y_T the labels for training; the variables x_V and y_V contain
# activities and labels for testing, respectively..  Note that the last numerical index of each file indicates how many neurons are concatinated. 
#i.e. inds1t-1.mat consists of the neural activity of AWA only while inds1t-2.mat consists of the activities of AWA and ASH, inds1t-3.mat
#consists of AWA, ASH, and AWCON. All activities are binned (20 Kernel frame) and normalized
nrnList1 = ('inds1t-1','inds1t-2','inds1t-3','inds1t-4','inds1t-5','inds1t-6','inds1t-7','inds1t-8','inds1t-9','inds1t-10','inds1t-11','inds1t-12','inds1t-13','inds1t-14');
nrnList2 = ('inds2t-1','inds2t-2','inds2t-3','inds2t-4','inds2t-5','inds2t-6','inds2t-7','inds2t-8','inds2t-9','inds2t-10','inds2t-11','inds2t-12','inds2t-13','inds2t-14');
nrnList3 = ('inds3t-1','inds3t-2','inds3t-3','inds3t-4','inds3t-5','inds3t-6','inds3t-7','inds3t-8','inds3t-9','inds3t-10','inds3t-11','inds3t-12','inds3t-13','inds3t-14');
nrnList4 = ('inds4t-1','inds4t-2','inds4t-3','inds4t-4','inds4t-5','inds4t-6','inds4t-7','inds4t-8','inds4t-9','inds4t-10','inds4t-11','inds4t-12','inds4t-13','inds4t-14');
nrnList5 = ('inds5t-1','inds5t-2','inds5t-3','inds5t-4','inds5t-5','inds5t-6','inds5t-7','inds5t-8','inds5t-9','inds5t-10','inds5t-11','inds5t-12','inds5t-13','inds5t-14');
nrnList6 = ('inds6t-1','inds6t-2','inds6t-3','inds6t-4','inds6t-5','inds6t-6','inds6t-7','inds6t-8','inds6t-9','inds6t-10','inds6t-11','inds6t-12','inds6t-13','inds6t-14');
nrnList7 = ('inds7t-1','inds7t-2','inds7t-3','inds7t-4','inds7t-5','inds7t-6','inds7t-7','inds7t-8','inds7t-9','inds7t-10','inds7t-11','inds7t-12','inds7t-13','inds7t-14');
nrnList8 = ('inds8t-1','inds8t-2','inds8t-3','inds8t-4','inds8t-5','inds8t-6','inds8t-7','inds8t-8','inds8t-9','inds8t-10','inds8t-11','inds8t-12','inds8t-13','inds8t-14');
nrnList9 = ('inds9t-1','inds9t-2','inds9t-3','inds9t-4','inds9t-5','inds9t-6','inds9t-7','inds9t-8','inds9t-9','inds9t-10','inds9t-11','inds9t-12','inds9t-13','inds9t-14');
nrnList10 = ('inds10t-1','inds10t-2','inds10t-3','inds10t-4','inds10t-5','inds10t-6','inds10t-7','inds10t-8','inds10t-9','inds10t-10','inds10t-11','inds10t-12','inds10t-13','inds10t-14');
lists = (nrnList1,nrnList2,nrnList3,nrnList4,nrnList5,nrnList6,nrnList7,nrnList8,nrnList9,nrnList10)



cwd = os.getcwd()
data_path = cwd + '/data_within_individuals/'

#names of the classifiers
names = ["Nearest_Neighbors", "Random_Forest", "Neural_Net"]
df = pd.DataFrame()
df['name'] = names

#classifier settings  
classifiers = [
    KNeighborsClassifier(2,weights='distance'),
    RandomForestClassifier(max_depth=10, n_estimators=500, max_features='log2'),
    MLPClassifier(hidden_layer_sizes=(50,100),alpha=1, max_iter=2000000)]


#running the classifiction  ---------------------------------------------------
# note that the allocation in the training and validation data was already done
# in matlab, hence the 10 different input nrnLists for 10 independent allocations 

allScores = np.zeros((len(classifiers),len(nrnList1))) 
cVars = np.arange(0,len(nrnList1),1)

#number of repetitions in crossvalidation 
reps = np.arange(0,10,1)
masterMat = np.zeros((len(lists),len(names),len(nrnList1)))

#bOld = np.zeros((4,12))
total_num = len(lists)*len(nrnList1)
counter = 0
for z,nrnList in zip(reps,lists): 
    for i, n,nName in zip(nrnList,cVars,nrnNums):
        fName = i + '.mat'
        print('percent done: ',counter/total_num*100, '%'  )
        print('--------------------------------------------------------------')
        fParts = os.path.split(fName)
        fName = data_path + i + '.mat'
        mat = scipy.io.loadmat(fName)
        X_train = mat['x_T']
        Y_train = np.ravel(mat['y_T'])
        if scrambleIt :

            np.random.shuffle(Y_train)
        
        X_test = mat['x_V']
        Y_test = np.ravel(mat['y_V'])
        if scrambleIt :

            np.random.shuffle(Y_test)
        
        scores = []
        for name, clf in zip(names, classifiers):
            
            clf.fit(X_train, Y_train)
            #score = clf.score(X_test, Y_test)
            Y_pred = clf.predict(X_test)
            score = f1_score(Y_test,Y_pred,average='macro')
            scores.append(score)
            
        sName = 'score_' + nName 
        df[sName] = scores
        counter += 1
  
    a = df.to_numpy()
    b = a[:,1:len(nrnList)+1]
    c = b.astype(float)
    masterMat[int(z),:,:] = c        



#plotting the results----------------------------------------------------------
#averating across the crossvalidation trials 
av = np.mean(masterMat,0)
sta = np.std(masterMat,0)
# see the data structure
plot_results(av,labelList,names,'F1 score')
plot_results(sta,labelList,names,'std of F1 score')
#plotting results
line_plot_results(av,sta,labelList,names,'Classification results')


saveName = fParts[0] + 'OSM-individuals.mat'
scipy.io.savemat(saveName, {'means': av, 'vars':sta})