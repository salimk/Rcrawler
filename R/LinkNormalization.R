#' Link Normalization
#'
#' A function that take a URL _charachter_ as input, and transforms it into a canonical form.
#' @param link character, the URL to Normalize.
#' @param current character, The URL of the current page source of the link.
#' @return return the simhash as a nmeric value
#' @author salim khalil
#' @details
#' This funcion call an external java class
#' @export
#'
#'
#'
LinkNormalization<-function(links, current){
  base <- strsplit(gsub("http://|https://|www\\.", "", current), "/")[[c(1, 1)]]
  base <- paste(base, "/", sep="")

  for(t in 1:length(links)){
    if (!is.na(links[t])){
      if(grepl("^\\s|\\s+$",links[t])) {links[t]<-gsub("^\\s|\\s+$", "", links[t] , perl=TRUE)}
      if (substr(links[t],1,1)=="." || substr(links[t],1,1)=="/"){ links[t]<-xml2::url_absolute(links[t], current) }
      #if(substr(link,1,1)=="/" && substr(link,1,2)!="//") { link<-paste("http://www.",base, link, sep="") }
      if(substr(links[t],1,7)!="http://") { links[t]<-paste("http://www.", links[t], sep="")}
      if(substr(links[t],1,10)!="http://www" && substr(links[t],1,7)=="http://") { links[t]<-gsub('(?<=:)(//)(?!www)','\\1www.',links[t],perl=T)}
      if(grepl("#",links[t])){links[t]<-gsub("\\#(.*)","",links[t])}
    }}
  links<-unique(links)
  return (links)
}
