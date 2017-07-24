
#Monte Carlo simulation
timeDiff = df1$Date[nrow(df1)]-df1$Date[1]+1
tmp_dailyRet = as.numeric(s_dailyRet_xts)
tmp_n = length(tmp_dailyRet)
tmp = data.frame((cumprod(1+c(tmp_dailyRet,sample(tmp_dailyRet,replace = TRUE)))-1)[(tmp_n+1):(tmp_n*2)])
for(i in 2:1000)
{
  tmp = cbind(tmp,(cumprod(1+c(tmp_dailyRet,sample(tmp_dailyRet,replace = TRUE)))-1)[(tmp_n+1):(tmp_n*2)])
}
colnames(tmp) = 1:1000

tmp_cumRet5 = apply(tmp,1,quantile,0.05)
tmp_cumRet25 = apply(tmp,1,quantile,0.25)
tmp_cumRet50 = apply(tmp,1,quantile,0.50)
tmp_cumRet75 = apply(tmp,1,quantile,0.75)
tmp_cumRet95 = apply(tmp,1,quantile,0.95)

df7 = data.frame(Date = c(df1$Date,df1$Date+timeDiff),
                 CumRet = c(df1$CumRet[1:tmp_n],rep(NA,tmp_n)),
                 PredRet5 = c(rep(NA,tmp_n-1),df1$CumRet[tmp_n],tmp_cumRet5*100),
                 PredRet25 = c(rep(NA,tmp_n-1),df1$CumRet[tmp_n],tmp_cumRet25*100),
                 PredRet50 = c(rep(NA,tmp_n-1),df1$CumRet[tmp_n],tmp_cumRet50*100),
                 PredRet75 = c(rep(NA,tmp_n-1),df1$CumRet[tmp_n],tmp_cumRet75*100),
                 PredRet95 = c(rep(NA,tmp_n-1),df1$CumRet[tmp_n],tmp_cumRet95*100))
df7 = df7[1:ceiling(tmp_n*1.1),]

print(ggplot(df7,aes(Date)) +
    geom_line(aes(y = CumRet ,color="Backtest"),size = 1) +
    geom_ribbon(aes(ymin = PredRet5,ymax = PredRet95),fill="#F5AE2922")+
    geom_ribbon(aes(ymin = PredRet25,ymax = PredRet75),fill="#F5AE2944")+
    geom_line(aes(y = PredRet50 ,color="Prediction"),size = 1) +
    geom_hline(yintercept = 0,size = 1) + 
    labs(y= "Return Prediction(%)") +
    labs(color="Legend") +
    scale_colour_manual("", breaks = c("Prediction","Backtest"),values = c("#F5AE29","#428BCA"))+
    scale_x_date(labels = date_format("%b %Y"))+
    theme(legend.position = c(0.06,0.85)) +
    theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
          axis.text = element_text(size=10,family = "Open Sans Condensed"),
          axis.title.x=element_blank(),
          legend.title = element_text(size=8,family = "Open Sans Condensed"),
          legend.text = element_text(size=8,family = "Open Sans Condensed"),
          legend.background = element_rect(fill = "transparent", colour = "transparent") )+
    theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
    theme(panel.grid.major = element_line(colour = "grey")))
