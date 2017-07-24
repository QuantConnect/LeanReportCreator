
file = jsonlite::fromJSON(params$file)

# b = file$LiveResults$results$Charts$Benchmark$Series$Benchmark$Values
s = file$LiveResults$results$Charts$`Strategy Equity`$Series$Equity$Values
#maybe bug
# b = b[1:(nrow(s)),]
b = s
b$y = 0
b$x = as.POSIXct(b$x,origin = "1970-01-01")
s$x = as.POSIXct(s$x,origin = "1970-01-01")

#benchmark
b_price_xts = xts(b[,-1],order.by = b[,1])
#strategy
s_price_xts = xts(s[,-1],order.by = s[,1])
b_price_xts2 = b_price_xts
s_price_xts2 = s_price_xts
index(s_price_xts) = as.Date(index(s_price_xts))
s_price_xts = s_price_xts[c(diff(index(s_price_xts))!=0,TRUE),]

b_dailyRet_xts = dailyReturn(b_price_xts)
s_dailyRet_xts = dailyReturn(s_price_xts)
b_CumRet_xts = cumprod(1+b_dailyRet_xts)-1
s_CumRet_xts = cumprod(1+s_dailyRet_xts)-1

#not daily really
b_dailyRet_xts2 = diff(b_price_xts2)/b_price_xts2
s_dailyRet_xts2 = diff(s_price_xts2)/s_price_xts2
b_dailyRet_xts2[is.na(b_dailyRet_xts2)] = 0
s_dailyRet_xts2[is.na(s_dailyRet_xts2)] = 0
b_CumRet_xts2 = cumprod(1+b_dailyRet_xts2)-1
s_CumRet_xts2 = cumprod(1+s_dailyRet_xts2)-1
b_CumRet_df2 = data.frame(Date = as.POSIXct(index(b_CumRet_xts2)), CumRet = as.numeric(b_CumRet_xts2))
s_CumRet_df2 = data.frame(Date = as.POSIXct(index(s_CumRet_xts2)), CumRet = as.numeric(s_CumRet_xts2))

b_CumRet_df = data.frame(Date = as.Date(index(b_CumRet_xts)), CumRet = as.numeric(b_CumRet_xts))
s_CumRet_df = data.frame(Date = as.Date(index(s_CumRet_xts)), CumRet = as.numeric(s_CumRet_xts))
bs_CumRet_df = merge(b_CumRet_df,s_CumRet_df,by="Date")

index(b_dailyRet_xts) = as.Date(index(b_dailyRet_xts))
index(s_dailyRet_xts) = as.Date(index(s_dailyRet_xts))
bs_dailyRet_xts = cbind(s_dailyRet_xts,b_dailyRet_xts)

sDrawdowns = s_price_xts
peak = as.numeric(s_price_xts[1])
for(i in 1:length(sDrawdowns)){
  if (as.numeric(sDrawdowns[i]) < peak){
    sDrawdowns[i] = as.numeric(sDrawdowns[i])/peak
  }else{
    peak = as.numeric(sDrawdowns[i])
    sDrawdowns[i] = 1
  }
}
tableDrawdown = table.Drawdowns(s_dailyRet_xts)
toBeRemoved = which(tableDrawdown$Depth==0)
if(length(toBeRemoved)>0) tableDrawdown = tableDrawdown[-toBeRemoved,]