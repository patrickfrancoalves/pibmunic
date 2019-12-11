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



distancias = pd.DataFrame({'codigo1': [], 'codigo2': [], 'distancia': [] })

for a, b, c in zip(coord['codigo'],coord['lat'],coord['lng']):
  for x, y, z in zip(coord['codigo'],coord['lat'],coord['lng']):
    coorda = [b,c]
    coordb = [y,z]
    time.sleep(uniform(2, 6))
    d = haversine(coorda, coordb)
    time.sleep(uniform(2, 6))
    distancias = distancias.append({'codigo1': a, 'codigo2': x, 'distancia': d }, ignore_index=True)
    print('Cidade 1:',a,'Cidade 2:',x,'distancia:', d,'\n')

distancias.to_csv("rive/distancias.csv")
