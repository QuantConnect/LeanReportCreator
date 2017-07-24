#Won't draw if backtest period is less than 0.5 year
if(nrow(s_dailyRet_xts)>126){
  
  cat("<table class='container'>")
  cat("<tr align='center'>")
  cat("<th width='100%'>")
  cat("Rolling Sharpe Ratio (6-month)")
  cat("</th></tr>")
  cat("</table>")
  
  #Rolling sharpe ratio chart
  sharpe50 = rollapply(s_dailyRet_xts, width=126,
                       FUN = function(Z) 
                       { 
                         ret = tryCatch(
                           {
                             (prod(1+Z)^2-1)/(sd(Z)*sqrt(252))
                             #SharpeRatio(Z,annualize = TRUE)[1]
                           },
                           error = function(cond){
                             return(NA)
                           }
                         )
                         return(ret) 
                       },by.column=FALSE, align="right")
  
  sharpe_df = data.frame(Date = index(sharpe50),SharpeRatio = sharpe50)
  
  print(ggplot(sharpe_df,aes(Date)) +
          geom_line(aes(y = SharpeRatio ,color="SharpeRatio"),size = 1) +
          geom_hline(yintercept = 0,size = 1)+
          geom_hline(aes(yintercept = mean(sharpe_df$SharpeRatio,na.rm = TRUE),color = "Mean"),
                     size = 1,linetype="dashed") + 
          labs(y= "Sharpe Ratio") +
          labs(color="Legend") +
          scale_colour_manual("", breaks = c("Mean","SharpeRatio"),values = c("red","#F5AE29"))+
          scale_x_date(labels = date_format("%b %Y"))+
          theme(legend.position = c(0.06,0.90)) +
          theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
                axis.text = element_text(size=10,family = "Open Sans Condensed"),
                axis.title.x=element_blank(),
                legend.title = element_text(size=8,family = "Open Sans Condensed"),
                legend.text = element_text(size=8,family = "Open Sans Condensed"),
                legend.background = element_rect(fill = "transparent", colour = "transparent") )+
          theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
          theme(panel.grid.major = element_line(colour = "grey")))
  
  imageNameMapping = rbind(imageNameMapping,data.frame(From = "RollingSharpeRatio(6-month)-1.png", 
                                                       To = "rolling-sharpe-ratio(6-month).png"))
}


