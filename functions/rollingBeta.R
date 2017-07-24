#Won't draw if backtest period is less than 1 year
if(nrow(bs_dailyRet_xts)>252){
  
  cat("<table class='container'>")
  cat("<tr align='center'>")
  cat("<th width='100%'>")
  cat("Rolling Portfolio Beta to Equity")
  cat("</th></tr>")
  cat("</table>")
  
  #Rolling beta charts
  bs_dailyRet_xts[,1][which(is.nan(bs_dailyRet_xts[,1]))] = NA
  bs_dailyRet_xts[,1][which(bs_dailyRet_xts[,1]==Inf)] = NA
  bs_dailyRet_xts[,1][which(is.na(bs_dailyRet_xts[,1]))] = 0
  bs_dailyRet_xts[,2][which(is.nan(bs_dailyRet_xts[,2]))] = NA
  bs_dailyRet_xts[,2][which(bs_dailyRet_xts[,2]==Inf)] = NA
  bs_dailyRet_xts[,2][which(is.na(bs_dailyRet_xts[,2]))] = 0
  beta50 = rollapply(bs_dailyRet_xts, width=126,
                     FUN = function(Z) 
                     { 
                       return(cov(Z[,1],Z[,2])/var(Z[,2]))
                     },by.column=FALSE, align="right")
  beta100 = rollapply(bs_dailyRet_xts, width=252,
                      FUN = function(Z) 
                      { 
                        return(cov(Z[,1],Z[,2])/var(Z[,2])) 
                      },by.column=FALSE, align="right")
  beta_df = data.frame(Date = index(beta50),Beta6mo = beta50, Beta12mo = beta100)
  
  print(ggplot(beta_df,aes(Date)) +
          geom_line(aes(y = Beta6mo ,color="Beta6mo"),size = 1) +
          geom_line(aes(y = Beta12mo ,color="Beta12mo"),size = 1) +
          geom_hline(yintercept = 0,size = 1) + 
          labs(y= "Beta") +
          labs(color="Legend") +
          scale_colour_manual("", breaks = c("Beta6mo", "Beta12mo"),values = c("#428BCA", "#CCCCCC"))+
          scale_x_date(labels = date_format("%b %Y"))+
          theme(legend.position = c(0.05,0.90)) +
          theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
                axis.text = element_text(size=10,family = "Open Sans Condensed"),
                axis.title.x=element_blank(),
                legend.title = element_text(size=8,family = "Open Sans Condensed"),
                legend.text = element_text(size=8,family = "Open Sans Condensed"),
                legend.background = element_rect(fill = "transparent", colour = "transparent"))+
          theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
          theme(panel.grid.major = element_line(colour = "grey")))
  
  imageNameMapping = rbind(imageNameMapping,data.frame(From = "RollingPortfolioBetaToEquity-1.png", 
                                                       To = "rolling-portfolio-beta-to-equity.png"))
}
