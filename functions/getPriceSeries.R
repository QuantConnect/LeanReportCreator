#Read info from json file
file = jsonlite::fromJSON(params$file)

#strategy
s = file$Charts$`Strategy Equity`$Series$Equity$Values
#benchmark
b = file$Charts$Benchmark$Series$Benchmark$Values

#Convert numeric date to "readable" format
s$x = as.POSIXct(s$x,origin = "1970-01-01")
b$x = as.POSIXct(b$x,origin = "1970-01-01")

#Convert data to xts format
s_price_xts = xts(s[,-1],order.by = s[,1])
index(s_price_xts) = as.Date(index(s_price_xts))
b_price_xts = xts(b[,-1],order.by = b[,1])
index(b_price_xts) = as.Date(index(b_price_xts))

#Calculate daily returns
s_dailyRet_xts = dailyReturn(s_price_xts)
s_dailyRet_xts[which(is.na(s_dailyRet_xts)|is.infinite(s_dailyRet_xts)|is.nan(s_dailyRet_xts))] = 0
b_dailyRet_xts = dailyReturn(b_price_xts)
b_dailyRet_xts[which(is.na(b_dailyRet_xts)|is.infinite(b_dailyRet_xts)|is.nan(b_dailyRet_xts))] = 0

#Adjust benchmark data to match strategy data
tmp = which(!index(b_dailyRet_xts) %in% index(s_dailyRet_xts))
if(length(tmp)>0) b_dailyRet_xts = b_dailyRet_xts[-tmp]
tmp = s_dailyRet_xts[which(!index(s_dailyRet_xts) %in% index(b_dailyRet_xts))]
if(length(tmp)>0) tmp[1:length(tmp)] = NA
b_dailyRet_xts = c(b_dailyRet_xts,tmp)

#Calculate cumulative returns
b_CumRet_xts = cumprod(1+b_dailyRet_xts)-1
s_CumRet_xts = cumprod(1+s_dailyRet_xts)-1
b_CumRet_df = data.frame(Date = as.Date(index(b_CumRet_xts)), CumRet = as.numeric(b_CumRet_xts))
s_CumRet_df = data.frame(Date = as.Date(index(s_CumRet_xts)), CumRet = as.numeric(s_CumRet_xts))
bs_CumRet_df = merge(b_CumRet_df,s_CumRet_df,by="Date")

#Put b and s in one dataframe
index(b_dailyRet_xts) = as.Date(index(b_dailyRet_xts))
index(s_dailyRet_xts) = as.Date(index(s_dailyRet_xts))
bs_dailyRet_xts = cbind(s_dailyRet_xts,b_dailyRet_xts)