# Required libraries
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import LSTM
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.linear_model import LogisticRegression
from sklearn import metrics, cross_validation, preprocessing


def model(df):
    df.rename(columns = {'Adj.Close': 'Adj Close', 'X1day_target': '1day_target'}, inplace = True)

    data = {'x_features': df['Adj Close'].pct_change(), 'y_target': df['1day_target']}
    frame = pd.DataFrame(data)

    frame.fillna(0, inplace = True)

    # Using train_test_fit to create subsets for fitting and testing
    x_train, x_test, y_train, y_test = train_test_split(frame['x_features'], frame['y_target'], test_size = 0.3, random_state = 23, stratify = frame['y_target'])

    model = Sequential([
        # Flattening the input Layer into a vector because it is a matrix
        Flatten(),
    
        #First hidden layer 31647 neurons
        Dense(1000, activation = 'relu'), # or tf.nn.relu
    
        #to prevent overfitting
        Dropout(0.20),
    
        Dense(500, activation = 'relu'),
    
        Dropout(0.20),
    
        #output layer with 1 neuron with the sigmoid function to counter for the 2 classes (1 or 0)
        Dense(1, activation = 'sigmoid') # or tf.nn.softmax
        ])

    #Compiler; using the adam optimizer and binary_crossentropy for binary classification
    model.compile(optimizer='adam', loss = 'binary_crossentropy', metrics = ['accuracy'] )

    # Fitting the data; 10 iterations
    model.fit(x_train.values, y_train.values, epochs = 20)

    # Evaluating the test dataset
    eval_array = model.evaluate(x_test, y_test)

    #print("\nTest Data Loss: {}".format(eval_array[0]))
    #print("\nTest Data Accuracy: {:.5}%".format(eval_array[1] * 100))

    seed = 23
    axx = []
    mean_auc = 0.0
    n = 10  # repeat the CV procedure 10 times to get more precise results
    for i in range(n):
        # for each iteration, randomly hold out 20% of the data as CV set
        X_train, X_cv, y_train, y_cv = cross_validation.train_test_split(frame['x_features'], frame['y_target'], test_size=.20, random_state=i*seed)

        # train model and make predictions
        model.fit(X_train, y_train) 
        preds = model.predict_proba(X_cv)
        evals = model.evaluate(X_cv, y_cv)
        axx.append(evals[1] * 100)

        # compute AUC metric for this CV fold
        fpr, tpr, thresholds = metrics.roc_curve(y_cv, preds)
        roc_auc = metrics.auc(fpr, tpr)
        #print("AUC (fold %d/%d): %f"%(i + 1, n, roc_auc))
        mean_auc += roc_auc

    return eval_array, axx


def model2(df):
    df.rename(columns = {'Adj.Close': 'Adj Close', 'X1day_target': '1day_target'}, inplace = True)

    data = {'x_features': df['Adj Close'].pct_change(), 'y_target': df['1day_target']}
    frame = pd.DataFrame(data)

    frame.fillna(0, inplace = True)


    # Using train_test_fit to create subsets for fitting and testing
    x_train, x_test, y_train, y_test = train_test_split(frame['x_features'], frame['y_target'], test_size = 0.3, random_state = 23, stratify = frame['y_target'])

    model2 = Sequential([
    # Flattening the input Layer into a vector because it is a matrix
        Flatten(),
    
        Dense(128, activation = 'relu'),
    
        Dropout(0.20),
    
        #output layer with 1 neuron with the sigmoid function to counter for the 2 classes (1 or 0)
        Dense(1, activation = 'sigmoid') # or tf.nn.softmax
       
        ])

    #Compiler; using the adam optimizer and binary_crossentropy for binary classification
    model2.compile(optimizer='adam', loss = 'binary_crossentropy', metrics = ['accuracy'] )

    # Fitting the data; 10 iterations
    model2.fit(x_train.values, y_train.values, epochs = 20)

    # Evaluating the test dataset
    eval_array2 = model2.evaluate(x_test, y_test)

    #print("\nTest Data Loss: {}".format(eval_array2[0]))
    #print("\nTest Data Accuracy: {:.5}%".format(eval_array2[1] * 100))

    seed = 23
    axx2 = []
    mean_auc = 0.0
    n = 10  # repeat the CV procedure 10 times to get more precise results
    for i in range(n):
        # for each iteration, randomly hold out 20% of the data as CV set
        X_train, X_cv, y_train, y_cv = cross_validation.train_test_split(frame['x_features'], frame['y_target'], test_size=.20, random_state=i*seed)

        # train model and make predictions
        model2.fit(X_train, y_train) 
        preds = model2.predict_proba(X_cv)
        evals = model2.evaluate(X_cv, y_cv)
        axx2.append(evals[1] * 100)

        # compute AUC metric for this CV fold
        fpr, tpr, thresholds = metrics.roc_curve(y_cv, preds)
        roc_auc = metrics.auc(fpr, tpr)
        #print("AUC (fold %d/%d): %f"%(i + 1, n, roc_auc))
        mean_auc += roc_auc

    #print("Mean AUC: %f"%(mean_auc/n))
    #print(axx)

    return eval_array2, axx2
