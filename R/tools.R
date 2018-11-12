Precifunc<-function(keyword,sizekey,text) {
  t<-0
  m<-0
  m<-sum(gregexpr(keyword ,text ,ignore.case = TRUE)[[1]] > 0)
  if(m>=5) m<-5
  if(m>0) t<-100/sizekey
  if(m>1) t<-t+(m*(100/(sizekey*5)))
  t<-t/2
  return(t)
}

NormalizeForExcel<- function(dta){

  max<-length(dta[[1]]);
  for(i in 1:length(dta)){
    if(length(dta[[i]])>max) max<-length(dta[[i]])
  }
  if(max>1){
    for(i in 1:length(dta)){
      if(length(dta[[i]])==0){
        dta[[i]]<-rep(NA, max)
      } else if(length(dta[[i]])<max){
        dta[[i]]<-rep(dta[[i]][[1]], max)
      }
    }
  }
  dta
}

isTarget<-function(Data) {
  x<-0;
  for (i in Data) {
    if(length(i)>0){
      if (!is.vector(i)){
        if(i=="NA"){x<-bitwOr(0,x)} else {x<-bitwOr(x,1)}
      } else {
        x<-bitwOr(x,1)
      }
    } else {
      x<-bitwAnd(0,x)
    }
  }
  if(x==0) return(FALSE)
  else return(TRUE)
}
RemoveTags<-function(content){
content<-gsub("<script\\b[^<]*>[^<]*(?:<(?!/script>)[^<]*)*</script>", "", content, perl=T)
content<-gsub("<.*?>", "", content)
content<-gsub(pattern = "\n" ," ", content)
content<-gsub("^\\s+|\\s+$", "", content)
return(content)
}
Listlength<-function(List){
 len<-0
 len<-sum(sapply(List, length))
  return(len)
}
TransposeList<-function(DATA){
TDATA<-list()
  for(i in 1:length(DATA[[1]])){
    line<-vector()
    CountNA<-0
    for (j in 1:length(DATA)){
      if(DATA[[j]][i]=="NA") CountNA<-CountNA+1
      line<-c(line,DATA[[j]][i])
    }
    if(CountNA!=4){
    TDATA<-c(TDATA,list(line))
    }
  }
return(TDATA)
}

ItemizeNode <- function(path){
  pathsplit<- unlist(strsplit(path,"/",fixed = TRUE))
  vecpaths<-vector()
  for(i in 1:length(pathsplit)){
    newpath<-""
    for(j in 1:i){
      newpath<-paste0(newpath,"/",pathsplit[j])
    }
    newpath<-substr(newpath, 2, nchar(newpath))
    vecpaths<-c(vecpaths,newpath)
  }
  return(vecpaths)
}

ReplaceX <- function(xx, real){
  xxsplit<- unlist(strsplit(xx,"/",fixed = TRUE))
  realsplit<- unlist(strsplit(real,"/",fixed = TRUE))
  for(i in 1:length(realsplit)){
    xxsplit[i]<-realsplit[i]
  }
  newpath=""
  for(j in 1:length(xxsplit)){
    newpath<- paste0(newpath,"/",xxsplit[j])
  }
  newpath<-substr(newpath, 2, nchar(newpath))
  return(newpath)
}

is_windows <- function() .Platform$OS.type == "windows"

is_osx     <- function() Sys.info()[['sysname']] == 'Darwin'

is_linux   <- function() Sys.info()[['sysname']] == 'Linux'

dir_exists <- function(path) utils::file_test('-d', path)

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}


#' @importFrom  data.table %chin%
getDomain<-function(urls){
  tlds<-c('sport',       'isla',       'army',       'navy',       'agrar',       'name',       'priv',       'info',
          'from',       'csiro',       'conf',       'coop',       'press',       'asso',       'aero',       'museum',
          'school',       'maori',       'presse',       'tourism',       'game',       'geek',       'gouv',       'brand',
          'shop',       'store',       'adult',       'muni',       'firm')
  rDomains<-vector()
  for (url in urls ){
    urlpart<-strsplit(url, split = ".",fixed = TRUE)[[1]]
    #cat(length(urlpart))
    dom<-0
    if(length(urlpart)==3){
      if(nchar(urlpart[length(urlpart)-1])>3 && !(urlpart[length(urlpart)-1] %chin% tlds) ){
        for (i in 1:(length(urlpart)-1)) {
          if(dom==0) { dom<-paste0("",urlpart[i])
          }else{ dom<-paste0(dom,".",urlpart[i])}
        }

      } else {
        for (i in 1:(length(urlpart)-2)) {
          if(dom==0) { dom<-paste0("",urlpart[i])
          }else{ dom<-paste0(dom,".",urlpart[i])}

        }
      }
    } else if(length(urlpart)>3){
      dom<-0
      for (i in 1:(length(urlpart)-2)) {
        if(dom==0) { dom<-paste0("",urlpart[i])
        }else{ dom<-paste0(dom,".",urlpart[i])}
      }
    } else {
      dom<-0
      for (i in 1:(length(urlpart)-1)) {
        if(dom==0) { dom<-paste0("",urlpart[i])
        }else{ dom<-paste0(dom,".",urlpart[i])}
      }
    }

    if(dom!=0) rDomains<-c(rDomains,dom)
  }
  rDomains
}

IsSubDomain <-function(domain){
  dom<-getDomain(domain)
  issubdom<-FALSE
  if (length(strsplit(dom, split = ".",fixed = TRUE)[[1]])>=2) issubdom<-TRUE
  else issubdom<-FALSE
  issubdom
}

