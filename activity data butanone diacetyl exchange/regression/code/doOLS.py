# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
    
import statsmodels.api as sm
from statsmodels.sandbox.regression.predstd import wls_prediction_std
from statsmodels.graphics.tsaplots import plot_acf
import numpy as np
import scipy.io
import sys

def arangeY(fileName,varName,kernel,offSet) :
    # load variables --------------------------------------------------------------
    mat = scipy.io.loadmat(fileName)
    yIn = np.array(mat.get(varName))
    num = yIn.shape[0]
    # re-arange ------------------------------------------------------------------
    dim = yIn.shape
    nanomerLen = 100
    vLen = offSet + kernel
    b = np.arange(0,dim[0],1) #all inputs 
    nanomer = np.repeat(1,nanomerLen,axis=0)
    yOut = np.array([], dtype=np.int64).reshape(0,1)
    #print(b)
    for i in b :
       yL = np.concatenate((nanomer.transpose(),yIn[i,:])) 
       ySeg = yL[-vLen:]
       ySeg2 = ySeg.reshape([vLen,1])
       yOut = np.vstack((yOut,ySeg2))
      
    return yOut, num

def makeDesMatX(fileName,varName,kernel,offSet) :
    
    # load variables --------------------------------------------------------------
    mat = scipy.io.loadmat(fileName)
    xIn = np.array(mat.get(varName))
    
    # re-arange ------------------------------------------------------------------
    dim = xIn.shape
    nanomerLen = 100
    vLen = offSet + kernel
    b = np.arange(0,dim[0],1) #all inputs 
    nanomer = np.repeat(1,nanomerLen,axis=0)
    desMat = np.array([], dtype=np.int64).reshape(0,kernel)
    for i in b :
       #print(i)
       xL = np.concatenate((nanomer.transpose(),xIn[i,:]))
       #yL = np.concatenate((nanomer.transpose(),yIn[i,:])) 
       
       blocX = np.array([], dtype=np.int64).reshape(0,vLen)
       c = np.arange(0,kernel,1)
       
       for j in c :
           segment = xL[len(xL)-vLen-j:len(xL)-j] 
           blocX = np.vstack((segment,blocX)) #transpose here... 
       

       desMat = np.vstack((desMat,blocX.transpose()))
     
    return desMat

def doOLS(NRNS,condition,kernel,offSet,rType,target,regName) :
    #reading all the files-----------------------------------------------------
    #
    #--------------------------------------------------------------------------
    name = target + '-'+ condition + '.mat'
    y,num = arangeY(name,'dxT',kernel,offSet)
    #assemble design matrix
    num = num * (kernel+offSet)
    #print(condition)
    desMat = np.array([]).reshape(num,0)
    for i in NRNS:
        name1 = i + '-' + condition + '.mat'
        dm1 = makeDesMatX(name1,'dxT',kernel,offSet)
        #print(dm1.shape)
        #print(desMat.shape)
        #desMat.reshape(dim[0],0)
        desMat = np.hstack((desMat,dm1))
    
    
    #this adds the constant. 
    desMat = sm.add_constant(desMat)
    
    #1st step - MODEL----------------------------------------------------------
    # This does the OLS/GLS/MLE 
    #--------------------------------------------------------------------------
    print('---------------------------------' + condition + '---------------------------------')
    print('-----------------------------------------------------------------------')
    if rType == 'OLS':
        model = sm.OLS(y,desMat)
        results = model.fit()
    if rType == 'GLS':
        model = sm.GLS(y,desMat)
        results = model.fit()
    if rType == 'GLSAR' :
        model = sm.GLSAR(y, desMat, rho=2)
        for i in range(10):
            results = model.fit()
            rho, sigma = sm.regression.yule_walker(results.resid,order=model.order)
            model = sm.GLSAR(y, desMat, rho)
            prompt = 'sigma is = ' + str(sigma) + ' rho is ' + str(rho)
            
            print(prompt)   
        
    # ACFSTATS(results.resid,condition)
    print(results.summary())
    
    params = results.params
    R2 = results.rsquared
    pred = results.predict()
    pVals = results.pvalues
    conf_int = results.conf_int()
    
    vals = {'desMat':desMat,'R2':R2,'params':params,'y':y,'preds':pred,'pVals':pVals,'conf_int':conf_int}
    fName = regName + condition + '-stats.mat'
    scipy.io.savemat(fName,vals)

    
    return results

if __name__ == '__main__':
    nrns = sys.argv[1]
    cond = sys.argv[2]
    kernel = sys.argv[3]
    offSet = sys.argv[4]
    rType = sys.argv[5]
    target = sys.argv[6]
    regName = sys.argv[7]
    doOLS(nrns,cond,kernel,offSet,rType,target,regName)
