
leve_df_res = list(Value = NA)

if(length(orders)>0){
  
  cat("<table class='container'>")
  cat("<tr align='center'>")
  cat("<th width='100%'>")
  cat("Leverage")
  cat("</th></tr>")
  cat("</table>")
  
  leve_df_res = cbind(allDate, Value = 0)
  for(sym in symbols)
  {
    leve_df_res$Value = leve_df_res$Value+abs(indOrderList[[sym]]$Value)
  }
  leve_df_res$Value = leve_df_res$Value/totalValue*100
  
  #The following code is used to draw chart only
  leve_df_res2 = rbind(data.frame(Date = s$x[1],Value = 0),leve_df_res,
                       data.frame(Date = max(s$x[nrow(s)],leve_df_res$Date[nrow(leve_df_res)]),Value = 0))
  barWidth = as.numeric(difftime(leve_df_res2$Date[-1],leve_df_res2$Date[-nrow(leve_df_res2)],units = "secs"))
  barWidth = c(barWidth,0)
  tmp = as.numeric(difftime(leve_df_res2$Date[nrow(leve_df_res2)],leve_df_res2$Date[1],units = "secs"))
  barWidth[which(barWidth/tmp<0.0008)] = tmp*0.0008
  
  leve_graph = ggplot(data = leve_df_res2,aes(x=Date),stat = "identity")
  leve_graph = leve_graph + geom_col(aes(y = Value, width = barWidth),
                                     position = position_nudge(x = barWidth/2),fill="#F5AE29")
  leve_graph = leve_graph + theme(legend.position = "none")
  leve_graph = leve_graph+labs(y= "Leverage(%)")
  leve_graph = leve_graph+geom_hline(yintercept = 0,size = 1)
  # leve_graph = leve_graph+geom_line(data = posi_df_res2, aes(x = Date, y = Value))
  leve_graph = leve_graph+scale_x_datetime(labels = date_format("%b %Y"))
  leve_graph = leve_graph+theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
                                axis.text = element_text(size=10,family = "Open Sans Condensed"),
                                axis.title.x=element_blank(),
                                panel.background = element_rect(colour = "#222222", fill = "white"),
                                panel.grid.major = element_line(colour = "grey"))
  print(leve_graph)
  
}