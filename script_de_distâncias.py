# -*- coding: utf-8 -*-
import pandas as pd
import time
from random import uniform
import math
import os
#print(os.getcwdb())

os.chdir('C:\\pibmunic')

coord = pd.read_stata('pib/brazil_mun.dta')
novas_colunas = {"x_stub":"lng","y_stub": "lat", "NM_MUNICIP": "cidade","cod_munic": "codigo"}
coord.rename(columns=novas_colunas, inplace=True)

coord.head()

coord.drop(['center','CD_GEOCMU'], axis=1, inplace=True)
coord.dtypes


def haversine(coord1, coord2):
    R = 6372800  # Earth radius in meters
    lat1, lon1 = coord1
    lat2, lon2 = coord2

    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi       = math.radians(lat2 - lat1)
    dlambda    = math.radians(lon2 - lon1)

    a = math.sin(dphi/2)**2 + \
        math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2

    return 2*R*math.atan2(math.sqrt(a), math.sqrt(1 - a))/1000

'regiões metropolitanas'
os.chdir('C:\\pibmunic')
pibm = pd.read_excel ('pib/PIB MUNICIPIOS 2010 2016.xlsx', sheet_name='PIB_MUNICIPIOS')

pibm[['Código do Município','Nome do Município','Região Metropolitana']][~pibm['Região Metropolitana'].isna()].head(5)
#pibm.columns

pibm['RMX'] = pibm['Região Metropolitana'].str[3:25]

pibm[['Código do Município','Nome do Município','Região Metropolitana','RMX']][~pibm['Região Metropolitana'].isna()].head(5)
capital = pibm[['Código do Município','Nome do Município','RMX']][pibm['Nome do Município']==pibm['RMX']]

cap = capital['Código do Município'].unique()

cap.size

#COGN3, BRKM3, ABEV3, CVCB3, BRFS3, BRKM5, UGPA3, CIEL3, UGPA3

pibm[~pibm['Região Metropolitana'].isna()].shape

distancias = pd.DataFrame({'codigo1': [], 'codigo2': [], 'distancia': [] })

i =0
for a, b, c in zip(coord['codigo'],coord['lat'],coord['lng']):
  for x, y, z in zip(coord['codigo'],coord['lat'],coord['lng']):
      if x in cap:
          i=i+1
          coorda = [b,c]
          coordb = [y,z]
          d = haversine(coorda, coordb)
          distancias = distancias.append({'codigo1': a, 'codigo2': x, 'distancia': d }, ignore_index=True)
          print('Distância entre {0} e {1} na interação: {2}'.format(a,x,i))

distancias.to_csv("distancias.csv")
distancias.head()
distancias.groupby('codigo2').count()

distancias.codigo1 = distancias.codigo1.astype(int)
distancias.codigo2 = distancias.codigo2.astype(int)


distancias2 = distancias.pivot(index='codigo1',columns='codigo2',values='distancia')
distancias2.head()
#distancias2.reset_index(inplace=True)

distancias2.columns.name= None
distancias2.columns

distancias2.set_index('codigo1',inplace=True)
distancias2['maximo'] = distancias2.max(axis=1)
distancias2.tail()
#distancias2.drop(columns=['maximo'],inplace=True)

distancias3 = distancias2.div(distancias2['maximo'],axis=0)


distancias3.head()
distancias3.to_csv("distancias3.csv")

del distancias
