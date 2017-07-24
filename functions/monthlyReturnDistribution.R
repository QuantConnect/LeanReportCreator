df5 = as.data.frame(sMonRet*100)
print(ggplot(df5, aes(x=monthly.returns)) + 
    geom_histogram(binwidth = 0.01*100, color="white", fill="#F5AE29" ) + 
    labs(y= "Number of Months") +
    labs(x= "Returns(%)") +
    # stat_bin(aes(y=..count.. , label=..count..), 
    #        geom="text", binwidth=0.01*100, vjust = 0, size = 5) +
    geom_vline(xintercept = 0) + 
    geom_vline(aes(xintercept = mean(df5[,1]),color="mean"),linetype="dashed") +
    scale_color_manual(values = c(mean = "red"))+
    theme(legend.title=element_blank(),
          legend.position = c(0.15,0.90),
          plot.margin = unit(c(1,1,0.5,0), "cm"),
          axis.title=element_text(size=16,face="bold",family = "Open Sans Condensed"), 
          axis.text = element_text(size=14,family = "Open Sans Condensed"),
          legend.background = element_rect(fill="transparent"),
          legend.text = element_text(size=14,family = "Open Sans Condensed")))