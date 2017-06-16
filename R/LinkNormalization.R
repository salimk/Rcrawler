#' Link Normalization
#'
#' A function that take a URL _charachter_ as input, and transforms it into a canonical form.
#' @param links character, the URL to Normalize.
#' @param current character, The URL of the current page source of the link.
#' @return
#' return the simhash as a nmeric value
#' @author salim khalil
#' @details
#' This funcion call an external java class
#' @export
#'
#' @examples
#'
#' # Normalize a set of links
#'
#' links<-c("/finance/banks/page-2017.html",
#'          "./section/subscription.php",
#'          "www.glofile.com/home/",
#'          "glofile.com/sport/foot/page.html",
#'          "sub.glofile.com/index.php",
#'          "http://glofile.com/page.html#1"
#'                    )
#'
#' links<-LinkNormalization(links,"http://glofile.com" )
#'
#'
LinkNormalization<-function(links, current){
  #base <- strsplit(gsub("http://|https://|www\\.", "", current), "/")[[c(1, 1)]]
  base <- strsplit(gsub("http://|https://", "", current), "/")[[c(1, 1)]]
  base2 <- strsplit(gsub("http://|https://|www\\.", "", current), "/")[[c(1, 1)]]

  #base <- paste(base, "/", sep="")

  for(t in 1:length(links)){
    #debugg<<-links[t]
    #debugg2<<-current
    if (!is.null(links[t])){
      if (!is.na(links[t])){
        if(grepl("^\\s|\\s+$",links[t])) {links[t]<-gsub("^\\s|\\s+$", "", links[t] , perl=TRUE)}
        #if starts with /  , add base
        if (substr(links[t],1,1)=="/"){ links[t]<-paste0("http://",base,links[t]) }
        #if sarts with . add base
        if (substr(links[t],1,1)==".") {
                if(substring(current, nchar(current)) == "/"){ links[t]<-paste0(current,gsub("\\./", "",links[t]))
                } else {
                  links[t]<-paste0(current,gsub("\\./", "/",links[t]))
                }
        }
        #if(substr(link,1,1)=="/" && substr(link,1,2)!="//") { link<-paste("http://www.",base, link, sep="") }

         if(substr(links[t],1,7)!="http://" && grepl(base2,links[t])) {
           links[t]<-paste0("http://",links[t])
           }

         if(substr(links[t],1,10)!="http://www" && substr(links[t],1,7)=="http://") { links[t]<-gsub('(?<=:)(//)(?!www)','\\1www.',links[t],perl=T)}

        if(substr(current,1,10)=="http://www") {
           if(substr(links[t],1,10)!="http://www" && substr(links[t],1,7)=="http://" ){ links[t]<-gsub('(?<=:)(//)(?!www)','\\1www.',links[t],perl=T)}
        } else {
          if(substr(links[t],1,10)=="http://www"){ links[t]<-gsub("www.","",links[t])}
          }
        if(grepl("#",links[t])){links[t]<-gsub("\\#(.*)","",links[t])}
      }
    }
  }
  links<-unique(links)
  return (links)
}
