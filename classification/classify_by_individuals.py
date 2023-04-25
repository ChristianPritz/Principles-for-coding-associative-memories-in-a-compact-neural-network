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
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier



#Plotting functions------------------------------------------------------------

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

scrambleIt = False; # set this value to true to make the scrambled label controls

# these are the xlabels for the graphs. Note that the activity vectors are progessively
# added to the model. Meaning that the third entry is not AWCON alone but the concatenated
# activities of AWA, ASH, and AWCON.         
labelList = ('AWA','ASH','AWCON','AWB','AWCOFF','ASJ','ADL','ASER','ASI','URX','ASK','ASEL','AVA','AVE')

#The folloing tuple is lists the names of the data files. Note that each data file contains the 
#binned and normalized activity vectors. Data is randomly allocated to training
#and testing batches further down in the code. the variable x_T contains activity 
#vectors and the variable y_T the labels.  Note that the last numerical index of each file indicates how many neurons are concatinated. 
#i.e. l1.mat consists of the neural activity of AWA only while l2.mat consists of the activities of AWA and ASH, l3.mat
#consists of AWA, ASH, and AWCON
nrnList = ('l1','l2','l3','l4','l5','l6','l7','l8','l9','l10','l11','l12','l13','l14')


cwd = os.getcwd()
data_path = cwd + '/data_by_individuals/'


#classifier names
names = ["Nearest_Neighbors", "Random_Forest", "Neural_Net"]

#classifier settings 
classifiers = [
    KNeighborsClassifier(9,weights='distance',algorithm = 'ball_tree'),
    RandomForestClassifier(max_depth=20, n_estimators=350, max_features='log2'),
    MLPClassifier(hidden_layer_sizes=(40,30,60),alpha=1, max_iter=2000000)]


# running the classifiction ---------------------------------------------------

df = pd.DataFrame()
df['name'] = names
allScores = np.zeros((len(classifiers),len(nrnList))) 
cVars = np.arange(0,len(nrnList),1)
reps = np.arange(0,10,1)

masterMat = np.zeros((len(reps),len(names),len(nrnList)))
for z in reps:
    print("this is rep number :",z)
    for i, n in zip(nrnList,cVars):
        fName = data_path + i + '.mat'

        fParts = os.path.split(fName)
        mat = scipy.io.loadmat(fName)

        x =  mat['x_T']
        y =  np.ravel(mat['y_T'])
        if scrambleIt :

            np.random.shuffle(y)

        i_T = mat['i_T']
        
        X_train, X_test, Y_train, Y_test = train_test_split(x, y, test_size=0.2)
        X_train.shape, Y_train.shape
        X_test.shape, Y_test.shape
        
        scores = []
        for name, clf in zip(names, classifiers):
            clf.fit(X_train, Y_train)
            #score = clf.score(X_test, Y_test)
            Y_pred = clf.predict(X_test)
            score = f1_score(Y_test,Y_pred,average='macro')
            scores.append(score)
            
        sName = 'score_' + i 
        df[sName] = scores
      

    a = df.to_numpy()
    b = a[:,1:len(nrnList)+1]
    c = b.astype(float)
    masterMat[int(z),:,:] = c

#plotting the results ---------------------------------------------------------

#averating across the crossvalidation trials 
av = np.mean(masterMat,0)
sta = np.std(masterMat,0)

# data structure
plot_results(av,labelList,names,'F1 score')
plot_results(sta,labelList,names,'std of F1 score')

#results
line_plot_results(av,sta,labelList,names,'Classification results')

#save results for processing in matlab 
saveName = fParts[0] + 'OSM-trials.mat'
scipy.io.savemat(saveName, {'means': av, 'vars':sta})
