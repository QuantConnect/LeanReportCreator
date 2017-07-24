df2 = data.frame(Date = as.Date(index(s_dailyRet_xts)), DailyRet = as.numeric(s_dailyRet_xts)*100)
print(ggplot(df2,aes(Date)) +
    geom_col(aes(y = DailyRet , fill = (DailyRet < 0)),width = 1) +
    geom_hline(yintercept = 0,size = 1) + 
    labs(y= "Daily Return(%)") +
    labs(color="Legend") +
    scale_fill_manual(labels = c("TRUE" = "Below Zero","FALSE" = "Above Zero"),
                      values = c("#F5AE29", "#CCCCCC"))+
    scale_x_date(labels = date_format("%b %Y"))+
    theme(legend.position = c(0.06,0.85)) +
    theme(axis.title=element_text(size=12,family = "Open Sans Condensed"), 
          axis.text = element_text(size=10,family = "Open Sans Condensed"),
          axis.title.x=element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size=8,family = "Open Sans Condensed"),
          legend.background = element_rect(fill = "transparent", colour = "transparent"))+
    theme(panel.background = element_rect(colour = "#222222", fill = "white"))+
    theme(panel.grid.major = element_line(colour = "grey")))