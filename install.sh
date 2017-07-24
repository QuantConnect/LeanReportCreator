apt-get update
apt-get install -y r-base

apt-get install -y pandoc
apt-get install -y libcurl4-openssl-dev

#Assume the fonts are in ./fonts/
cp ./fonts/* /usr/share/fonts/truetype

Rscript install.R


