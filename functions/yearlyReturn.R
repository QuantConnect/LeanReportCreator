sYearRet = periodReturn(s_price_xts,period = "yearly")*100
df4 = data.frame(Year = index(sYearRet), Returns = round(as.numeric(sYearRet),4))
df4$Year = ceiling(decimal_date(index(sYearRet))-1)
df4[1:nrow(df4),] = df4[nrow(df4):1,]
df4_1 = df4
df4_1$Returns = 0
df4_2 = df4
df4_2$Returns = mean(df4$Returns)
print(ggplot(df4, aes(x = Year,y = Returns)) +
    geom_bar(fill = "#428BCA",stat="identity",width = 0.5) + 
    geom_line(data = df4_1,aes(x = Year,y = Returns),colour = 'black')+
    geom_line(data = df4_2,aes(x = Year,y = Returns,colour = 'mean'),linetype="dashed")+
    scale_color_manual(values = c(mean = "red"))+
    scale_x_continuous(breaks = seq(min(df4$Year),max(df4$Year),by = 1))+
    # geom_text(aes(label=Returns), vjust=0.5, colour="black",size = 5) +
    coord_flip() +
    labs(y= "Returns(%)") +
    theme(legend.title=element_blank(),
          legend.position = c(0.15,0.90),
          plot.margin = unit(c(1,1,0.5,0), "cm"),
          axis.title=element_text(size=16,face="bold",family = "Open Sans Condensed"), 
          axis.text = element_text(size=14,family = "Open Sans Condensed"),
          legend.background = element_rect(fill="transparent"),
          legend.text = element_text(size=14,family = "Open Sans Condensed")))