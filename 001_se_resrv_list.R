# Step 1: Install packages required for web-scrapping #########
ipak <- function(pkg){
      new.pkg <- pkg[!(pkg %in% installed.packages()[,"Package"])]
      if (length(new.pkg))
        install.packages(new.pkg, dependencies = TRUE)
      sapply(pkg, require, character.only = TRUE)
}

packages <- c("rvest","stringr","RDSTK","XML","qdapRegex")
ipak(packages)


yyyy <- c("2016","2017","2018")
mm <- c("01","02","03","04","05","06","07","08","09","10","11","12")
yyyymm <- character()
for (i in yyyy){
  for (j in mm){
  ym <- paste(i,j,sep="")
  yyyymm <- append(yyyymm,ym)
  }
}

ym_c <- yyyymm[1:32]
pgs <- numeric()
for (i in ym_c){
l1 <- paste("http://www.seis.or.kr/web/socialboard/BD_board_precertiCorpList.do?q_ent_id_v&q_report_ym_c=",i,sep="")
  a0 <- read_html(l1)
  a1 <- xml_find_all(a0,"//a/@onclick[contains(string(.),'jsMovePage')]") %>% xml_text()
  a2 <- as.numeric(gsub("\\D","",a1))
  a3 <- max(a2)
  pgs <- append(pgs,a3)
}

b0 <- as.data.frame(cbind(ym_c,pgs))
b1 <- b0[ !(b0$pgs==-Inf),]
b2 <- as.character(b1[,2])
b3 <- as.numeric(b2)

c1 <- character()
for (k in 1:nrow(b1)){
  for (m in 1:b3[k]){
    c0 <- paste("http://www.seis.or.kr/web/socialboard/BD_board_precertiCorpList.do?q_ent_id_v&q_report_ym_c=",as.character(b1[k,1]),"&q_currPage=",m,sep="")
    c1 <- append(c1,c0)
    }
}

c5 <- character()
for (n in 1:length(c1)) {
  c2 <- read_html(c1[n])
  c3 <- xml_find_all(c2,"//td/@onclick[contains(string(.),'corpView')]") %>% xml_text()
  c4 <- gsub("\\D","",c3)
  ymc <- gsub("http://www.seis.or.kr/web/socialboard/BD_board_precertiCorpList.do?","",c1[n])
  ymc1 <- gsub("?q_ent_id_v&q_report_ym_c=","",ymc)
  ymc2 <- substr(ymc1,2,7)
  page <- gsub(".*_curr","",c1[n])
  for (o in 1:length(c4)) {
    ele <- paste(c4[o],ymc2,sep="|")
    ele2 <- paste("E",ele,sep="")
    ele3 <- paste(ele2,page,sep="|")
    c5 <- append(c5,ele3)
  }
}

c6 <- as.data.frame(c5)

write.table(c6, ".../se_resrv_list.csv",sep="|", row.names=FALSE)
