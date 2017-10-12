Precifunc<-function(keyword,sizekey,text) {
  t<-0
  m<-0
  m<-sum(gregexpr(paste0(" ",tolower(keyword)," ") ,tolower(gsub("\\W", " ", text , perl=TRUE)), fixed=TRUE)[[1]] > 0)
  if (m>=5)(m<-5)
  if(m>0) t<-100/sizekey
  if(m>1) t<-t+(m*(100/(sizekey*5)))
  t<-t/2
  return(t)
}
