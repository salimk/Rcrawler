#' Link Normalization
#'
#' To normalize and transform URLs into a canonical form.
#'
#' @param links character, one or more URLs to Normalize.
#' @param current character, The current page URL where links are located
#' @return
#' Vector of normalized urls
#'
#' @author salim khalil
#'
#' @export
#'
#' @examples
#'
#' # Normalize a set of links
#'
#' links<-c("http://www.twitter.com/share?url=http://glofile.com/page.html",
#'          "/finance/banks/page-2017.html",
#'          "./section/subscription.php",
#'          "//section/",
#'          "www.glofile.com/home/",
#'          "IndexEn.aspx",
#'          "glofile.com/sport/foot/page.html",
#'          "sub.glofile.com/index.php",
#'          "http://glofile.com/page.html#1",
#'          "?tags%5B%5D=votingrights&amp;sort=popular"
#'                    )
#'
#' links<-LinkNormalization(links,"http://glofile.com" )
#'
#' links
#'
#'
LinkNormalization<-function(links, current){
  protocole<-strsplit(current, "/")[[c(1,1)]]
  base <- strsplit(gsub("http://|https://", "", current), "/")[[c(1, 1)]]
  base2 <- strsplit(gsub("http://|https://|www\\.", "", current), "/")[[c(1, 1)]]
  rlinks<-c();
  #base <- paste(base, "/", sep="")

  for(t in 1:length(links)){
    #debugg<<-links[t]
    #debugg2<<-current
    if (!is.null(links[t]) && length(links[t]) == 1){
      if (!is.na(links[t])){
       if(substr(links[t],1,2)!="//"){
        if(sum(gregexpr("http", links[t], fixed=TRUE)[[1]] > 0)<2){
            # remove spaces
            if(grepl("^\\s|\\s+$",links[t])) {links[t]<-gsub("^\\s|\\s+$", "", links[t] , perl=TRUE)}

            #if starts with / add base
            if (substr(links[t],1,1)=="/"){
                links[t]<-paste0(protocole,"//",base,links[t])
            }
            #if sarts with ./ add base
            else if (substr(links[t],1,2)=="./") {
            # la url current se termine par /
              if(substring(current, nchar(current)) == "/"){
                      links[t]<-paste0(current,gsub("\\./", "",links[t]))
            # si non
              } else {
                      links[t]<-paste0(current,gsub("\\./", "/",links[t]))
              }

            # if sarts with www add base
            } else if (substr(links[t],1,3)=="www"){
                links[t]<-paste0(protocole,"//",links[t])

              # if sarts with ?
            }else if (substr(links[t],1,1)=="?"){
                if(substring(current, nchar(current)) == "/"){
                  links[t]<-paste0(current,links[t])
                  # si non
                } else {
                  links[t]<-paste0(current,"/",links[t])
                }

            # if sarts with current domain
            } else if(grepl( pattern = paste0("^",gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", base2,ignore.case = TRUE),".*"),x =links[t])){
              if(grepl( pattern ="www",current ,ignore.case = TRUE)){
                  links[t]<-paste0(protocole,"//www.",links[t])
              }else {
                  links[t]<-paste0(protocole,"//",links[t])
              }

            # if sarts with subdomain
            } else if(substr(links[t],1,7)!="http://" && substr(links[t],1,8)!="https://" && substr(links[t],1,3)!="www"
                      && grepl( pattern = paste0("[A-Za-z]*",gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", paste0(".",base2),".*")), x = links[t], ignore.case = TRUE)){
              links[t]<-paste0(protocole,"//",links[t])
              # if relative
            } else if(substr(links[t],1,7)!="http://" && substr(links[t],1,8)!="https://" && substr(links[t],1,3)!="www"
                      && !grepl( pattern = paste0(".*",gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1",base2,".*")), x = links[t], ignore.case = TRUE) ){
              if(substring(current, nchar(current)) == "/"){
                links[t]<-paste0(current,links[t])
                # si non
              } else {
                links[t]<-paste0(current,"/",links[t])
              }
            }

            if(grepl("#",links[t])){links[t]<-gsub("\\#(.*)","",links[t])}

            rlinks <- c(rlinks,links[t])
        }
      }
     }
    }
  }
  rlinks<-unique(rlinks)
  return (rlinks)
}
