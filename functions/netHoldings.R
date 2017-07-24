
posi_date = c()
posi_symbol = c()
posi_quant = c()
posi_price = c()
posi_df_res = list(Value = NA)
orders = file$Orders
indOrderList = list()
assetClass = data.frame(Asset = "Cash", Class = 0)

#Won't draw if there is no trading
if(length(orders)>0){
  
  cat("<table class='container'>")
  cat("<tr align='center'>")
  cat("<th width='100%'>")
  cat("Net Holdings")
  cat("</th></tr>")
  cat("</table>")
  
  #Parse the info in the orders
  for(i in 1:length(orders))
  {
    if(orders[[i]]$Tag=="Liquidated"){
      next
    }
    if(orders[[i]]$Value==0){
      next
    }
    posi_date = c(posi_date,orders[[i]]$Time)
    posi_symbol = c(posi_symbol,orders[[i]]$Symbol$Value)
    
    #The code is buggy and will be changed when the asset has nothing to do with USD
    if(orders[[i]]$PriceCurrency=="USD"){
      posi_quant = c(posi_quant,orders[[i]]$Quantity)
      posi_price = c(posi_price,orders[[i]]$Price)
    }else{
      posi_quant = c(posi_quant,-orders[[i]]$Value)
      posi_price = c(posi_price,1/orders[[i]]$Price)
    }
    
    #Do asset classification
    if(!orders[[i]]$Symbol$Value %in% assetClass$Asset)
    {
      assetClass = rbind(assetClass,data.frame(Asset = orders[[i]]$Symbol$Value,
                                               Class = orders[[i]]$SecurityType))
    }
  }
  posi_df = data.frame(Date = as.POSIXct(posi_date,format="%Y-%m-%dT%H:%M:%SZ"),Symbol = posi_symbol, 
                       Quant = posi_quant,Price = posi_price,Value = posi_quant*posi_price)
  
  posi_df_agg = aggregate(list(Quant = posi_df$Quant,Value = posi_df$Value),
                          by=list(Symbol = posi_df$Symbol,Date = posi_df$Date),FUN = sum)
  
  #Assume in the same minute, the price is the same
  tmp = which(posi_df_agg$Quant==0)
  if(length(tmp)>0)  posi_df_agg = posi_df_agg[-tmp,]
  posi_df_agg$Price = posi_df_agg$Value/posi_df_agg$Quant
  
  tmp = aggregate(list(Value = posi_df_agg$Value),by = list(Date = posi_df_agg$Date),FUN = sum)
  tmp$Value = cumsum(tmp$Value)
  tmp$Value = s$y[1] - tmp$Value
  cashTable = tmp
  
  #allDate should be the whole backtest period
  allDate = data.frame(Date = tmp$Date)
  
  symbols = union(posi_df_agg$Symbol,posi_df_agg$Symbol)
  posi_df_res = cbind(allDate, Value = 0)
  for(sym in symbols)
  {
    tmp = posi_df_agg[posi_df_agg$Symbol==sym,]
    tmp = merge(allDate,tmp,by="Date",all=TRUE)
    tmp$Quant[is.na(tmp$Quant)]=0
    tmp$Quant = cumsum(tmp$Quant)
    tmp$Value = na.locf(tmp$Quant*tmp$Price,na.rm = FALSE)
    tmp$Value[is.na(tmp$Value)]=0
    posi_df_res$Value = posi_df_res$Value+tmp$Value
    indOrderList[[sym]] = tmp
  }
  totalValue = posi_df_res$Value+cashTable$Value
  posi_df_res$Value = posi_df_res$Value/totalValue*100
  for(sym in symbols)
  {
    indOrderList[[sym]]$Percentage = indOrderList[[sym]]$Value/totalValue
  }
  
  #The following code is used to draw chart only
  posi_df_res2 = rbind(data.frame(Date = s$x[1],Value = 0),posi_df_res,
                       data.frame(Date = max(s$x[nrow(s)],posi_df_res$Date[nrow(posi_df_res)]),Value = 0))
  barWidth = as.numeric(difftime(posi_df_res2$Date[-1],posi_df_res2$Date[-nrow(posi_df_res2)],units = "secs"))
  barWidth = c(barWidth,0)
  
  tmp = as.numeric(difftime(posi_df_res2$Date[nrow(posi_df_res2)],posi_df_res2$Date[1],units = "secs"))
  barWidth[which(barWidth/tmp<0.0008)] = tmp*0.0008
  
  posi_graph = ggplot(data = posi_df_res2,aes(x=Date),stat = "identity")
  posi_graph = posi_graph + geom_col(aes(y = Value , fill = (Value < 0), width = barWidth),
                                     position = position_nudge(x = barWidth/2))
  posi_graph = posi_graph + scale_fill_manual(labels = c("TRUE" = "Below Zero","FALSE" = "Above Zero"),
                                              values = c("#F5AE29", "#CCCCCC"))
  posi_graph = posi_graph + theme(legend.position = "none")
  posi_graph = posi_graph+labs(y= "Net Holdings(%)")
  posi_graph = posi_graph+geom_hline(yintercept = 0,size = 1)
  # posi_graph = posi_graph+geom_line(data = posi_df_res2, aes(x = Date, y = Value))
  posi_graph = posi_graph+scale_x_datetime(labels = date_format("%b %Y"))
  posi_graph = posi_graph+theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
                                axis.text = element_text(size=10,family = "Open Sans Condensed"),
                                axis.title.x=element_blank(),
                                panel.background = element_rect(colour = "#222222", fill = "white"),
                                panel.grid.major = element_line(colour = "grey"))
  print(posi_graph)
  
}