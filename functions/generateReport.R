#Read the intermediate file where the names of images are stored
if(file.exists(paste0(dir_name,"/images/imageNameMapping.csv")))
{
  imageNameMapping = read.csv(paste0(dir_name,"/images/imageNameMapping.csv"))
  #Change the names of the images according to the mapping info in the intermediate file
  for(i in 1:nrow(imageNameMapping))
  {
    tryCatch({
      if(file.exists(paste0(dir_name,"/images/",imageNameMapping$From[i])))
        file.rename(paste0(dir_name,"/images/",imageNameMapping$From[i]),paste0(dir_name,"/images/",imageNameMapping$To[i]))
    },error = function(e){
      while(!file.rename(paste0(dir_name,"/images/",imageNameMapping$From[i]),paste0(dir_name,"/images/",imageNameMapping$To[i]))){
        Sys.sleep(0.1)
      }
    })
  }
}

#Remove unnecessary files
unlink(paste0(dir_name,"/images/imageNameMapping.csv"), recursive=TRUE)

#Read and modify the template
html = readLines("Template.html")

#Fill Strategy Description
des= readLines("Description.txt")
html[152] = paste0(des[-1],collapse = "<br>")
html[c(134, 362, 458, 650)] = paste0('<div class="header-right">',des[1],'</div>')

#Fill auther-bio
profile = readLines("Profile.txt")
html[165] = paste0('About the Author <span class="pull-right">',profile[1],'</span>')
html[174] = paste0(profile[-1],collapse = "<br>")

#Parse generated file and fill the form in the template
jsonfile = jsonlite::fromJSON("strategy-statistics.json")
for(i in 1:4)
{
  if(jsonfile$StrategyStatistics[i]==TRUE){
    html[i*4+190] = '<td><i class="fa fa-check" aria-hidden="true"></i></td>'
  }else{
    html[i*4+190] = '<td><i class="fa fa-times" aria-hidden="true"></i></td>'
  }
}

assetType = union(assetClass$Class,assetClass$Class)
assetTypeName = c("Equity","Option","Commodity","Forex","Cfd")
html[210] = paste0("<td>",paste(assetTypeName[assetType],collapse = ", "),"</td>")

tmp = c(as.character(file$TotalPerformance$PortfolioStatistics$CompoundingAnnualReturn*100),
        as.character(file$TotalPerformance$PortfolioStatistics$Drawdown*100),
        as.character(file$TotalPerformance$TradeStatistics$SharpeRatio),
        as.character(file$TotalPerformance$TradeStatistics$SortinoRatio),
        as.character(as.numeric(file$Statistics$`Total Trades`)/nrow(df1)))

for(i in 1:length(tmp))
{
  tmp[i] = ifelse(regexpr("\\.",tmp[i])[1]>0,paste0(tmp[i],"00"),paste0(tmp[i],".000"))
  tmp[i] = substr(tmp[i],1,regexpr("\\.",tmp[i])[1]+3)
}

html[225] = paste0("<td>",tmp[1],"%","</td>")
html[229] = paste0("<td>",tmp[2],"%","</td>")
html[233] = paste0("<td>",tmp[3],"</td>")
html[237] = paste0("<td>",tmp[4],"</td>")
html[241] = paste0("<td>",tmp[5],"</td>")

#Read image files and fill the chart blank in the template
allImages = c('cumulative-return.png','daily-returns.png','drawdowns.png',
              'monthly-returns.png','annual-returns.png','distribution-of-monthly-returns.png',
              'crisis-2009q1.png','crisis-2009q2.png','crisis-9-11.png',
              'crisis-apr14.png','crisis-aug07.png','crisis-dotcom.png',
              'crisis-ecb-ir-event-2012.png','crisis-fall2015.png','crisis-flash-crash.png',
              'crisis-fukushima-melt-down-2011.png','crisis-gfc-crash.png','crisis-lehman-brothers.png',
              'crisis-low-volatility-bull-market.png','crisis-mar08.png','crisis-new-normal.png',
              'crisis-oct14.png','crisis-recovery.png','crisis-sept08.png',
              'crisis-us-downgrade-european-debt-crisis.png','crisis-us-housing-bubble-2003.png',
              'rolling-portfolio-beta-to-equity.png',
              'rolling-sharpe-ratio(6-month).png','net-holdings.png','leverage.png',
              'asset-allocation-all.png','asset-allocation-equity.png','asset-allocation-forex.png',
              'return-prediction.png')
images = imageNameMapping$To

allCrisisImages = allImages[7:26]
crisisImages = as.character(images[which(images %in% allCrisisImages)])

i = 1
count = 1
while(count<=length(allCrisisImages)){
  if(allCrisisImages[i] %in% crisisImages){
    i = i+1
  }else{
    for(j in i:(length(allCrisisImages)-1)){
      tmp1 = paste0('<img src="./images/',allCrisisImages[j],'">')
      tmp1 = which(html==tmp1)
      tmp2 = paste0('<img src="./images/',allCrisisImages[j+1],'">')
      tmp2 = which(html==tmp2) 
      tmp = html[tmp2]
      html[tmp2] = html[tmp1]
      html[tmp1] = tmp
      tmp = html[tmp2-6]
      html[tmp2-6] = html[tmp1-6]
      html[tmp1-6] = tmp  
      tmp = allCrisisImages[j+1]
      allCrisisImages[j+1] = allCrisisImages[j]
      allCrisisImages[j] = tmp
    }
  }
  count = count + 1
}

namesToRemove = setdiff(allImages,images)
for(fileName in namesToRemove)
{
  tmp = paste0('<img src="./images/',fileName,'">')
  tmp = which(html==tmp)
  html = html[-c((tmp-9):(tmp+4))]
}

writeLines(html,"Report.html")



