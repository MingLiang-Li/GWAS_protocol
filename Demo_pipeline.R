#1.download demo dataset from https://zzlab.net/GAPIT/GAPIT_Tutorial_Data.zip
#2. clean memory and load GAPIT library
rm(list=ls())
source("http://zzlab.net/GAPIT/gapit_functions.txt")
source("gapit.txt")
#3. set pathway; read genotype, map, covariates, and phenotype data
setwd("YOUR_PATH_WAY")
myGD=read.table("mdp_numeric.txt",head=T)
myGM=read.table("mdp_SNP_information.txt",head=T)
myCV=read.table("Copy of Q_First_Three_Principal_Components.txt",head=T)
myY=read.table("mdp_traits_validation.txt",head=T)
#4. run GAPIT with BLINK, FarmCPU, or MLM model
myGAPIT_blink <- GAPIT( Y=myY, GD=myGD, GM=myGM, CV=myCV, model="Blink", SNP.MAF=0.05)
myGAPIT_farmcpu <- GAPIT( Y=myY, GD=myGD, GM=myGM,CV=myCV, model="FarmCPU", SNP.MAF=0.05)
myGAPIT_mlm <- GAPIT( Y=myY, GD=myGD, GM=myGM,CV=myCV, model="MLM", SNP.MAF=0.05)
#5. go to current pathway to check the output result files
getwd()
