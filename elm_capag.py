# -*- coding: utf-8 -*-
import time
import numpy as np
import pandas as pd
import os
import warnings

from elmx import ELMClassifier, ELMRegressor, GenELMClassifier, GenELMRegressor
from random_layer import RandomLayer, MLPRandomLayer, RBFRandomLayer, GRBFRandomLayer

from sklearn.svm import SVR
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import learning_curve
from sklearn.kernel_ridge import KernelRidge
from sklearn.metrics import r2_score
import matplotlib.pyplot as plt

# libraries for displaying images
from IPython.display import Image
from IPython.core.display import HTML
from IPython.display import HTML
warnings.filterwarnings("ignore")
warnings.filterwarnings(action="ignore", category=DeprecationWarning)
warnings.filterwarnings(action="ignore", category=FutureWarning)

#from pandas.io.json import json_normalize
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, MinMaxScaler
#from sklearn.datasets import load_iris, load_digits, load_diabetes, make_regression
#https://github.com/chickenbestlover/Online-Recurrent-Extreme-Learning-Machine

'-----------------------------------------------------------------------------'
'---      Lendo a base CAPAG com as variáveis explicativas relevantes      ---'
'-----------------------------------------------------------------------------'

capag = pd.read_excel('capag_explicativas.xlsx', sheet_name='Sheet1')

capag.rename(columns={"Unnamed: 0": "codmun"}, inplace=True)

capag.columns.values


capag.dtypes
capag.head()


'-----------------------------------------------------------------------------'
'---      Descrição dos dados                                              ---'
'-----------------------------------------------------------------------------'

capag.describe().transpose()

capag[['ind1','ind2','ind3']].quantile([0.001,0.01,0.025,0.05,0.95,0.975,0.99,0.999]).transpose()

for i in ['ind1', 'ind2', 'ind3']:
    capag.loc[ (capag['{0}'.format(i)].isna()), 'miss'] = 1
    capag.loc[~(capag['{0}'.format(i)].isna()), 'miss'] = 0
    print(capag[['codmun', 'miss']].groupby(['miss']).count())


'-----------------------------------------------------------------------------'
'---       https://readthedocs.org/projects/elm/downloads/pdf/latest/      ---'
'-----------------------------------------------------------------------------'

capag[['ind1', 'ind2', 'ind3']].quantile([0.01, 0.99]).transpose()

capag.loc[ capag['ind1'].between(0.0001 ,1.13), 'dind1'] = 1
capag.loc[~capag['ind1'].between(0.0001 ,1.13), 'dind1'] = 0
capag[['codmun', 'dind1']].groupby(['dind1']).count()

capag.loc[ capag['ind2'].between(0.0001 ,2.28), 'dind2'] = 1
capag.loc[~capag['ind2'].between(0.0001 ,2.28), 'dind2'] = 0
capag[['codmun', 'dind2']].groupby(['dind2']).count()


capag.loc[capag['ind3'].between(0.0001, 81.5), 'dind3'] = 1
capag.loc[~capag['ind3'].between(0.0001, 81.5), 'dind3'] = 0
capag[['codmun', 'dind3']].groupby(['dind3']).count()


#capag['ind1s'] = capag['ind1']*capag['dind1']
#capag['ind2s'] = capag['ind2']*capag['dind2']
#capag['ind3s'] = capag['ind3']*capag['dind3']
#capag[['ind1s','ind2s','ind3s','pop']].describe().transpose()


capag.columns[13:31]


for var in capag.columns[13:31]:
    capag['{0}_2'.format(var)] = capag['{0}'.format(var)].pow(2)


from itertools import combinations

for a, b in combinations(capag.columns[13:31], 2):
    capag[f'{a}/{b}'] = capag[a].div(capag[b])

capag.replace([np.inf, -np.inf], 0,inplace=True)
capag.fillna(0,inplace=True)

'-----------------------------------------------------------------------------'
'---          Selecionando variáveis com as maiores correlações            ---'
'-----------------------------------------------------------------------------'
correl = capag.corr().reset_index()[['index','ind1']]

#for c in capag1.columns:
#    print(c)

correl[(correl['ind1']<0.10) & ~(correl['index'].isin(['ind2','ind3']))].head()

selecao = correl[(correl['ind1']<0.10) & ~(correl['index'].isin(['ind2','ind3']))]['index']


'-----------------------------------------------------------------------------'
'---       https://readthedocs.org/projects/elm/downloads/pdf/latest/      ---'
'-----------------------------------------------------------------------------'
capag1 = capag[capag['dind1']==1].copy()

#capag1.drop(['codmun', 'ind2', 'ind3', 'dind1', 'dind2', 'dind3'], inplace=True , axis=1 )
#X = capag1.drop(['ind1'],axis=1)
X = capag1[selecao]

y = capag1[['ind1']]

X = MinMaxScaler().fit_transform(X)
y = MinMaxScaler().fit_transform(y)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.30)

'-----------------------------------------------------------------------------'
'---                   Support Vector Regression                           ---'
'-----------------------------------------------------------------------------'
from sklearn.svm import SVR
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import learning_curve
from sklearn.kernel_ridge import KernelRidge

del metricas
#metricas = ['accuracy', 'average_precision', 'f1', 'precision', 'recall', 'roc_auc']

pram1 = {"C": [600, 700, 800, 900, 1000], "gamma": ['scale', 'auto'], "kernel": ['linear', 'poly', 'rbf', 'sigmoid'],
"coef0": [0.00, 0.10, 0.20,0.30, 0.40, 0.50, 0.60, 0.7], "epsilon":[0.10,0.15,0.20,0.35]}


pram2 = {"alpha": [0.75, 0.80, 0.85], "degree": [1, 2, 3], "coef0": [0.000, 0.001, 0.002, 0.003]}



svr = GridSearchCV(SVR(), param_grid=pram1)
krg = GridSearchCV(KernelRidge(),  param_grid=pram2)

import time
t0 = time.time()
svr.fit(X_train, y_train)
svr_fit = time.time() - t0
print("SVR complexity, bandwidth selected and model fitted in %.3f s" % svr_fit)

t0 = time.time()
krg.fit(X_train, y_train)
krg_fit = time.time() - t0
print("KRR complexity, bandwidth selected and model fitted in %.3f s" % krg_fit)


# Best paramete set
print('Best parameters found:\n', svr.best_params_)
print('R-Square on the train set:', r2_score(y_train, svr.predict(X_train)))
print('R-Square on the test set: ', r2_score(y_test, svr.predict(X_test)))


print('Best parameters found:\n', krg.best_params_)
print('R-Square on the train set:', r2_score(y_train, krg.predict(X_train)))
print('R-Square on the test set: ', r2_score(y_test, krg.predict(X_test)))


'-----------------------------------------------------------------------------'
'---            Multilayer Perceptron Regression                           ---'
'-----------------------------------------------------------------------------'

from sklearn.neural_network import MLPClassifier
from sklearn import preprocessing
from sklearn.model_selection import GridSearchCV
from sklearn.neural_network import MLPRegressor

#[i for i in range(10,110,10)]


mlp = MLPRegressor()
param_grid = {'hidden_layer_sizes': [(150, 200, 150)],
              'activation': ['relu'],
              'solver': ['sgd'],
              'learning_rate': ['constant'],
              'learning_rate_init': [0.003, 0.035, 0.040, 0.045],
              'power_t': [0.62, 0.65, 0.68],
              'alpha': [0.0035, 0.0045, 0.0055, 0.0065],
              'max_iter': [1200],
              'warm_start': [False]}
GridS = GridSearchCV(mlp, param_grid=param_grid, cv=3, verbose=True, pre_dispatch='2*n_jobs', n_jobs=-1)

import time
t0 = time.time()
GridS.fit(X_train, y_train)
mlp_fit = time.time() - t0
print("SVR complexity and bandwidth selected and model fitted in %.3f s"  % mlp_fit)


# Best paramete set
print('Best parameters found:\n', GridS.best_params_)


from sklearn.metrics import r2_score
print('R-Square on the train set:',r2_score(y_train, GridS.predict(X_train)))
print('R-Square on the test set:' ,r2_score(y_test , GridS.predict(X_test)))

# All results
means = GridS.cv_results_['mean_test_score']
stds = GridS.cv_results_['std_test_score']
for mean, std, params in zip(means, stds, GridS.cv_results_['params']):
    print("%0.3f (+/-%0.03f) for %r" % (mean, std * 2, params))





'-------------------------------------------------------------------------'
'---        Exemplo Online Recurrent Extreme Learning Machine          ---'
'-------------------------------------------------------------------------'

#https://github.com/chickenbestlover/Online-Recurrent-Extreme-Learning-Machine


rhl = RBFRandomLayer(n_hidden=250, rbf_width=0.8)
elmr = GenELMRegressor(hidden_layer=rhl)
elmr.fit(X_train, y_train)
print(elmr.score(X_train, y_train), elmr.score(X_test, y_test))
plt.plot(y_test, elmr.predict(X_test))
