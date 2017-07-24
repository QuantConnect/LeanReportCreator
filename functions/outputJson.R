
#Significant Backtest
significantBacktest = ifelse(diff(year(index(s_price_xts))[c(1,length(s_price_xts))])>= 5,1,0)

#Significant Trading
significantTrading = ifelse(length(orders) >= 100,1,0)

#Diversification
diversified = ifelse(length(symbols) >= 7,1,0)

#EvenlyInvested
evenlyInvested = ifelse(max(unlist(lapply(names(indOrderList),
                                          function(x) max(abs(indOrderList[[x]]$Percentage))))) <= 0.1,1,0)

RollingPortfolioBetaToEquity_SixMonth = NA
RollingPortfolioBetaToEquity_TwelveMonth = NA
RollingSharpeRatio_SixMonth = NA
if(exists("beta_df")){
  RollingPortfolioBetaToEquity_SixMonth = beta_df$Beta6mo
  RollingPortfolioBetaToEquity_TwelveMonth = beta_df$Beta12mo
}
if(exists("sharpe_df")){
  RollingSharpeRatio_SixMonth = sharpe_df$SharpeRatio
}
DailyInfoTable = data.frame(Date = df1$Date,
                            CumulativeReturn = df1$CumRet,
                            DailyReturn = df2$DailyRet,
                            Drawdown = df3$Drawdown,
                            RollingPortfolioBetaToEquity_SixMonth = RollingPortfolioBetaToEquity_SixMonth,
                            RollingPortfolioBetaToEquity_TwelveMonth = RollingPortfolioBetaToEquity_TwelveMonth,
                            RollingSharpeRatio_SixMonth = RollingSharpeRatio_SixMonth
)

MinuteInfoTable = NA
if(!is.na(posi_df_res$Value))
  MinuteInfoTable = data.frame(Time = posi_df_res$Date,
                               NetHoldings = posi_df_res$Value,
                               Leverage = leve_df_res$Value
  )

StrategyStat = data.frame(SignificantBacktest = significantBacktest,
                          SignificantTrading = significantTrading,
                          Diversified = diversified,
                          EvenlyInvested = evenlyInvested)

MonthlyReturnTable = setNames(split(sMonRetTable, seq(nrow(sMonRetTable))), rownames(sMonRetTable))

outputJson = list(StrategyStatistics = StrategyStat,
                  DailyInfoTable = DailyInfoTable,
                  MonthlyReturnTable = MonthlyReturnTable,
                  YearlyReturnTable = df4,
                  CrisisAnalysis = EventChartInfo,
                  DrawdownTable = tableDrawdown,
                  AssetAllocation = pie_df1
)

write(rjson::toJSON(outputJson),paste0(params$dir,"/strategy-statistics.json"))