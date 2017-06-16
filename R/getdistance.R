#' Calculate Distance between two SimHash fingerprint
#'
#' A function that calculate the distance between two given fingerprint a _charachter_, distance is equal to 0 means the two strings are similar 100%.
#' @param s1 character, the first fingerprint
#' @param s2 character, the second fingerprint
#'
#' @return
#' return the distance as a nmeric value
#' @author salim khalil
#' @examples
#'
#'  text1<-"R is a free software environment for statistical computing and graphics.
#'          It compiles and runs on a wide variety of UNIX platforms, Windows and MacOS"
#'  text2<-"R is a language and environment for statistical computing and graphics.
#'          It is a GNU project which is similar to the S language and at Bell Laboratories"
#'  text3<-" Astronomy is the scientific study of all objects beyond our world,
#'            and a way to understand the physical laws and origins of the universe."
#'
#'  dist1<-getDistance(getsimHash(text1,64),getsimHash(text2,64))
#'  #dist1 is equal to 7, means the two strings are near-duplicate.
#'
#'  dist2<-getDistance(getsimHash(text1,64),getsimHash(text3,64))
#'  #dist2 is equal to 21, means the two strings are not similar.
#'
#'
#' @export
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
