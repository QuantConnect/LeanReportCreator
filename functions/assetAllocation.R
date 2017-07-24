
titles = c("All Assets Allocation","Equity Assets Allocation","Option Assets Allocation",
           "Commodity Assets Allocation","Forex Assets Allocation","Future Assets Allocation","")
chartNames = c("all","equity","option","commodity","forex","future")
index_array = c()
chart_list = list()

#Aggregate the asset holding information
pie_df = data.frame(Asset = "Cash", Percentage = 0)
if(length(indOrderList)>0)
{
  timeRange = as.numeric(difftime(posi_df_res2$Date[nrow(posi_df_res2)],posi_df_res2$Date[1],units = "secs"))
  timeWeight = as.numeric(difftime(posi_df_res2$Date[-1], posi_df_res2$Date[-nrow(posi_df_res2)],units = "secs"))
  #Calculate time-weighted average
  for(i in 1:length(indOrderList))
  {
    assetName = names(indOrderList)[i]
    percentValue = c(0,indOrderList[[i]]$Percentage)
    WeightedAvgValue = sum(timeWeight*percentValue/timeRange)
    tmp_row = data.frame(Asset = assetName,Percentage = WeightedAvgValue)
    pie_df = rbind(pie_df,tmp_row)
  }
}
pie_df$Percentage[1] = 1 - sum(pie_df$Percentage)
pie_df = merge(pie_df,assetClass,by = "Asset")
pie_df = pie_df[order(abs(pie_df$Percentage),decreasing = TRUE),]
pie_df1 = pie_df

#What if there is no such class
#Right now, only consider equity and forex

for(i in 1:length(chartNames))
{
  if(i > 1){
    pie_df1 = pie_df[which(pie_df$Class==i-1),]
  }
  if(nrow(pie_df1)!=0)
  {
    index_array = c(index_array,i)
    tmp_index = which(abs(pie_df1$Percentage)/sum(abs(pie_df1$Percentage))<0.10&(pie_df1$Asset!="Cash"))
    pie_df1_res = pie_df1
    if (length(tmp_index)>1)
    {
      tmp_df = pie_df1_res[tmp_index,]
      pie_df1_res = pie_df1_res[-tmp_index,]
      pie_df1_res = rbind(pie_df1_res,data.frame(Asset = "Others",Percentage = sum(tmp_df$Percentage),Class = -1))
      if(nrow(pie_df1_res)==1)
      {
        pie_df1_res$Asset = "(Too Small To Display)"
      }
    }
    pie_df1_res = pie_df1_res[order(pie_df1_res$Percentage),]
    pie_df1_res$Group = factor(nrow(pie_df1_res):1)
    
    #Adjust the labels on the axis of the chart
    bias = -sum(pie_df1_res$Percentage[which(pie_df1_res$Percentage<0)])
    tmpSum = sum(pie_df1_res$Percentage)
    stepEach = (bias*2+tmpSum)/10
    labelseq = c(rev(seq(0,-bias,by = -stepEach)))
    if(stepEach<bias+tmpSum)  labelseq = c(labelseq, seq(stepEach,bias+tmpSum,by = stepEach))
    
    pie_chart1 = ggplot(pie_df1_res, aes(x="", y=abs(Percentage), fill= Group))+
      geom_bar(stat = "identity")+
      coord_polar("y") +
      scale_y_continuous(labels=percent(labelseq), breaks = c(labelseq+bias))+
      scale_fill_brewer(palette = "Oranges") + 
      theme(axis.title.x=element_blank())+
      geom_text(aes(label = paste(percent(round(Percentage,3)),Asset,sep = '\n')),
                position = position_stack(vjust = 0.5),
                size = 5,family = "Open Sans Condensed")+
      theme(axis.title = element_blank(),
            axis.text = element_text(size=15,family = "Open Sans Condensed"),
            legend.position = "none")+
      theme(panel.background = element_rect(colour = "white", fill = "white"))+
      theme(panel.grid.major = element_line(colour = "grey"))
    
    chart_list[[length(chart_list)+1]] = pie_chart1
  }
}

while (length(index_array)%%3!=0){
  index_array = c(index_array,length(titles))
}

count = 1
for(i in 1:length(chart_list))
{
  if(count %% 3 == 1)
  {
    cat("<table class='container'>")
    cat("<tr align='center'>")
    cat("<th width='35%'>")
    cat(titles[index_array[count]])
    cat("</th><th width='30%'>")
    cat(titles[index_array[count+1]])
    cat("</th><th width='35%'>")
    cat(titles[index_array[count+2]])
    cat("</th></tr>")
    cat("</table>")
  }
  imageNameMapping = rbind(imageNameMapping,
                           data.frame(From = paste0("AssetAllocation-",i,".png"),
                                      To = paste0("asset-allocation-",chartNames[index_array[count]],".png")))
  print(chart_list[[i]])
  
  count = count + 1
}
