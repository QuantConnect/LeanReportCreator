#Calculate drawdowns
sDrawdowns = aggregate(s_price_xts,by = index(s_price_xts),FUN = function(x){x[length(x)]})
peak = as.numeric(sDrawdowns[1])
for(i in 1:length(sDrawdowns)){
  if (as.numeric(sDrawdowns[i]) < peak){
    sDrawdowns[i] = as.numeric(sDrawdowns[i])/peak
  }else{
    peak = as.numeric(sDrawdowns[i])
    sDrawdowns[i] = 1
  }
}
#Calculate drawdown table
tableDrawdown = table.Drawdowns(s_dailyRet_xts)
toBeRemoved = which(tableDrawdown$Depth==0)
if(length(toBeRemoved)>0) tableDrawdown = tableDrawdown[-toBeRemoved,]
#Drawdown chart
df3 = data.frame(Date = as.Date(index(sDrawdowns)), Drawdown = as.numeric(sDrawdowns))
df3$Drawdown = (df3$Drawdown-1)*100
tableDrawdown$To[which(is.na(tableDrawdown$To))] = max(df3$Date)
print(ggplot(df3,aes(Date,Drawdown)) +
    annotate("rect",xmin=tableDrawdown$From[1],xmax=tableDrawdown$To[1],ymin=-Inf,ymax=0,fill="#FFCCCCCC")+
    annotate("rect",xmin=tableDrawdown$From[2],xmax=tableDrawdown$To[2],ymin=-Inf,ymax=0,fill="#FFE5CCCC")+
    annotate("rect",xmin=tableDrawdown$From[3],xmax=tableDrawdown$To[3],ymin=-Inf,ymax=0,fill="#FFFFCCCC")+
    annotate("rect",xmin=tableDrawdown$From[4],xmax=tableDrawdown$To[4],ymin=-Inf,ymax=0,fill="#E5FFCCCC")+
    annotate("rect",xmin=tableDrawdown$From[5],xmax=tableDrawdown$To[5],ymin=-Inf,ymax=0,fill="#CCFFCCCC")+
    geom_area(fill="grey",color = "grey") +
    geom_hline(yintercept = 0,size = 1) + 
    annotate("segment",x=tableDrawdown$Trough[1],xend=tableDrawdown$Trough[1],y=-Inf,yend=0,linetype = 2)+
    annotate("text",x=tableDrawdown$Trough[1],y = 0.85*min(df3$Drawdown),label = "1st Worst",angle = 90)+
    annotate("segment",x=tableDrawdown$Trough[2],xend=tableDrawdown$Trough[2],y=-Inf,yend=0,linetype = 2)+
    annotate("text",x=tableDrawdown$Trough[2],y = 0.85*min(df3$Drawdown),label = "2nd Worst",angle = 90)+
    annotate("segment",x=tableDrawdown$Trough[3],xend=tableDrawdown$Trough[3],y=-Inf,yend=0,linetype = 2)+
    annotate("text",x=tableDrawdown$Trough[3],y = 0.85*min(df3$Drawdown),label = "3rd Worst",angle = 90)+
    annotate("segment",x=tableDrawdown$Trough[4],xend=tableDrawdown$Trough[4],y=-Inf,yend=0,linetype = 2)+
    annotate("text",x=tableDrawdown$Trough[4],y = 0.85*min(df3$Drawdown),label = "4th Worst",angle = 90)+
    annotate("segment",x=tableDrawdown$Trough[5],xend=tableDrawdown$Trough[5],y=-Inf,yend=0,linetype = 2)+
    annotate("text",x=tableDrawdown$Trough[5],y = 0.85*min(df3$Drawdown),label = "5th Worst",angle = 90)+
    labs(y= "Drawdown(%)") +
    labs(color="Legend") +
    scale_x_date(labels = date_format("%b %Y"))+
    theme(legend.position = "none") +
    theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
          axis.text = element_text(size=10,family = "Open Sans Condensed"),
          axis.title.x=element_blank())+
    theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
    theme(panel.grid.major = element_line(colour = "grey")))