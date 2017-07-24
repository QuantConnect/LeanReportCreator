#Remove all the variables from previous execution
rm(list=ls())

#Get the parameters input from command line
args = commandArgs(trailingOnly = TRUE)
input_name = args[1]
output_name = args[2]
dir_name = args[3]

print("Parsing Json file:")
print(input_name)

#Call RMarkDown file and specify the input and output director
rmarkdown::render("Live.Rmd","html_document",output_file = paste0(dir_name,"/",output_name),
                  params = list(file=input_name,dir = dir_name))

#Generate Report
source(paste0(".","/functions/generateReport.R"))

