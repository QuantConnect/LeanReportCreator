# -*- coding: utf-8 -*-
"""
Created on Mon Apr  2 09:26:20 2018

@author: Li Xiang
"""

import os
import json
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
font = {'family': 'Open Sans Condensed'}
matplotlib.rc('font',**font)
la = matplotlib.font_manager.FontManager()
lu = matplotlib.font_manager.FontProperties(family = "Open Sans Condensed")
from matplotlib.dates import DateFormatter
import pandas as pd
import numpy as np
import matplotlib.colors as mcolors
from datetime import date
from datetime import datetime
from datetime import timedelta
import re
import math
import GenerateHTML

class LeanReportCreator(object):
    
    def __init__(self, jsonfile, outdir = "outputs"):
        # Create output directory
        self.outdir = outdir
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        # Read input file
        with open(jsonfile) as data_file:    
            try:
                data = json.load(data_file)    
            except ValueError:
                data = {"Charts": []}
        self.data = data
        # Parse the input file and make sure the input file is complete
        self.is_drawable = False
        if "Strategy Equity" in data["Charts"] and "Benchmark" in data["Charts"]:
            # Get value series from the input file
            strategySeries = data["Charts"]["Strategy Equity"]["Series"]["Equity"]["Values"] 
            benchmarkSeries = data["Charts"]["Benchmark"]["Series"]["Benchmark"]["Values"] 
            df_strategy = pd.DataFrame(strategySeries).set_index('x')
            df_benchmark = pd.DataFrame(benchmarkSeries).set_index('x')
            df_strategy = df_strategy[df_strategy > 0]
            df_benchmark = df_benchmark[df_benchmark > 0]
            df_strategy = df_strategy[~df_strategy.index.duplicated(keep='first')]
            df_benchmark = df_benchmark[~df_benchmark.index.duplicated(keep='first')]
            df = pd.concat([df_strategy,df_benchmark],axis = 1)
            df.columns = ['Strategy','Benchmark']
            df = df.set_index(pd.to_datetime(df.index, unit='s'))
            self.df = df.fillna(method = 'ffill')
            self.df = df.fillna(method = 'bfill')
            self.initStrategyValue = self.df["Strategy"][0]
            self.initBenchmarkValue = self.df["Benchmark"][0]
            
            # Get order information from the input file
            self.orders = data["Orders"]
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_values = pd.DataFrame()
            df_values["Value"] = [x["Value"] for x in self.orders.values()]
            df_values = df_values.set_index([[datetime.strptime(x["Time"][0:19], '%Y-%m-%dT%H:%M:%S') for x in self.orders.values()]])
            df_this = df_this.join(df_values, how = "outer")
            df_this["Cash"] = -df_this["Value"]
            df_this["Cash"][0] = df_this["Strategy"][0]
            df_this.fillna(0,inplace = True)
            df_this["Cash"] = np.cumsum(df_this["Cash"])
            df_this["Value"] = df_this["Strategy"] - df_this["Cash"]
            self.df_cash = df_this
            
            # Predefine this dataframe which is used to keep cash flow
            self.df_values = pd.DataFrame()

            # True means the essential information is complete
            self.is_drawable = True
    
    def cumulative_return(self, name = "cumulative-return.png", width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            df_this["Strategy"] = (df_this["Strategy"]/self.initStrategyValue-1)*100
            df_this["Benchmark"] = (df_this["Benchmark"]/self.initBenchmarkValue-1)*100
            
            # Drawing charts
            plt.figure()
            ax = df_this.plot(color = ["#F5AE29","grey"])
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("")
            plt.ylabel('Cumulative Return(%)',size = 12,fontweight='bold')
            ax.legend(["Strategy","Benchmark"],prop = {'weight':'bold'},frameon=False, loc = "upper left")
            ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
            plt.axhline(y = 0, color = 'black')
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
        
    def daily_returns(self, name = "daily-returns.png", width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_this = df_this.groupby([df_this.index.date]).apply(lambda x: x.tail(1))
            df_this.index = df_this.index.droplevel(1)
            ret_strategy = np.array([self.initStrategyValue] + df_this["Strategy"].tolist())
            ret_strategy = ret_strategy[1:]/ret_strategy[:-1] - 1
            df_this["Strategy"] = ret_strategy*100
            df_this.index = pd.to_datetime(df_this.index)
            if len(df_this) > 1:
                for i in range(len(df_this)-1):
                    tmp_delta = df_this.index[i+1] - df_this.index[i]
                    for j in range(1, tmp_delta.days):
                        df_this.loc[df_this.index[i] + timedelta(j)] = 0
                    df_this.loc[df_this.index[i] + timedelta(0.99)] = df_this.loc[df_this.index[i]]
                df_this.loc[df_this.index[i+1] + timedelta(0.99)] = df_this.loc[df_this.index[i+1]]  
                df_this.sort_index(inplace = True)
            
            # Drawing charts
            plt.figure()
            ax = df_this.plot(color = "white",  alpha=0)
            ax.fill_between(df_this.index.values,0,df_this['Strategy'], where = 0<df_this['Strategy'], color = "#F5AE29",step = "pre")
            ax.fill_between(df_this.index.values,0,df_this['Strategy'], where = 0>df_this['Strategy'], color = "grey",step = "pre")
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("")
            plt.ylabel('Daily Return(%)',size = 12,fontweight='bold')
            ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
            plt.axhline(y = 0, color = 'black')
            ax.legend_.remove()
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')                
        return True
        
    def drawdown(self,name = "drawdowns.png",width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_this["Drawdown"] = 1
            lastPeak = self.initStrategyValue
            for i in range(len(df_this)):
                if df_this.iloc[i,0] < lastPeak:
                    df_this.iloc[i,1] = df_this.iloc[i,0]/lastPeak
                else:
                    lastPeak = df_this.iloc[i,0]        
            df_this["DDGroup"] = 0
            tmp = 0
            for i in range(1,len(df_this)):
                if df_this.iloc[i,1] != 1:
                    df_this.iloc[i,2] = tmp
                else:
                    continue
                if df_this.iloc[i-1,1] == 1:
                    tmp += 1
                    df_this.iloc[i,2] = tmp       
            df_this["index"] = [i for i in range(len(df_this))]
            tmp_df = pd.DataFrame.from_dict({'MDD':df_this.groupby([df_this["DDGroup"]])['Drawdown'].min(),
                                          'Offset':df_this.groupby([df_this["DDGroup"]])['Drawdown'].apply(lambda x: np.where(x == min(x))[0][0]),
                                          'Start':df_this.groupby([df_this["DDGroup"]])['index'].first(),
                                          'End':df_this.groupby([df_this["DDGroup"]])['index'].last()})
            tmp_df.drop(tmp_df.index[[0]],inplace = True)
            tmp_df.sort_values("MDD",inplace = True)
            df_this = (df_this["Drawdown"] - 1)*100
            
            # Drawing charts
            plt.figure()
            tmp_colors = ["#FFCCCCCC","#FFE5CCCC","#FFFFCCCC","#E5FFCCCC","#CCFFCCCC"]
            tmp_texts = ["1st Worst","2nd Worst","3rd Worst","4th Worst","5th Worst"]
            ax = df_this.plot(color = "grey",zorder = 2)
            ax.fill_between(df_this.index.values,df_this,0, color = "grey",zorder = 3)
            for i in range(min(len(tmp_df),5)):
                tmp_start = df_this.index.values[int(tmp_df.iloc[i]["Start"])]
                tmp_end = df_this.index.values[int(tmp_df.iloc[i]["End"])]
                tmp_mid = df_this.index.values[int(tmp_df.iloc[i]["Offset"])+int(tmp_df.iloc[i]["Start"])]
                plt.axvspan(tmp_start, tmp_end,0,0.95, color = tmp_colors[i],zorder = 1)
                plt.axvline(tmp_mid, 0,0.95, ls = "dashed",color ="black", zorder = 4)
                plt.text(tmp_mid,min(df_this)*0.75,tmp_texts[i], rotation = 90, zorder = 4)
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("")
            plt.ylabel('Drawdown(%)',size = 12,fontweight='bold')
            ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
            plt.axhline(y = 0, color = 'black')
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
   
    def monthly_returns(self, name = "monthly-returns.png",width = 3.5*2, height = 2.5*2):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_this1 = df_this.groupby([df_this.index.year,df_this.index.month]).apply(lambda x: x.head(1))
            df_this2 = df_this.groupby([df_this.index.year,df_this.index.month]).apply(lambda x: x.tail(1))
            df_this1.index = df_this1.index.droplevel(2)
            df_this2.index = df_this2.index.droplevel(2)
            df_this = pd.concat([df_this1,df_this2],axis = 1)
            df_this["Return"] = (df_this.iloc[:,1] / df_this.iloc[:,0] - 1) * 100
            df_this = df_this.iloc[:,2]
            for i in range(1,df_this.index[0][1]):
                df_this.loc[df_this.index[0][0],i] = float("nan")
            df_this.sort_index(0,0,inplace = True)
            df_this = df_this.unstack()
            df_this = df_this.iloc[::-1]
            
            # Define the rules of color change
            def make_colormap(seq):
                seq = [(None,) * 3, 0.0] + list(seq) + [1.0, (None,) * 3]
                cdict = {'red': [], 'green': [], 'blue': []}
                for i, item in enumerate(seq):
                    if isinstance(item, float):
                        r1, g1, b1 = seq[i - 1]
                        r2, g2, b2 = seq[i + 1]
                        cdict['red'].append([item, r1, r2])
                        cdict['green'].append([item, g1, g2])
                        cdict['blue'].append([item, b1, b2])
                return mcolors.LinearSegmentedColormap('CustomMap', cdict)
            c = mcolors.ColorConverter().to_rgb
            c_map = make_colormap([c('#CC0000'),0.1,c('#FF0000'),0.2,c('#FF3333'),
                                     0.3,c('#FF9933'),0.4,c('#FFFF66'),0.5,c('#FFFF99'),
                                           0.6,c('#B2FF66'),0.7,c('#99FF33'),0.8,
                                                 c('#00FF00'),0.9, c('#00CC00')])   
            
            # Drawing charts
            plt.figure()
            ax = plt.imshow(df_this, aspect='auto',cmap=c_map, interpolation='none',vmin = -10, vmax = 10)
            fig = ax.get_figure()
            fig.set_size_inches(3.5*2,2.5*2)
            plt.xlabel('Month',size = 12,fontweight='bold')
            plt.ylabel('Year',size = 12,fontweight='bold')
            plt.yticks(range(len(df_this.index.values)),df_this.index.values)
            plt.xticks(range(12),["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"])
            for (j,i),label in np.ndenumerate(df_this):   
                plt.text(i,j,round(label,1),ha='center',va='center')
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
    
    def annual_returns(self, name = "annual-returns.png",width = 3.5*2, height = 2.5*2):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_this1 = df_this.groupby([df_this.index.year]).apply(lambda x: x.head(1))
            df_this2 = df_this.groupby([df_this.index.year]).apply(lambda x: x.tail(1))
            df_this1.index = df_this1.index.droplevel(1)
            df_this2.index = df_this2.index.droplevel(1)
            df_this = pd.concat([df_this1,df_this2],axis = 1)
            df_this["Return"] = (df_this.iloc[:,1] / df_this.iloc[:,0] - 1) * 100
            df_this = df_this.iloc[:,2]
            
            # Drawing charts
            plt.figure()
            ax = df_this.plot.barh(color = ["#428BCA"])
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("Returns(%)")
            plt.ylabel('Year',size = 12,fontweight='bold')
            plt.axvline(x = 0, color = 'black')
            vline = plt.axvline(x = np.mean(df_this),color = "red", ls = "dashed", label = "mean")
            plt.legend([vline],["mean"],loc='upper left')
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
    
    def monthly_return_distribution(self, name = "distribution-of-monthly-returns.png",width = 3.5*2, height = 2.5*2):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_this1 = df_this.groupby([df_this.index.year,df_this.index.month]).apply(lambda x: x.head(1))
            df_this2 = df_this.groupby([df_this.index.year,df_this.index.month]).apply(lambda x: x.tail(1))
            df_this1.index = df_this1.index.droplevel(2)
            df_this2.index = df_this2.index.droplevel(2)
            df_this = pd.concat([df_this1,df_this2],axis = 1)
            df_this["Return"] = (df_this.iloc[:,1] / df_this.iloc[:,0] - 1) * 100
            df_this["Group"] = np.floor(df_this["Return"])
            tmp_mean = np.mean(df_this["Return"])
            tmp_mean = 11 if tmp_mean > 10 else -11 if tmp_mean < -10 else tmp_mean
            df_this = df_this.iloc[:,[2,3]]
            df_this["Group"] = [x if x<=10 and x>=-10 else float("-Inf") if x<-10 else float("Inf") for x in df_this["Group"]]
            df_this = df_this.groupby([df_this["Group"]]).count()
            tmp_min = int(min(max(min(df_this.index.values),-11),0))
            tmp_max = int(max(min(max(df_this.index.values), 11),0))
            for i in range(max(tmp_min,-10), min(tmp_max,10)+1):
                if i not in df_this.index.values:
                    tmp = df_this.iloc[0].copy()
                    tmp[0] = 0
                    tmp.name = np.float64(i)
                    df_this = df_this.append(tmp,ignore_index = False)
            df_this.sort_index(inplace = True)
            df_this.index = [">10" if x == float("Inf") else "<-10" if x == float("-Inf") else int(x) for x in df_this.index]

            # Drawing charts
            plt.figure()
            ax = df_this.plot.bar(color = ["#F5AE29"])
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("Returns(%)")
            plt.ylabel('Number of Months',size = 12,fontweight='bold')
            plt.axvline(x = -tmp_min, color = 'black')
            vline = plt.axvline(x = tmp_mean-tmp_min,color = "red", ls = "dashed", label = "mean")    
            plt.legend([vline],["mean"],loc='upper left')
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
    
    def crisis_events(self, width = 3.5*2, height = 2.5*2):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df.copy()
            start_date = ["2000-03-10","2001-09-11","2003-01-08","2008-08-01","2010-05-05",
                                  "2007-08-01","2008-03-01","2008-09-01","2009-01-01","2009-03-01",
                                  "2011-08-05","2011-03-16","2012-09-10",
                                  "2014-04-01","2014-10-01","2015-08-15",
                                  "2005-01-01","2007-08-01","2009-04-01","2013-01-01"]
            end_date = ["2000-09-10","2001-10-11","2003-02-07","2008-09-30","2010-05-10",
                                "2007-08-31","2008-03-31","2008-09-30","2009-02-28","2009-05-31",
                                "2011-09-05","2011-04-16","2012-10-10",
                                "2014-04-30","2014-10-31","2015-09-30",
                                "2007-07-31","2009-03-31","2012-12-31",str(date.today())]
            titles = ["Dotcom","9-11","US Housing Bubble 2003","Lehman Brothers","Flash Crash",
                       "Aug07","Mar08","Sept08","2009Q1","2009Q2",
                       "US Downgrade-European Debt Crisis","Fukushima Melt Down 2011","ECB IR Event 2012",
                       "Apr14","Oct14","Fall2015",
                       "Low Volatility Bull Market","GFC Crash","Recovery","New Normal"]
            
            # Drawing charts
            for i in range(len(start_date)):    
                df_this_tmp = df_this[start_date[i]:end_date[i]].copy()
                if not len(df_this_tmp):
                    continue
                df_this_tmp["Strategy"] = (df_this_tmp["Strategy"]/df_this_tmp["Strategy"][0]-1)*100
                df_this_tmp["Benchmark"] = (df_this_tmp["Benchmark"]/df_this_tmp["Benchmark"][0]-1)*100
                plt.figure()
                ax = df_this_tmp.plot(color = ["#F5AE29","grey"])
                fig = ax.get_figure()
                plt.xticks(ha = 'center')
                plt.xlabel("")
                plt.ylabel('Return(%)',size = 12,fontweight='bold')
                ax.legend(["Strategy","Benchmark"],prop = {'weight':'bold'},frameon=False, loc = "upper left")
                ax.xaxis.set_major_formatter(DateFormatter("%Y-%m-%d"))
                plt.axhline(y = 0, color = 'black')
                ax.grid()
                fig.set_size_inches(width, height) 
                fig.savefig(self.outdir + "/crisis-" +re.sub(r' ','-',titles[i].lower())+".png", dpi = 200, bbox_inches='tight')
                plt.cla()
                plt.clf()
                plt.close('all')
        return True
    
    def rolling_beta(self, name = "rolling-portfolio-beta-to-equity.png",width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            days_L = 252
            days_S = 126
            if len(set(self.df.index.date)) > days_L:
                df_this = self.df.copy()
                df_this = df_this.groupby([df_this.index.date]).apply(lambda x: x.tail(1))
                df_this.index = df_this.index.droplevel(1)    
                ret_strategy = np.array([self.initStrategyValue] + df_this["Strategy"].tolist())
                ret_strategy = ret_strategy[1:]/ret_strategy[:-1] - 1
                df_this["Strategy"] = ret_strategy*100
                ret_benchmark = np.array([self.initBenchmarkValue] + df_this["Benchmark"].tolist())
                ret_benchmark = ret_benchmark[1:]/ret_benchmark[:-1] - 1
                df_this["Benchmark"] = ret_benchmark*100                    
                df_this["Beta6mo"] = float("nan")
                df_this["Beta12mo"] = float("nan")    
                for i in range(days_L, len(df_this)):
                    cov_matrix = np.cov(df_this["Strategy"][(i-days_L):i],df_this["Benchmark"][(i-days_L):i])
                    df_this.iloc[[i],[3]] = cov_matrix[0,1]/cov_matrix[1,1]
                for i in range(days_S, len(df_this)):
                    cov_matrix = np.cov(df_this["Strategy"][(i-days_S):i],df_this["Benchmark"][(i-days_S):i])
                    df_this.iloc[[i],[2]] = cov_matrix[0,1]/cov_matrix[1,1]
                df_this.drop(["Benchmark","Strategy"],1,inplace = True)    
                df_this["Empty"] = 0
                
                # Drawing charts
                plt.figure()
                ax = df_this.plot(color = ["#CCCCCC","#428BCA"])
                fig = ax.get_figure()
                plt.xticks(rotation = 0,ha = 'center')
                plt.xlabel("")
                plt.ylabel('Beta',size = 12,fontweight='bold')
                ax.legend(["Beta6mo","Beta12mo"],prop = {'weight':'bold'},frameon=False, loc = "upper left")
                ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
                plt.axhline(y = 0, color = 'black')
                ax.grid()
                fig.set_size_inches(width, height)
                fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
                plt.cla()
                plt.clf()
                plt.close('all')
        return True
    
    def rolling_sharpe(self, name = "rolling-sharpe-ratio(6-month).png",width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            days_S = 126
            days_in_one_year = 252
            if len(set(self.df.index.date)) > days_S:
                df_this = self.df.copy()
                df_this.drop("Benchmark",1,inplace = True)
                df_this = df_this.groupby([df_this.index.date]).apply(lambda x: x.tail(1))
                df_this.index = df_this.index.droplevel(1) 
                ret_strategy = np.array([self.initStrategyValue] + df_this["Strategy"].tolist())
                ret_strategy = ret_strategy[1:]/ret_strategy[:-1] - 1
                df_this["Strategy"] = ret_strategy*100
                df_this["SharpeRatio"] = float("nan")
                for i in range(days_S, len(df_this)):
                    tmp_ret = np.mean(df_this["Strategy"][(i-days_S):i]) * days_in_one_year
                    tmp_std = max(np.std(df_this["Strategy"][(i-days_S):i]) * math.sqrt(days_in_one_year),0.0001)
                    df_this.iloc[[i],[1]] = tmp_ret/tmp_std
                df_this.drop("Strategy",1,inplace = True)    
                df_this["mean"] = np.mean(df_this["SharpeRatio"])
                
                # Drawing charts
                plt.figure()
                ax = df_this["SharpeRatio"].plot(color = "#F5AE29")
                ax = df_this["mean"].plot(color = "red", linestyle = "dashed")          
                fig = ax.get_figure()
                plt.xticks(rotation = 0,ha = 'center')
                plt.xlabel("")
                plt.ylabel('SharpeRatio',size = 12,fontweight='bold')
                plt.legend(["SharpeRatio","mean"],prop = {'weight':'bold'},frameon=False, loc = "upper left")
                ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
                plt.axhline(y = 0, color = 'black')
                ax.grid()
                fig.set_size_inches(width, height)
                fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
                plt.cla()
                plt.clf()
                plt.close('all')
        return True
    
    def net_holdings(self, name = "net-holdings.png",width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df_cash.copy()
            df_this["Strategy"] = df_this["Value"]/df_this["Strategy"]*100
            df_this.drop(df_this.columns[[1,2]],1,inplace = True)
            df_this = df_this.groupby([df_this.index.date,df_this.index.hour,df_this.index.minute], as_index = False).apply(lambda x: x.tail(1))
            df_this.index = df_this.index.droplevel(0)
            
            # Drawing charts
            plt.figure()
            ax = df_this.plot(color = "white",  alpha=0)
            ax.fill_between(df_this.index.values,0,df_this['Strategy'], where = 0<df_this['Strategy'], color = "#F5AE29",step = "pre")
            ax.fill_between(df_this.index.values,0,df_this['Strategy'], where = 0>df_this['Strategy'], color = "grey",step = "pre")
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("")
            plt.ylabel('Net Holdings(%)',size = 12,fontweight='bold')
            ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
            plt.axhline(y = 0, color = 'black')
            ax.legend_.remove()
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
    
    def leverage(self, name = "leverage.png",width = 11.5, height = 2.5):
        if self.is_drawable:
            # Prepare the dataset to be used for drawing charts
            df_this = self.df_cash.copy()
            df_this["Strategy"] = abs(df_this["Value"]/df_this["Strategy"]*100)
            df_this.drop(df_this.columns[[1,2]],1,inplace = True)
            df_this = df_this.groupby([df_this.index.date,df_this.index.hour,df_this.index.minute], as_index = False).apply(lambda x: x.tail(1))
            df_this.index = df_this.index.droplevel(0)
            
            # Drawing charts
            plt.figure()
            ax = df_this.plot(color = "#F5AE29")
            ax.fill_between(df_this.index.values,0,df_this['Strategy'], color = "#F5AE29",step = "pre")
            fig = ax.get_figure()
            plt.xticks(rotation = 0,ha = 'center')
            plt.xlabel("")
            plt.ylabel('Leverage(%)',size = 12,fontweight='bold')
            ax.xaxis.set_major_formatter(DateFormatter("%b %Y"))
            plt.axhline(y = 0, color = 'black')
            ax.legend_.remove()
            ax.grid()
            fig.set_size_inches(width, height)
            fig.savefig(self.outdir + "/" + name, dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
        return True
    
    def asset_allocation(self,width = 3.5*2, height = 2.5*2):
        if self.is_drawable:
            df_this = self.df.copy()
            df_this.drop("Benchmark",1,inplace = True)
            df_values = pd.DataFrame()
            df_values["Value"] = [x["Value"] for x in self.orders.values()]
            df_values["Symbol"] = [x["Symbol"]["Value"] for x in self.orders.values()]
            df_values["Type"] = [x["SecurityType"] for x in self.orders.values()]
            df_values = df_values.set_index([[datetime.strptime(x["Time"][0:19], '%Y-%m-%dT%H:%M:%S') for x in self.orders.values()]])
            timeBegin = df_this.index[0]
            timeEnd = df_this.index[-1]
            timeDuration = (timeEnd - timeBegin).total_seconds()
            df_cash_tmp = df_values.copy()
            df_cash_tmp["Value"] = -df_cash_tmp["Value"]
            df_cash_tmp["Symbol"] = "CASH"
            df_cash_tmp["Type"] = 0
            if timeBegin in df_cash_tmp.index:
                df_cash_tmp.loc[timeBegin-timedelta(seconds = 1)] = [df_this["Strategy"][0], "CASH", 0]
                timeBegin = timeBegin-timedelta(seconds = 1)
            else:
                df_cash_tmp.loc[timeBegin] = [df_this["Strategy"][0], "CASH", 0]
            df_values = df_values.append(df_cash_tmp)
            df_values.sort_index(inplace = True)
            self.df_values = df_values
            SecurityTypeName = ['Cash','Equity', 'Option', 'Commodity', 'Forex', 'Future', 'Cfd', 'Crypto']
            asset_alloc = []
            for SecurityType in range(0,7+1):
                df_tmp = df_values.where(df_values["Type"] == SecurityType).iloc[:,0].copy()
                df_tmp = df_tmp.groupby(df_tmp.index).sum().cumsum()
                list_timestamp = list(df_tmp.index)
                list_timestamp.append(timeEnd)
                timeWeightedValue = sum([(list_timestamp[i+1] - list_timestamp[i]).total_seconds()/timeDuration*df_tmp[i] for i in range(len(df_tmp))])
                asset_alloc.append(timeWeightedValue)
            df_pie = pd.DataFrame()
            df_pie["Value"] = asset_alloc
#            df_pie["Weight"] = [round(x/sum(df_pie["Value"])*100,1) for x in df_pie["Value"]]
            df_pie["AbsWeight"] = [round(abs(x)/sum(abs(df_pie["Value"]))*100,1) for x in df_pie["Value"]]
            df_pie["Labels"] = SecurityTypeName
            df_pie = df_pie.where(df_pie["Value"] != 0).dropna(axis = 0, how = "any")
            if len([x for x in df_pie["AbsWeight"] if x < 5]) > 1:
                df_pie["Labels"] = [ df_pie["Labels"].iloc[i] if df_pie["AbsWeight"].iloc[i] >= 5 else "Others" for i in range(len(df_pie)) ]
            df_pie = df_pie.groupby(by = "Labels").sum()
            df_pie.reset_index(inplace = True)
            df_pie.sort_values(by = ['AbsWeight','Value'],ascending = False, inplace = True)
            df_pie["Labels"] = [str(round(df_pie["AbsWeight"].iloc[i],1)) + "%\n" + df_pie["Labels"].iloc[i] 
                                if df_pie["Value"].iloc[i] >= 0 else "(" + str(round(df_pie["AbsWeight"].iloc[i],1)) + "%)\n" + df_pie["Labels"].iloc[i] 
                                for i in range(len(df_pie))]
            df_pie["Value"] = abs(df_pie["Value"])
            colors = ['#FFE5CC', '#FFCC99', '#FFB266', '#FF9933', '#FF8000', '#CC6600','#994C00','#990000']       
                      
            fig = plt.figure()
            patches, texts, autotexts = plt.pie(df_pie["Value"],  labels=df_pie["Labels"], colors=colors, autopct="", startangle=90, labeldistance = 0.5)
            for x in texts:
                x.set_fontsize(12)
                x.set_fontweight("bold")
            for x in autotexts:
                x.set_fontsize(12)
                x.set_fontweight("bold")
            plt.axis('equal')
            fig.set_size_inches(width, height) 
            fig.savefig(self.outdir + "/asset-allocation-all.png", dpi = 200, bbox_inches='tight')
            plt.cla()
            plt.clf()
            plt.close('all')
            
            for SecurityType in range(1,7+1):
                df_tmp = df_values.where(df_values["Type"] == SecurityType).copy()
                asset_symbols = list(set(df_tmp["Symbol"].dropna(axis = 0)))
                if asset_symbols:
                    asset_alloc = []
                    for sym in asset_symbols:
                        df_tmp2 = df_tmp.where(df_tmp["Symbol"]==sym).iloc[:,0].copy()
                        df_tmp2 = df_tmp2.groupby(df_tmp2.index).sum().cumsum()
                        list_timestamp = list(df_tmp2.index)
                        list_timestamp.append(timeEnd)
                        timeWeightedValue = sum([(list_timestamp[i+1] - list_timestamp[i]).total_seconds()/timeDuration*df_tmp2[i] for i in range(len(df_tmp2))])
                        asset_alloc.append(timeWeightedValue)
                        asset_symbols = [asset_symbols[i] if i < 7 else "Others" for i in range(len(asset_symbols))]
                        if len(asset_alloc) > 7:
                            asset_alloc = list(asset_alloc[0:7] + [sum(asset_alloc[7:])])
                            asset_symbols = asset_symbols[0:8]
                    if not sum([abs(x) for x in asset_alloc]):
                        continue        
                    df_pie = pd.DataFrame()
                    df_pie["Value"] = asset_alloc
#                    df_pie["Weight"] = [round(x/sum(df_pie["Value"])*100,1) for x in df_pie["Value"]]
                    df_pie["AbsWeight"] = [round(abs(x)/sum(abs(df_pie["Value"]))*100,1) for x in df_pie["Value"]]
                    df_pie["Labels"] = asset_symbols
                    if len([x for x in df_pie["AbsWeight"] if x < 5]) > 1:
                        df_pie["Labels"] = [ df_pie["Labels"].iloc[i] if df_pie["AbsWeight"].iloc[i] >= 5 else "Others" for i in range(len(df_pie)) ]
                    df_pie = df_pie.groupby(by = "Labels").sum()
                    df_pie.reset_index(inplace = True)
                    df_pie.sort_values(by = ['AbsWeight','Value'],ascending = False, inplace = True)
                    df_pie["Labels"] = [str(round(df_pie["AbsWeight"].iloc[i],1)) + "%\n" + df_pie["Labels"].iloc[i] 
                                        if df_pie["Value"].iloc[i] >= 0 else "(" + str(round(df_pie["AbsWeight"].iloc[i],1)) + "%)\n" + df_pie["Labels"].iloc[i] 
                                        for i in range(len(df_pie))]
                    df_pie = df_pie.where(df_pie["Value"] != 0).dropna(axis = 0, how = "any")
                    df_pie["Value"] = abs(df_pie["Value"])
                    colors = ['#FFE5CC', '#FFCC99', '#FFB266', '#FF9933', '#FF8000', '#CC6600','#994C00','#990000']
                    
                    fig = plt.figure()
                    patches, texts, autotexts = plt.pie(df_pie["Value"],  labels=df_pie["Labels"], colors=colors, autopct="", startangle=90, labeldistance = 0.6)
                    for x in texts:
                        x.set_fontsize(12)
                        x.set_fontweight("bold")
                    for x in autotexts:
                        x.set_fontsize(12)
                        x.set_fontweight("bold")
                    plt.axis('equal')                   
                    fig.set_size_inches(width, height) 
                    fig.savefig(self.outdir + "/asset-allocation-"+SecurityTypeName[SecurityType].lower()+".png", dpi = 200, bbox_inches='tight')
                    plt.cla()
                    plt.clf()
                    plt.close('all')                    
        return True
    
    def output_json(self, name = "strategy-statistics.json"):
        if self.is_drawable and "TotalPerformance" in self.data:
            SignificantPeriod = 1 if (self.df.index[-1] - self.df.index[0]).days/365 > 5 else 0
            SignificantTrading = 1 if len(self.orders) >= 100 else 0
            Diversified = 1 if len(set(self.df_values["Symbol"])) > 7 else 0
            RiskControl = 1 if self.data["TotalPerformance"] and self.data["TotalPerformance"]["PortfolioStatistics"]["Beta"] < 0.5 else 0
            SecurityTypeName = ['Equity', 'Option', 'Commodity', 'Forex', 'Future', 'Cfd', 'Crypto']
            Markets = [SecurityTypeName[x-1] for x in list(set(self.df_values["Type"])) if x > 0]
            
            CAGR = self.data["TotalPerformance"]["PortfolioStatistics"]["CompoundingAnnualReturn"] if self.data["TotalPerformance"] else 0 
            Drawdown = self.data["TotalPerformance"]["PortfolioStatistics"]["Drawdown"] if self.data["TotalPerformance"] else 0 
            SharpeRatio = self.data["TotalPerformance"]["PortfolioStatistics"]["SharpeRatio"] if self.data["TotalPerformance"] else 0 
            InformationRatio = self.data["TotalPerformance"]["PortfolioStatistics"]["InformationRatio"] if self.data["TotalPerformance"] else 0 
            TradesPerDay = len(self.orders) / max( (self.df.index[-1] - self.df.index[0]).days , 1)
            
            res = {"Key Characteristics": [("Significant Period", SignificantPeriod), 
                                           ("Significant Trading", SignificantTrading),
                                           ("Diversified", Diversified),
                                           ("Risk Control", RiskControl),
                                           ("Markets", Markets)], 
                "Key Statistics":[("CAGR", str(round(CAGR*100,2)) + "%"),
                                  ("Drawdown", str(round(Drawdown*100,2)) + "%"),
                                  ("Sharpe Ratio", round(SharpeRatio,3)),
                                  ("Information Ratio", round(InformationRatio,3)),
                                  ("Trades Per Day", round(TradesPerDay,6))]}
            
        else:
            res = {"Key Characteristics": [("Significant Period", 0), 
                                           ("Significant Trading", 0),
                                           ("Diversified", 0),
                                           ("Risk Control", 0),
                                           ("Markets", [])], 
                "Key Statistics":[("CAGR", 0),
                                  ("Drawdown", 0),
                                  ("Sharpe Ratio", 0),
                                  ("Information Ratio", 0),
                                  ("Trades Per Day", 0)]}
        with open(self.outdir + "/" + name, 'w+') as f:
            json.dump(res, f, ensure_ascii=False)
        return True
    
    def genearte_report(self):
        self.cumulative_return()
        self.daily_returns()
        self.drawdown()
        self.monthly_returns()
        self.annual_returns()
        self.monthly_return_distribution()
        self.crisis_events()
        self.rolling_beta()
        self.rolling_sharpe()
        self.net_holdings()
        self.leverage()
        self.asset_allocation()
        self.output_json()
        GenerateHTML.GenerateHTMLReport(self.outdir)

#Usage
#lrc = LeanReportCreator("./json/sample.json")
#lrc.genearte_report()
