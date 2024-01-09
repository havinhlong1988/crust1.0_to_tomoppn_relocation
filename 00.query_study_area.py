#!/usr/bin/env python
# coding: utf-8
'''
find the range of lat - long - dep of 3D model list + station cover area 
'''
import numpy as np
import pandas as pd
import sys, os
import glob
import subprocess
# import pygmt

print("query the study area")

if len(sys.argv[:])!=2:
    print('proper usage:')
    print('python querry_study_area.py [link-to-model]')
    print(sys.argv[:])
    sys.exit()
file = str(sys.argv[1])
# 
data_cor = pd.read_csv(file,skiprows=1,delim_whitespace=True,index_col=None,names=["lat","long"])
# 
stas = pd.read_csv('./input/sta.info',delim_whitespace=True,index_col=None,names=["name","lat","long","evl","net"])
# 
files = glob.glob(f'output/models_gradient/*.dat',recursive = True)
data_dep = pd.read_csv(files[0],delim_whitespace=True,index_col=None,names=["vp","vs","dep"])


# query the horizontal coordinate
latlst = data_cor["lat"].unique()
latlst.sort()
longlst = data_cor["long"].unique()
longlst.sort()
# query the horizontal coordinate for stations
slatlst = stas["lat"].unique()
slatlst.sort()
slonglst = stas["long"].unique()
slonglst.sort()
# query the depth range (that a bit tricky)
deplst=data_dep['dep'].unique()

# 
f = open("00_query_coordinantes.dat","w")
f.write("%3.1f %d %d \n"%(1.,len(longlst),len(latlst)))
f.write("%3.1f %3.1f %d %d %d\n"%(1., 1.,len(longlst),len(latlst),len(deplst)))

for long in longlst:
    f.write("%7.2f "%(long))
f.write("\n")

for lat in latlst:
    f.write("%7.2f "%(lat))
f.write("\n")

for long in longlst:
    f.write("%7.2f "%(long))
f.write("\n")

for lat in latlst:
    f.write("%7.2f "%(lat))
f.write("\n")

for dep in deplst:
    f.write("%7.2f "%(dep))
f.write("\n")

f.close()

if (slatlst[0] < latlst[0]) | (slatlst[-1] > latlst[-1]) | (slonglst[0] < longlst[0]) | (slonglst[-1] > longlst[-1]):
    print(" >>>>>   Some thing was wrong with your setup. The model will not work cuz the stations located outside the model space!!!!")
# fig = pygmt.Figure()
# pygmt.config(FONT_LABEL="13p,Times-Bold,black")
# pygmt.config(FONT_TITLE="13p,Times-Bold,black")
# pygmt.config(FONT_ANNOT_PRIMARY="10p,Times-Bold,black")
# pygmt.config(FONT_ANNOT_SECONDARY="10p,Times-Roman,black")

# #
# title="Model area"
# # 
# fig.basemap(region=[longlst[0],longlst[-1],latlst[0],latlst[-1]],
#                     projection="M5i",
#                     frame=['xafg+l"Longitude (deg)"',
#                            'yafg+l"Latitude (deg)"',
#                            'WSen+glightyellow+t%s' % title,
#                           ],)
# fig.plot(x=data_cor["long"],y=data_cor["lat"],style="x0.05c",pen="0.5p.gray")
# fig.plot(
#     x=stas.long,
#     y=stas.lat,
#     style="t0.12i",
#     fill="darkblue",
#     pen="0.5p,darkblue",
#     no_clip=True
# )
# fig.savefig("00_model_seting_with_stations.png",crop=True, dpi=300, transparent=False) 
# fig.show()
