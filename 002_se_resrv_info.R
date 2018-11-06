# Step 1: Install packages required for web-scrapping #########
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[,"Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages <- c("rvest","stringr","RDSTK","XML","qdapRegex")
ipak(packages)

ttt<-read.table(".../se_resrv_list.csv",head=TRUE)
ttt2 <- as.data.frame(matrix(ncol=9,nrow=nrow(ttt)))
for (i in 1:nrow(ttt)) {
  tryCatch({cid = substr(ttt[i,1],1,10)
          did = substr(ttt[i,1],12,17)
          link = paste("http://www.seis.or.kr/web/socialboard/BD_board_precertiCorpView.do?q_ent_id_v=",cid,"&q_report_ym_c=",did,sep="")
          a1<-read_html(link)
          a2<-xml_find_all(a1, "//tbody//tr//td") %>% xml_text()
          a3 <- gsub("\t","",a2)
          a4 <- gsub("\n","",a3)
          a5 <- as.data.frame(a4)
          a6 <- as.data.frame(matrix(ncol=nrow(a5), nrow=1))
          for (j in 1:nrow(a5)){
            b <- as.character(a5[j,1])
            ttt2[i,j] <- b
          }}, error=function(e){})
}

colnames(ttt) <- "id"
colnames(ttt2) <- c("name","url","ceo","jijeong","addr","phone","fax","btype","blank")
ttt3 <- cbind(ttt[,1],ttt2[,1:9])
write.table(ttt3, ".../se_resrv_info.csv", sep=",")
