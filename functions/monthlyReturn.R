sMonRet = periodReturn(s_price_xts,period = "monthly")
sMonRetTable = table.CalendarReturns(sMonRet)
sMonRetTable = sMonRetTable[,-ncol(sMonRetTable)]
mx = t(as.matrix(sMonRetTable))
# mx[which(is.na(mx))]=0
myPanel <- function(x, y, z, ...) {
  panel.levelplot(x,y,z,...)
  panel.text(x, y, z)
}
ckey = list(labels=list(cex=1))
ramp = colorRamp(c("red", "#FFFF99","green"))
colpal = colorRampPalette(colors = rgb( ramp(seq(0, 1, length = 91)), max = 255)) 
lw = list(left.padding = list(x = 0, units = "inches"))
lw$right.padding = list(x = 0, units = "inches")
lh = list(bottom.padding = list(x = 0, units = "inches"))
lh$top.padding = list(x = 0, units = "inches")
lattice.options(layout.widths = lw, layout.heights = lh)
print(levelplot(mx,panel = myPanel,scales=list(x=list(cex=1.1),y=list(cex=1.1)),
          xlab = list(label = "Month",fontsize = 16, font = 2),
          ylab = list(label = "Year", fontsize = 16, font = 2),
          col.regions = colpal(100),at = c(-100,seq(-10,10,length.out = 90),100),
          colorkey = NULL,aspect="fill"))