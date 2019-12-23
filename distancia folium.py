#pibm[['Sigla da Unidade da Federação','Código da Unidade da Federação']].groupby(['Sigla da Unidade da Federação']).count()
#pibm['Sigla da Unidade da Federação'].unique()
lista = ['Nome do Município','Código do Município','Sigla da Unidade da Federação','Código da Unidade da Federação']
uf = []

for estado in pibm['Sigla da Unidade da Federação'].unique():
  ufx = pibm[lista][pibm['Sigla da Unidade da Federação']==estado].groupby(lista).count().reset_index().sort_values("Código do Município").copy()
  uf.append(ufx)

#################################################
#  Agora preciso conseguir as coordenadas       #
#################################################
lista = ['Nome do Município','Código do Município','Sigla da Unidade da Federação','Código da Unidade da Federação']
buscas = pibm[lista].groupby(lista).count().reset_index().sort_values("Código do Município").copy()
buscas.shape


from geopy.distance import distance
from geopy.geocoders import Nominatim
import geopy.geocoders

from geopy.geocoders import Nominatim
import time
from random import uniform
import pandas as pd
from geopy.distance import distance
geopy.geocoders.options.default_timeout = 60
geopy.geocoders.options.default_proxies = {}

coord = pd.DataFrame({'codigo': [], 'cidade': [], 'lat': [] , 'lng': [] })
coord_uf = []
#geolocator = Nominatim(user_agent="foursquare_agent")
conta = 0

for ind in range(0,26):
  for a, b, c in zip(uf[ind]['Nome do Município'],uf[ind]['Código do Município'],uf[ind]['Sigla da Unidade da Federação']):
    geolocator = Nominatim(user_agent="agt{0}".format(b))
    lugar = a + ' , ' + c
    time.sleep(uniform(2,5))
    location = geolocator.geocode(lugar)
    conta = conta + 1
    time.sleep(uniform(2,4))
    try:
      time.sleep(uniform(2,4))
      lat = location.latitude
      lng = location.longitude
    except:
      lat = None
      lng = None
      pass
    coord = coord.append({'codigo': b, 'cidade': a, 'lat': lat, 'lng': lng }, ignore_index=True)
    time.sleep(uniform(2,4))
    coord_uf.append(coord)
    print('Cidade {0} - {1} coordenadas: {2} e {3}'.format(a,c,lat,lng),'interação',conta,'\n')

#coord.to_csv("coord2.csv")

coord.head()

coord = pd.read_stata('/content/gdrive/My Drive/brazil_mun.dta')
novas_colunas = {"x_stub":"lng","y_stub": "lat", "NM_MUNICIP": "cidade","cod_munic": "codigo"}
coord.rename(columns=novas_colunas, inplace=True)

coord.drop(['center','CD_GEOCMU'], axis=1, inplace=True)
coord.dtypes

coord.query('cidade.str.contains("ABADIA")', engine='python')

import math

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

"""### Tudo sobre distâncias geográficas:
https://janakiev.com/blog/gps-points-distance-python/

The latitude of Paris, France is 48.864716, and the longitude is 2.349014. Paris, France is located at France country in the Cities place category with the gps coordinates of 48° 51' 52.9776'' N and 2° 20' 56.4504'' E.
"""

import pandas as pd
distancias = pd.DataFrame({'codigo1': [], 'codigo2': [], 'distancia': [] })

for a, b, c in zip(coord['codigo'],coord['lat'],coord['lng']):
  for x, y, z in zip(coord['codigo'],coord['lat'],coord['lng']):
    coorda = [b,c]
    coordb = [y,z]
    #d = distance(coorda, coordb)
    d = haversine(coorda, coordb)

    distancias = dist.append({'codigo1': a, 'codigo2': x, 'distancia': d }, ignore_index=True)
    print('Cidade 1:',a,'Cidade 2:',x,'distancia:', d,'\n')

dist.head()

"""# New Section"""
