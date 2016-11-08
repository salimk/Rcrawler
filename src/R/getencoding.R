#' Getencoding
#'
#' A function that parse a web page content and retreive it's encoding charset based on content and HTTP header
#' @param url character, url to
#' @return return the encoding charset as character
#' @author salim khalil
#' @details
#' xxx
#' @seealso \code{other function}
#' @import httr xml2
#' @export
Getencoding <- function(url) {

  pag<-tryCatch(GET(url, user_agent("Mozilla/5.0 (Windows NT 6.3; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0"),timeout(5)) , error=function(e) NULL)
  page<-as.character(content(pag, type = "htmlTreeParse", as="text"))
  if (grepl("<meta http-equiv=\"Content-Type\"", page)) {
    enc<-xml_attr(xml_find_one(read_html(page),"//meta[@http-equiv=\'Content-Type\']"), "content")
    enc<-gsub(".*charset=([^\']*)","\\1",enc )
    #enc<-regmatches(page, gregexpr('charset=([^\'>]*)', page))[[1]][1]
    #enc<-gsub("(.*)=([^\'\"]*)\"","\\2",enc )
    } else if (grepl("<meta charset=", page)){

      enc<-regmatches(page, gregexpr('charset=([^\'>/]*)', page))[[1]][1]
      enc<-gsub("(.*)=\"([^\">]*)\"","\\2",enc )
    }
    else {
    head<-pag$headers$`content-type`
    enc<-regmatches(head, gregexpr('charset=([^\']*)', head))[[1]]
    enc<-gsub("(.*)=(.*)","\\2",enc )
  }
  enc<-toupper(enc)
  enc<-gsub("^\\s+|\\s+$", "", enc)
     return (enc)
}
