EventChartInfo = list()
startDate = as.Date(c("2000-03-10","2001-09-11","2003-01-08","2008-08-01","2010-05-05",
                      "2007-08-01","2008-03-01","2008-09-01","2009-01-01","2009-03-01",
                      "2011-08-05","2011-03-16","2012-09-10",
                      "2014-04-01","2014-10-01","2015-08-15",
                      "2005-01-01","2007-08-01","2009-04-01","2013-01-01"))
endDate = as.Date(c("2000-09-10","2001-10-11","2003-02-07","2008-09-30","2010-05-10",
                    "2007-08-31","2008-03-31","2008-09-30","2009-02-28","2009-05-31",
                    "2011-09-05","2011-04-16","2012-10-10",
                    "2014-04-30","2014-10-31","2015-09-30",
                    "2007-07-31","2009-03-31","2012-12-31",as.character(Sys.Date())))
titles = c("Dotcom","9-11","US Housing Bubble 2003","Lehman Brothers","Flash Crash",
           "Aug07","Mar08","Sept08","2009Q1","2009Q2",
           "US Downgrade-European Debt Crisis","Fukushima Melt Down 2011","ECB IR Event 2012",
           "Apr14","Oct14","Fall2015",
           "Low Volatility Bull Market","GFC Crash","Recovery","New Normal","")
links = c("https://en.wikipedia.org/wiki/Dot-com_bubble",
          "https://en.wikipedia.org/wiki/September_11_attacks",
          "https://en.wikipedia.org/wiki/Timeline_of_the_United_States_housing_bubble#2001_-_2006",
          "https://en.wikipedia.org/wiki/Bankruptcy_of_Lehman_Brothers",
          "https://en.wikipedia.org/wiki/2010_Flash_Crash",
          "#0","#0","#0","#0","#0",
          "https://en.wikipedia.org/wiki/European_debt_crisis",
          "https://en.wikipedia.org/wiki/Fukushima_Daiichi_nuclear_disaster",
          "https://www.ecb.europa.eu/press/pr/date/2012/html/index.en.html",
          "#0","#0","#0","#0",
          "https://en.wikipedia.org/wiki/Financial_crisis_of_2007%E2%80%932008",
          "#0","#0")
footnotes = c("https://en.wikipedia.org/wiki/Dot-com_bubble",
              "https://en.wikipedia.org/wiki/September_11_attacks",
              "https://en.wikipedia.org/wiki/Timeline_of_the_United_States_housing_bubble#2001_-_2006",
              "https://en.wikipedia.org/wiki/Bankruptcy_of_Lehman_Brothers",
              "https://en.wikipedia.org/wiki/2010_Flash_Crash",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://en.wikipedia.org/wiki/European_debt_crisis",
              "https://en.wikipedia.org/wiki/Fukushima_Daiichi_nuclear_disaster",
              "https://www.ecb.europa.eu/press/pr/date/2012/html/index.en.html",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://en.wikipedia.org/wiki/Financial_crisis_of_2007%E2%80%932008",
              "https://finance.yahoo.com/quote/%5EGSPC/history/",
              "https://finance.yahoo.com/quote/%5EGSPC/history/")
#Use this array to show which charts should be drawn
index_array = c()
for(i in 1:length(startDate))
{
  tmp = which(bs_CumRet_df$Date>=startDate[i]&bs_CumRet_df$Date<=endDate[i])
  if(length(tmp)>0){
    index_array = c(index_array,i)
  }
}
while (length(index_array)%%3!=0){
  index_array = c(index_array,length(titles))
}
count = 1
for(i in index_array)
{
  if(count%%3==1)
  {
    cat("<table class='container'>")
    cat("<tr align='center'>")
    cat("<th width='35%'><a style='color:black' href='")
    cat(links[index_array[count]])
    cat("'>")
    cat(titles[index_array[count]])
    cat(paste0("<sup>[",count,"]</sup>"))
    cat("</a></th><th width='30%'><a style='color:black' href='")
    cat(links[index_array[count+1]])
    cat("'>")
    tmp = ifelse(titles[index_array[count+1]]=="","",paste0("[",count+1,"]"))
    cat(titles[index_array[count+1]])
    cat(paste0("<sup>",tmp,"</sup>"))
    cat("</a></th><th width='35%'><a style='color:black' href='")
    cat(links[index_array[count+2]])
    cat("'>")
    tmp = ifelse(titles[index_array[count+2]]=="","",paste0("[",count+2,"]"))
    cat(titles[index_array[count+2]])
    cat(paste0("<sup>",tmp,"</sup>"))
    cat("</a></th></tr>")
    cat("</table>")
  }
  #count = count+1 at bottom
  if(i==length(titles)){
    break
  }
  
  #Make the cumulative return of both strategy and benchmark have the same start point
  tmp_b_dailyRet_xts = b_dailyRet_xts[which(bs_CumRet_df$Date>=startDate[i]&
                                              bs_CumRet_df$Date<=endDate[i]),]
  tmp_s_dailyRet_xts = s_dailyRet_xts[which(bs_CumRet_df$Date>=startDate[i]&
                                              bs_CumRet_df$Date<=endDate[i]),]
  tmp_b_CumRet_xts = cumprod(1+tmp_b_dailyRet_xts)-1
  tmp_s_CumRet_xts = cumprod(1+tmp_s_dailyRet_xts)-1
  tmp_b_CumRet_df = data.frame(Date = as.Date(index(tmp_b_CumRet_xts)), 
                               CumRet = as.numeric(tmp_b_CumRet_xts))
  tmp_s_CumRet_df = data.frame(Date = as.Date(index(tmp_s_CumRet_xts)), 
                               CumRet = as.numeric(tmp_s_CumRet_xts))
  tmp_bs_CumRet_df = merge(tmp_b_CumRet_df,tmp_s_CumRet_df,by="Date")
  
  df6 = tmp_bs_CumRet_df
  df6$CumRet.x = (df6$CumRet.x - df6$CumRet.x[1])*100
  df6$CumRet.y = (df6$CumRet.y - df6$CumRet.y[1])*100
  print(ggplot(df6,aes(Date)) +
          geom_line(aes(y = CumRet.x,color="Benchmark"),size = 1) +
          geom_line(aes(y = CumRet.y,color="Strategy"),size = 1) +
          labs(y= "Returns(%)") +
          labs(color="Legend") +
          scale_colour_manual("", breaks = c("Benchmark", "Strategy"),
                              values = c("#CCCCCC", "#F5AE29"))+
          scale_x_date(labels = date_format("%Y-%m-%d"))+
          theme(plot.margin = unit(c(1,1,0.5,0), "cm")) +
          theme(axis.title=element_text(size=16,face="bold",family = "Open Sans Condensed"), 
                axis.text = element_text(size=14,family = "Open Sans Condensed"),
                axis.title.x=element_blank(),
                axis.text.x=element_text(angle = 30,hjust=1,family = "Open Sans Condensed"))+
          theme(panel.background = element_rect(colour = "#222222", fill = "white"),
                panel.grid.major = element_line(colour = "grey"))+
          theme(legend.title=element_blank(),
                legend.position = c(0.15,0.85),
                legend.background = element_rect(fill="transparent"),
                legend.text = element_text(size=14,family = "Open Sans Condensed")))
  
  #Handle the renaming issue
  tmp_df = data.frame(Name = tolower(gsub(" ","-",titles[index_array[count]])),
                      StartDate = startDate[index_array[count]],
                      EndDate = endDate[index_array[count]])
  EventChartInfo[[count]] = list(Attribute = tmp_df,
                                 TimeSeries = df6)
  imageNameMapping = rbind(imageNameMapping,
                           data.frame(From = paste0("Event-",count,".png"),
                                      To = paste0("crisis-",
                                                  tolower(gsub(" ","-",titles[index_array[count]])),".png")))
  count = count+1
}