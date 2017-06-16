#' Calculate SimHash fingerprint in R
#'
#' A function that take a _charachter_ as input, and generate it's simhash.
#' @param string character, the content to hash.
#' @param hashbits numeric, specify the hash bits 64 or 128
#'
#' @return
#' return the simhash as a nmeric value
#' @author salim khalil
#' @details
#' This funcion call an external java class
#' @importFrom  rJava .jnew
#' @importFrom  rJava .jcall
#' @importFrom  rJava .jstrVal
#' @export
#' @examples
#'
#' text<-"R is a free software environment for statistical computing and graphics.
#'       It compiles and runs on a wide variety of UNIX platforms, Windows and MacOS"
#' fingerprint<-getsimHash(text,64)
#'
#'
getsimHash<-function(string,hashbits){
  #.jaddClassPath("/src/SimHash.jar")
  oj<-.jnew("SimHash")
  fingerprint<-.jcall(oj,"S","getsimHash",as.character(string),as.integer(hashbits), evalString=FALSE)
  simHash<-.jstrVal(fingerprint)
  return (simHash)
}
