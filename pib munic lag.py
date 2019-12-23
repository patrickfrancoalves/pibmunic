# -*- coding: utf-8 -*-
import requests
import pandas as pd
import numpy as np
import random
from geopy.geocoders import Nominatim
import os

# libraries for displaying images
from IPython.display import Image
from IPython.core.display import HTML
from IPython.display import HTML

# tranforming json file into a pandas dataframe library
from pandas.io.json import json_normalize


pibma = pd.read_excel('PIB MUNICIPIOS 1999 2015.xlsx', sheet_name='PIB_MUNICIPIOS')

pibmx = pibma[['ano', 'cod_munic', 'pib']][pibma['ano']<=2009].copy()

pibmx.rename(columns={"cod_munic": "codigo"}, inplace=True)


pibmx.groupby('ano').count()


pibma[pibma['ano']<=2009].tail()
pibmb = pd.read_excel('PIB MUNICIPIOS 2010 2016.xlsx', sheet_name='PIB_MUNICIPIOS')
pibmb.dtypes


# Veja tutorial sobre lags em um painel de dados
# https://towardsdatascience.com/timeseries-data-munging-lagging-variables-that-are-distributed-across-multiple-groups-86e0a038460c
# Vamos trabalhar só com pib, Código do Município e ano.

for i in range(0,len(pibma.columns)):
    print('Coluna {0} variável: {1}\n'.format(i,pibma.columns[i]))

colunas = [pibmb.columns[0],pibmb.columns[6],pibmb.columns[39]]


colunas
pibmb[['Código do Município','Ano']].groupby('Ano').count()
pibm_reduzido = pibmb[colunas].copy()

pibm_reduzido.shape

novas_colunas = {"Ano":"ano",
                 "Código do Município": "codigo",
                 "Produto Interno Bruto, a preços correntes\n(R$ 1.000)": "pib"}

pibm_reduzido.rename(columns=novas_colunas, inplace=True)

pibm_reduzido.sort_values(by=["codigo","ano"], ascending=True).reset_index(inplace=True)
pibm_reduzido.head()
pibmy = pibm_reduzido.append(pibmx)

pibmy.groupby('ano').count()


#################################################
#  tentativa de usar outro método para os lags  #
#################################################

df = pibmy.set_index(["ano", "codigo"])

pib_list = []

for i in range(0,17):
  pib_list.append(df.unstack().shift(i))
  pib_list[i] = pib_list[i].stack(dropna=True)
  pib_list[i].rename(columns={"pib": "pib_{0}".format(i)}, inplace=True)
  pib_list[i].reset_index(inplace=True)
  pib_list[i] = pib_list[i].loc[pib_list[i]['ano']==2016].dropna().copy()
  pib_list[i].set_index("codigo",inplace=True)
  pib_list[i].drop(columns=["ano"],inplace=True)

pib_list[4].head()

from functools import reduce
df_final = reduce(lambda left,right: pd.merge(left,right,on='codigo'), pib_list)

#pib_lags = pib_list[0].join(pib_list[1]).join(pib_list[2]).join(pib_list[3]).join(pib_list[4]).join(pib_list[5]).join(pib_list[6]).join(pib_list[7]).join(pib_list[8]).join(pib_list[9]).join(pib_list[10]).join(pib_list[11]).join(pib_list[12]).join(pib_list[13]).join(pib_list[14]).join(pib_list[15])

df_final.head(10)

df_final.corr()

df_final.to_csv("pib_lags.csv")
