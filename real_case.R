
#Download reproduction material (data)
#system("wget https://github.com/MingLiang-Li/GWAS_protocol/blob/main/beagle.jar")
#system("wget http://ricediversity.org/data/sets_hydra/HDRA-G6-4-RDP1-RDP2-NIAS-2.tar.gz")
#system("wget http://ricediversity.org/data/sets_hydra/HDRA-G6-4-SNP-MAP.tar.gz")
#system("wget http://ricediversity.org/data/sets_hydra/phenoAvLen_G6_4_RDP12_ALL.tar.gz")

#Extract the data
#system("tar -xvf  HDRA-G6-4-RDP1-RDP2-NIAS-2.tar.gz")
#system("tar zxvf HDRA-G6-4-SNP-MAP.tar.gz")
#system("tar zxvf phenoAvLen_G6_4_RDP12_ALL.tar.gz")

#please replace all the pathway in this script to the pathway saved your data

#create a new map file for PLINK binary format to replace allele from A/B to G/C/A/T
map=read.table("HDRA-G6-4-SNP-MAP/HDRA-G6-4-final-snp-map.tsv",head=F)
bim=read.table("HDRA-G6-4-RDP1-RDP2-NIAS/HDRA-G6-4-RDP1-RDP2-NIAS.bim",head=F)
bim[,5:6]=map[,4:5]
write.table(bim,"HDRA-G6-4-RDP1-RDP2-NIAS/HDRA-G6-4-RDP1-RDP2-NIAS.bim",quote=F,row.names = F,col.names = F)

#convert PLINK format to VCF format
#Ensure the 'blink' file has executable permissions
system("chmod +x  blink")
system("./blink --file HDRA-G6-4-RDP1-RDP2-NIAS/HDRA-G6-4-RDP1-RDP2-NIAS --plink  --compress --noimp --out rice")
system("./blink --file rice --uvcf --recode --out rice")

#run beagle5 to impute missing genotype. beagle5 could be downloaded from https://faculty.washington.edu/browning/beagle/beagle.html
#Adjust the Java VM maximum heap size (-Xmx) based on available system memory and dataset size
system("java -Xmx20000m -jar beagle.jar gt=rice.vcf out=test")

#create txt file
zlines <- readLines("HDRA-G6-4-RDP1-RDP2-NIAS/HDRA-G6-4-RDP1-RDP2-NIAS.fam")
zline <- "FID IID father mother sex phenotype"
zlines <- c(zline,zlines)
writeLines(zlines,"rice.txt")

system("./blink --file test --vcf --compress --out rice")
system("./blink --file rice --hapmap --recode --out rice")
system("awk '{print $2}' rice.txt > ID.txt")

#load SNP data, map, and phenotype
trait1=read.table("phenoAvLen_G6_4_RDP12_ALL/phenoAvLen_G6_4_RDP12_ALL.txt",head=T)

#match and convert sample ID between SNP data and phenotype data
ID=read.table("ID.txt",head=T)
trait1[,1]=paste("IRGC",trait1[,1],sep='')
trait=read.delim("HDRA-G6-4-RDP1-RDP2-NIAS/HDRA-G6-4-RDP1-RDP2-NIAS-sativa-only.sample_map.rev2.tsv",head=F)
trait=merge(trait,ID,by.x="V2",by.y="IID")
trait=merge(trait,trait1,by.x="V3",by.y="FID")
myG=read.table("rice.hmp",head=F,check.names = F)
myY=trait[,c(2,12)]

#Run blink R version via GAPIT
source("http://zzlab.net/GAPIT/gapit_functions.txt")
myGAPIT=GAPIT(Y=myY,G=myG,PCA.total=3,model="BLINK")
