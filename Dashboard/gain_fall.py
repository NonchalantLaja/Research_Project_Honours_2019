import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import Counter
import datetime
#from matplotlib import style
#style.use('ggplot')
import math
from sklearn import preprocessing
from sklearn.linear_model import LinearRegression
import warnings
warnings.filterwarnings('ignore')


def gain_fall(df):
    #Gains and falls
    def gain_fall(*args): # *args lets us pass any parameters, any number of arguments which becomes an iterable
        cols = [c for c in args] # passing each column mapping it row wise
        for col in cols:
            if(col > 0):
                return(1)   # GAIN
            if(col < 0):
                return(0)# FALL

    
    df.rename(columns = {'Adj.Close': 'Adj Close'}, inplace = True)

    # .shift shifts up to get the future value old - new divided by
    df['1day_Lag'] = (df['Adj Close'].shift(-1) - df['Adj Close']) / df['Adj Close']

    df['1day_target'] = list(map(gain_fall, *[df['1day_Lag']]))
    df.dropna(inplace = True)


    df['1day_target'] = df['1day_target'].shift(1)
    df['1day_target'].fillna(0, inplace = True)

    # The distribution of the 1day_target mapping
    vals = df['1day_target'].values #.tolist optional 
    str_vals = [str(i) for i in vals]


    return df, Counter(str_vals)

#print('Data spread: ', Counter(str_vals)) # seeing the way in which buys/sell/hold are distributed