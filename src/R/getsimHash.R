#' getsimHash
#'
#' A function that take a _charachter_ as input, and generate it's simhash.
#' @param string character, the content to hash.
#' @param hashbits  numeric, specify the hash bits 64 or 128
#' @return return the simhash as a nmeric value
#' @author salim khalil
#' @details
#' This funcion call an external java class
#' @importFrom  rJava .jnew
#' @importFrom  rJava .jcall
#' @importFrom  rJava .jstrVal
#' @export
#'
#'
#'
getsimHash<-function(string,hashbits){
  #.jaddClassPath("/src/SimHash.jar")
  oj<-.jnew("SimHash")
  fingerprint<-.jcall(oj,"S","getsimHash",as.character(string),as.integer(hashbits), evalString=FALSE)
  simHash<-.jstrVal(fingerprint)
  return (simHash)
}
getDistance<-function(s1,s2){
  if(nchar(s1) != nchar(s2)) {
    distance<--1
  } else {
    distance<-0
    for(i in 1:nchar(s1)){
      if(substr(s1, i, i)!=substr(s2, i, i)) {distance<-distance+1}
    } }
  return (distance)
}
