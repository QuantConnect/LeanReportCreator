# LeanReportCreator
Create beautiful HTML/PDF reports for sharing your LEAN backtest and live trading results.

## Instruction on installing and running the program

Dear users, please refer to the following instructions to generate your strategy report!

### 1. Install R and R libraries.

For Linux users, you can execute the bash file "install.sh" to establish R environment directly. 

For Windows users, you are recommended to install Rstudio and finish the same environment configuration manually.

After R is installed, you can execute "install.R" file by the command "Rscript install.R" to install all the necessary R libraries.

### 2. Prepare input files

(1) The first input file is the .json file which you can download once you finish your backtesting. You could put this file into a convenient directory, such as ./json/sample.json.

(2) Then please replace the files "Profile.txt", "Profile.png", "Description.txt" with your own files, but do not change their names.

### 3. Generate report

Use the following command to generate your strategy report:

If you want to generate a backtesting report, you should use this command.

"Rscript Backtest.R ./json/sample.json Backtest.html ./"

If you want to generate a live trading report, you should use this command.

"Rscript Live.R ./json/sample.json Live.html ./"

Note: 

(1) The first parameter "Backtest.R" (or "Live.R") is the file we are going to execute, other function files are called inside this file.

(2) The second parameter "./json/sample.json" is your json file.

(3) The third parameter "Backtest.html" (or "Live.html") is the name of an informal version of html output.

(4) The fourth parameter "./" is the output directory.

### 4. Get the outputs

(1) Report.R

(2) all the individual images in the directory "images"

(3) strategy-statistics.json

## Explaination on the meaning of the charts

Here I am going to give you a detailed explaination on the meaning of each chart.

### 1. Cumulative Return

![GitHub Logo](/images/cumulative-return.png)
This chart shows the cumulative returns for both your strategy (in orange) and the benchmark (in grey).

The backtest version of this chart is calculated based on daily data. If the original price series in json file is not daily, we will first convert them into daily data.

The live version of this chart is calculated based on miniute data. Icons on the chart will show when the live trading started, stopped, or had runtime errors.

### 2. Daily Return

![GitHub Logo](/images/daily-returns.png)
This chart shows the daily returns for your strategy.

When the return is positive, a orange bar will show above the horizontal line; when the return is negative, a grey bar will show below the horizontal line.

### 3. Top 5 Drawdown Periods

![GitHub Logo](/images/drawdowns.png)
This chart shows the drawdown of each day.

A certain day's drawdown is defined as the percentage of loss compared to the maximum value prior to this day. The drawdowns are calculated based on daily data.

By this defination, we can infer that when cerntain day's value is the maximum so far, its drawdown is 0.

The top 5 drawdown periods are marked in the chart with different colors.

### 4. Monthly Returns

![GitHub Logo](/images/monthly-returns.png)
This chart shows the return of each month.

We convert original price series into monthly series, and calculate the returns of each month. 

The green color indicates positive return, the red color indicates negative return, and the greater the loss is, the darker the color is; the yellow color means the gain or loss is rather small; the white color means the month is not included in the backtest period.

The values in the cells are in percentage.

### 5. Annual Returns

![GitHub Logo](/images/annual-returns.png)
This chart shows the return of each year.

We calculate the total return within each year, shown by the blue bars. The red dotted line represents the average of the annual returns.

One thing needs mentioning: if the backtest covers less than 12 month of a certain year, then the value in the chart is the actual return which is not annualized.

### 5. Distribution of Monthly Returns

![GitHub Logo](/images/distribution-of-monthly-returns.png)
This chart shows the distribution of monthly returns.

The x-axis represents the value of return. The y-axis is the number of months which have a certain return. The red dotted line represents mean value of montly returns.

### 6. Crisis Events

9/11
![GitHub Logo](/images/crisis-9-11.png)
Lehman Brothers
![GitHub Logo](/images/crisis-lehman-brothers.png)
Us Downgrade/European Debt Crisis
![GitHub Logo](/images/crisis-us-downgrade-european-debt-crisis.png)
This group of charts shows the behaviors of both your strategy and the benchmark during a certain historical period. 

We set the value of your strategy the same as the benchmark at the beginning of each crisis event, and the lines represent the cumulative returns of your strategy and benchmark from the beginning of this crisis event.

We won't draw the crisis event charts whose time periods are not covered by your strategy.

### 7. Rolling Portfolio Beta to Equity

![GitHub Logo](/images/rolling-portfolio-beta-to-equity.png)
This chart shows the rolling portfolio beta to the benchmark.

This chart is drawn based on daily data. Every day, we calculate the beta of your portfolio to the benchmark over the past 6 months (grey line) or 12 months (blue line). 

A beta close to 1 means the strategy has a risk exposure similar to the benchmark; a beta higher than 1 means the strategy is riskier than the benchmark; a beta close to 0 means the strategy is "market neutral", which isn't much affected by market situation. Beta could also be negative, under which the strategy has opposite risk expousure to the benchmark.

We won't draw this chart when your backtest period is less than 12 months.

### 8. Rolling Sharpe Ratio

![GitHub Logo](/images/rolling-sharpe-ratio(6-month).png)
This chart shows the rolling sharpe ratio of your strategy.

The rolling sharpe ratio is calculated on daily data, and annualized. Every day, we calculate the sharpe ratio of your portfolio over the past 6 months, and connect the sharpe ratios into a line. The red dotted line represents the mean value of the total sharpe ratios.

We won't draw this chart when your backtest period is less than 6 months.

### 9. Net Holdings

![GitHub Logo](/images/net-holdings.png)
This chart shows the net holdings of your portfolio.

The net holding is the aggregated weight of risky assets in your portfolio. It could be either positive (when your total position is long), negative (when your total position is short) or 0 (when you only hold cash). The net holding changes only if new order is fired.

The chart is drawn based on minute data, which means we aggregate all the risky positions in every minute together.

### 10. Leverage

![GitHub Logo](/images/leverage.png)
This chart shows the leverage of your portfolio.

The value of the leverage is always non-negative. When you only hold cash, the leverage is 0; a leverage smaller than 1 means you either long assets with money less than your portfolio value or short assets with total value less than your portfolio value; a leverage larger than 1 means you either borrow money to buy assets or short assets whose value is larger than your portfolio value. The leverage changes only if new order is fired.

The chart is drawn based on minute data, which means we aggregate all the risky positions in every minute together.

### 11. Asset Allocations

![GitHub Logo](/images/asset-allocation-all.png)
![GitHub Logo](/images/asset-allocation-equity.png)
This group of charts show your asset allocations.

It is a time-weighted average of each class of asset to your portfolio. 

The first chart shows the percentages of all the assets together. The sum of the percentages is 100%. When a certain asset has very small percentage and is too small to be shown in the pie chart, it will be incorporated into "others" class. The value of the percentage could be either positive or negative. 

The rest of the pie charts shows the percentages of some more specific asset classes, for example, stocks, foreign exchanges, etc. We won't draw the chart if your portfolio doesn't include any asset within this class.

### 12. Return Prediction

![GitHub Logo](/images/return-prediction.png)
This chart shows the cumulative returns as well as the future trend prediction.

The future trend is predicted based on Monte Carlo Simulation. The blue line is the 50% percentile of the simualtion results; the area in dark shadow represents the simulation results between 25% and 75%; the area in light shadow represents the simulation results between 5% and 95%.







