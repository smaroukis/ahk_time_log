import pandas as pd
import os
from plotly.offline import download_plotlyjs, init_notebook_mode, plot, iplot
from plotly.graph_objs import Scatter, Figure, Layout

USERPROFILE = os.getenv('USERPROFILE')
time_log_fname='/Users/Spencer/Box Sync/Projects/most-recent/smaroukis.github.io/ahk_time_log/Time_log.txt'

columns = ['Start Datetime', 'LogType', 'End Time', 'Duration (m)', 'Duration (s)', 'Cumulative (m)', 'Cumulative (s)']
df = pd.read_csv(time_log_fname, delimiter='\t', header=None, names=columns, index_col=None, parse_dates=True)

# 'Duration (m)' is in %H:%M%:%S format but we need minutes in decimal format so:
df['Duration (m)'] = df['Duration (s)']/60
df['Cumulative (m)'] = df['Cumulative (s)']/60

datetimes = pd.to_datetime(df['Start Datetime'], format='%d.%m.%Y  %H:%M:%S')

report = df.groupby([datetimes.dt.date, 'LogType']).agg({'Duration (m)':['count','sum','mean']})
report.index.names = ['Date', 'LogType'] # Change from "Start Time" since this is day of the month

# report['Duration (m)', 'count-ma'] = moving_average(report['Duration (m)']['count'].values, 5)
# TODO: Update Python script with above line and function definition

# Multi-level index requires Cross Section function
dfsnem = report.xs('SNEM', level='LogType')
dfnemmt = report.xs('NEM-MT', level='LogType')

### Plotly
#init_notebook_mode(connected=True)

snem = Scatter(
    x=dfsnem.index,
    y=dfsnem['Duration (m)']['count'].values,
    name='SNEM count')

nemmt = Scatter(
    x=dfnemmt.index,
    y=dfnemmt['Duration (m)']['count'].values,
    name='NEM-MT count')

data=[snem, nemmt]
layout=Layout(
    title='App Count for SQMX',
    yaxis={'title':'App Count'},
    xaxis={'title':'Date'})

fig=Figure(data=data, layout=layout)

# A) Save as full .html file
#plot(data, filename='graph.html')

# B) Output div to file for serving up in jekyll blog
div_fname = '/Users/Spencer/Box Sync/Projects/most-recent/smaroukis.github.io/_includes/graph_div.html'
div = plot(data, output_type='div')
with open(div_fname, "w+") as f:
    f.write(div)