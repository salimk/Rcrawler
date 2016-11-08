#' contentscraper
#'
#' A function for extracting content matching a specific XPath patterns from a web page, the function takes a web page text as _character_ and a set of named patterns then it return a list contining content matching patterns
#' @param webpage character, a web page as text
#' @param patterns  character vector, one or more XPath patterns to extract from the web page
#' @param patnames character vector, names of patterns
#' @return return a named list of extracted content
#' @author salim khalil
#' @details
#' contentscraper(x ,c("//head/title","//body/div/article"),c("title", "article"))
#' @import  xml2
#' @export
#'
contentscraper <- function(webpage, patterns, patnames, excludepat, astext=TRUE, encod) {
  x<-read_html(webpage, encoding = encod)
  content<-lapply(patterns,function(n) { tryCatch(paste(xml_find_one(x,n)),error=function(e) "" ) })
  if (!missing(excludepat)){
  contoex<-lapply(excludepat,function(n) { tryCatch(paste(xml_find_one(x,n)),error=function(e) "" ) })
  }

  for( i in 1:length(content)) {
   if (!missing(excludepat)){
      for (j in 1:length(contoex)) {
            if (grepl(contoex[[j]], content[[i]], fixed = TRUE) && nchar(contoex[[j]])!=0 ){
            content[[i]]<-gsub(contoex[[j]],"", content[[i]], fixed = TRUE)
      }}
   }
    if(astext){
      content[[i]]<-gsub("<.*?>", "", content[[i]])
      content[[i]]<-gsub(pattern = "\n" ," ", content[[i]])
      content[[i]]<-gsub("^\\s+|\\s+$", "", content[[i]])
    }

  }


  if  (!missing(patnames)){
    for( i in 1:length(content)) {
      names(content)[i]<-patnames[[i]]
    }
  }

  return (content)
}
