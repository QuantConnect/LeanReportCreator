df1 = s_CumRet_df
df1$CumRet = df1$CumRet*100
df1$CumRetBench = b_CumRet_df$CumRet*100
print(ggplot(df1,aes(Date)) +
    geom_step(aes(y = CumRetBench, color="Benchmark"),size = 1) +
    geom_step(aes(y = CumRet ,color="Strategy"),size = 1) +
    geom_hline(yintercept = 0,size = 1) + 
    labs(y= "Cumulative Return(%)") +
    labs(color="Legend") +
    scale_colour_manual("", breaks = c("Benchmark","Strategy"),values = c("grey","#F5AE29"))+
    scale_x_date(labels = date_format("%b %Y"))+
    theme(legend.position = c(0.06,0.85)) +
    theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
          axis.text = element_text(size=10,family = "Open Sans Condensed"),
          axis.title.x=element_blank(),
          legend.title = element_text(size=8,family = "Open Sans Condensed"),
          legend.text = element_text(size=8,family = "Open Sans Condensed"),
          legend.background = element_rect(fill = "transparent", colour = "transparent") )+
    theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
    theme(panel.grid.major = element_line(colour = "grey")))