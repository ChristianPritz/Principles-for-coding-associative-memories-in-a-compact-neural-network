# -*- coding: utf-8 -*-
"""
Created on Tue Nov 22 17:44:04 2022

@author: chris
"""



import os
import numpy as np
from matplotlib import pyplot as plt

Model = 'OLS'
conds = ('NAIVE','STAVT','STAVM','STAPT','STAPM')
kernel = 1
offSet = 45

nrns = ('AWA','ASER','ASG','AWCW','AWB','AWCS','ASEL')


target = 'AIYnr'
regName = 'AIY-'
resultsL = {'NAIVE':0,'STAVT':0,'STAVM':0,'STAPT':0,'STAPM':0}

for i in conds:
    resultsL[i] = doOLS(nrns,i,kernel,offSet,Model,target,regName)
     
    
#display results: 
print(resultsL['NAIVE'].summary())



