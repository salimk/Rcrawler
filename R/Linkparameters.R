#' Get the list of parameters and values from an URL
#'
#' A function that take a URL _charachter_ as input, and extract the parameters and values from this URL .
#' @param URL character, the URL to extract
#' @return return the URL paremeters=values
#' @author salim khalil
#' @details
#' This function extract the link parameters and values (Up to 10 parameters)
#' @export
#' @examples
#'
#' Linkparameters("http://www.glogile.com/index.php?name=jake&age=23&template=2&filter=true")
#' # Extract all URL parameters with values as vector
#'
Linkparameters<-function(URL){
  str<-URL
if (grepl("\\?",str)) {
  no_param<-gregexpr("\\&", str)[[1]]
  paramsv<-vector()
  if (no_param[1]<0) {
    paramsv<-sub(".*\\?(.*)","\\1", str)
  } else {
    pa1<-".*\\?(.*)"
    if (length(gregexpr("\\&", str)[[1]])>=1){
      for(k in 1:(length(gregexpr("\\&", str)[[1]]))){
      pa1<-paste(pa1,"\\&(.*)", sep="")
      }
    for(k in 1:(length(gregexpr("\\&", str)[[1]])+1)){
        pa<-paste("\\",k, sep="")
        paramsv<-c(paramsv,sub(pa1,pa, str))
      }}
      }
  } else paramsv<-"NULL"
return(paramsv)
}
