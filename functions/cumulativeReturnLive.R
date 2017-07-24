img1 = readPNG(paste0(params$dir,"/icons/play.png"))
g1 <- rasterGrob(img1, interpolate=TRUE)
img2 = readPNG(paste0(params$dir,"/icons/stop.png"))
g2 <- rasterGrob(img2, interpolate=TRUE)
img3 = readPNG(paste0(params$dir,"/icons/bug.png"))
g3 <- rasterGrob(img3, interpolate=TRUE)

df1 = s_CumRet_df2
df1$CumRet = df1$CumRet*100
df1$CumRetBench = b_CumRet_df2$CumRet*100

df1$CumRetDash = df1$CumRet

halfWidth = (as.numeric(df1$Date[length(df1$Date)]) - as.numeric(df1$Date[1]))/100
halfHeight = (max(df1$CumRet)-min(df1$CumRet))/25

df1$CumRet[which(is.na(s_price_xts2))] = NA

cumRetChart = ggplot(df1,aes(Date)) +
  geom_line(aes(y = CumRetBench, color="Benchmark"),size = 1) +
  geom_line(aes(y = CumRet ,color="Strategy"),size = 1) +
  geom_line(aes(y = CumRetDash ,color="Strategy"),size = 1,linetype = "dotted") +
  geom_hline(yintercept = 0,size = 1) + 
  labs(y= "Cumulative Return(%)") +
  labs(color="Legend") +
  scale_colour_manual("", breaks = c("Benchmark","Strategy"),values = c("grey","#F5AE29"))+
  scale_x_datetime(labels = date_format("%b %Y"))+
  theme(legend.position = c(0.06,0.85)) +
  theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
        axis.text = element_text(size=10,family = "Open Sans Condensed"),
        axis.title.x=element_blank(),
        legend.title = element_text(size=8,family = "Open Sans Condensed"),
        legend.text = element_text(size=8,family = "Open Sans Condensed"),
        legend.background = element_rect(fill = "transparent", colour = "transparent") )+
  theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
  theme(panel.grid.major = element_line(colour = "grey")) 
min_df1CumRet = min(df1$CumRet,na.rm = TRUE)

meta = file$LiveResults$results$Charts$Meta$Series
startSeries = meta$Launched$Values$x
stopSeries = meta$Stopped$Values$x
bugSeries = meta$RuntimeError$Values$x

if(length(startSeries)>0){
  startSeries = as.POSIXct(startSeries,origin = "1970-01-01")
  for(i in 1:length(startSeries)){
    cumRetChart = cumRetChart+annotation_custom(g1, xmin=as.numeric(startSeries[i])-halfWidth, 
                                                xmax=as.numeric(startSeries[i])+halfWidth, 
                                                ymin=-halfHeight+min_df1CumRet, ymax=halfHeight+min_df1CumRet)
  }
}
if(length(stopSeries)>0){
  stopSeries = as.POSIXct(stopSeries,origin = "1970-01-01")
  for(i in 1:length(stopSeries)){
    tmp = s_CumRet_df2$CumRet[which.min(abs(as.numeric(stopSeries[i])-as.numeric(s_CumRet_df2$Date)))]*100
    # if(length(tmp)==0) next
    cumRetChart = cumRetChart+annotation_custom(g2, xmin=as.numeric(stopSeries[i])-halfWidth, 
                                                xmax=as.numeric(stopSeries[i])+halfWidth, 
                                                ymin=-halfHeight+tmp, ymax=halfHeight+tmp)
    tmptmp1 = tmp
  }
}
if(length(bugSeries)>0){
  bugSeries = as.POSIXct(bugSeries,origin = "1970-01-01")
  for(i in 1:length(bugSeries)){
    tmp = s_CumRet_df2$CumRet[which.min(abs(as.numeric(bugSeries[i])-as.numeric(s_CumRet_df2$Date)))]*100
    # if(length(tmp)==0) next
    cumRetChart = cumRetChart+annotation_custom(g3, xmin=as.numeric(bugSeries[i])-halfWidth, 
                                                xmax=as.numeric(bugSeries[i])+halfWidth, 
                                                ymin=-halfHeight+tmp, ymax=halfHeight+tmp)
    tmptmp2 = tmp
  }
}

print(cumRetChart)

#Change df1 back, because it will be used later
df1 = s_CumRet_df
df1$CumRet = df1$CumRet*100
df1$CumRetBench = b_CumRet_df$CumRet*100