<<<<<<< HEAD
#' ContentScraper
#'
#' From a given web page as text _character_ and a set of named XPath patterns, this function extracts selected parts of the HTML document then it returns a list of extracted contents.
#' @param webpage character, a web page as text.
#' @param patterns character vector, one or more XPath patterns to extract from the web page.
#' @param patnames character vector, given names for each xpath pattern to extract.
#' @param ManyPerPattern boolean, If False only the first matched element by the pattern is extracted (like in Blogs one page has one article/post and one title). Otherwise if set to True  all nodes matching the pattern are extracted (Like in galleries, listing or comments, one page has many elements with the same pattern )
#' @param excludepat character vector, one o more Xpath to exclude from the extracted content.
#' @param astext boolean, default is TRUE, HTML and PHP tags is stripped from the extracted piece.
#' @param encod character, set the weppage character encoding.
#' @return
#' return a named list of extracted content
#' @author salim khalil
#' @examples
#' \dontrun{
#' pageinfo<-LinkExtractor("http://glofile.com/index.php/2017/06/08/athletisme-m-a-rome/")
#' #Retreive the webpge header and data
#'
#' Data<-ContentScraper(pageinfo[[1]][[10]],c("//head/title","//*/article"),c("title", "article"))
#' #Extract the title and the article from webpage content using Xpaths
#' }
#' @import  xml2
#' @export
#'
#'
ContentScraper <- function(webpage, patterns, patnames, excludepat, ManyPerPattern=FALSE, astext=TRUE, encod) {
  x<-read_html(webpage, encoding = encod)
  if(ManyPerPattern){
    if (astext){
     content<-lapply(patterns,function(n) { tryCatch(xml_text(xml_find_all(x,n)),error=function(e) "" ) })
     #content<-c(paste0("Source=",urlsource),content)
    } else{
      content<-lapply(patterns,function(n) { tryCatch(xml_find_all(x,n),error=function(e) "" ) })
      #content<-c(paste0("Source=",urlsource),content)
    }
  } else {
  content<-lapply(patterns,function(n) { tryCatch(paste(xml_find_first(x,n)),error=function(e) "" ) })
  if (!missing(excludepat)){
  contoex<-lapply(excludepat,function(n) { tryCatch(paste(xml_find_first(x,n)),error=function(e) "" ) })
  }
    for( i in 1:length(content)) {
       if (!missing(excludepat)){
          for (j in 1:length(contoex)) {
                if (grepl(contoex[[j]], content[[i]], fixed = TRUE) && nchar(contoex[[j]])!=0 ){
                content[[i]]<-gsub(contoex[[j]],"", content[[i]], fixed = TRUE)
          }}
       }
        if(astext){
          content[[i]]<-gsub("<script\\b[^<]*>[^<]*(?:<(?!/script>)[^<]*)*</script>", "", content[[i]], perl=T)
          content[[i]]<-gsub("<.*?>", "", content[[i]])
          content[[i]]<-gsub(pattern = "\n" ," ", content[[i]])
          content[[i]]<-gsub("^\\s+|\\s+$", "", content[[i]])
        }
    }
  }

  if  (!missing(patnames)){
    for( i in 1:length(content)) {
      names(content)[i]<-patnames[[i]]
    }
  }

  return (content)
}
=======
#' ContentScraper
#'
#' From a given web page as text _character_ and a set of named XPath patterns, this function extracts selected parts of the HTML document then it returns a list of extracted contents.
#' @param webpage character, a web page as text.
#' @param patterns character vector, one or more XPath patterns to extract from the web page.
#' @param patnames character vector, given names for each xpath pattern to extract.
#' @param ManyPerPattern boolean, If False only the first matched element by the pattern is extracted (like in Blogs one page has one article/post and one title). Otherwise if set to True  all nodes matching the pattern are extracted (Like in galleries, listing or comments, one page has many elements with the same pattern )
#' @param excludepat character vector, one o more Xpath to exclude from the extracted content.
#' @param astext boolean, default is TRUE, HTML and PHP tags is stripped from the extracted piece.
#' @param encod character, set the weppage character encoding.
#' @return
#' return a named list of extracted content
#' @author salim khalil
#' @examples
#' \dontrun{
#' pageinfo<-LinkExtractor("http://glofile.com/index.php/2017/06/08/athletisme-m-a-rome/")
#' #Retreive the webpge header and data
#'
#' Data<-ContentScraper(pageinfo[[1]][[10]],c("//head/title","//*/article"),c("title", "article"))
#' #Extract the title and the article from webpage content using Xpaths
#' }
#' @import  xml2
#' @export
#'
#'
ContentScraper <- function(webpage, patterns, patnames, excludepat, ManyPerPattern=FALSE, astext=TRUE, encod) {
  x<-read_html(webpage, encoding = encod)
  if(ManyPerPattern){
    if (astext){
     content<-lapply(patterns,function(n) { tryCatch(xml_text(xml_find_all(x,n)),error=function(e) "" ) })
     #content<-c(paste0("Source=",urlsource),content)
    } else{
      content<-lapply(patterns,function(n) { tryCatch(xml_find_all(x,n),error=function(e) "" ) })
      #content<-c(paste0("Source=",urlsource),content)
    }
  } else {
  content<-lapply(patterns,function(n) { tryCatch(paste(xml_find_first(x,n)),error=function(e) "" ) })
  if (!missing(excludepat)){
  contoex<-lapply(excludepat,function(n) { tryCatch(paste(xml_find_first(x,n)),error=function(e) "" ) })
  }
    for( i in 1:length(content)) {
       if (!missing(excludepat)){
          for (j in 1:length(contoex)) {
                if (grepl(contoex[[j]], content[[i]], fixed = TRUE) && nchar(contoex[[j]])!=0 ){
                content[[i]]<-gsub(contoex[[j]],"", content[[i]], fixed = TRUE)
          }}
       }
        if(astext){
          content[[i]]<-gsub("<script\\b[^<]*>[^<]*(?:<(?!/script>)[^<]*)*</script>", "", content[[i]], perl=T)
          content[[i]]<-gsub("<.*?>", "", content[[i]])
          content[[i]]<-gsub(pattern = "\n" ," ", content[[i]])
          content[[i]]<-gsub("^\\s+|\\s+$", "", content[[i]])
        }
    }
  }

  if  (!missing(patnames)){
    for( i in 1:length(content)) {
      names(content)[i]<-patnames[[i]]
    }
  }

  return (content)
}
>>>>>>> origin/master
