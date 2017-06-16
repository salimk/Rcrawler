#' RobotParser fetch and parse robots.txt
#'
#' This function fetch and parse robots.txt file of the website which is specified in the first argument and return the list of correspending rules .
#' @param website character, url of the website which rules have to be extracted  .
#' @param useragent character, the useragent of the crawler
#' @return
#' return a list of three elements, the first is a character vector of Disallowed directories, the third is a Boolean value which is TRUE if the user agent of the crawler is blocked.
#' @import httr
#' @export
#'
#' @examples
#'
#' RobotParser("http://www.glofile.com","AgentX")
#' #Return robot.txt rules and check whether AgentX is blocked or not.
#'
#'
RobotParser <- function(website, useragent) {
  URLrobot<-paste(website,"/robots.txt", sep = "")
  bots<-GET(URLrobot, user_agent("Mozilla/5.0 (Windows NT 6.3; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0"),timeout(5))
  bots<-as.character(content(bots, as="text"))
  write(bots, file = "robots.txt")
  bots <- readLines("robots.txt") # dans le repertoire du site
  if (missing(useragent)) useragent<-"Rcrawler"
  useragent <- c(useragent, "*")
  ua_positions <- which(grepl( "[Uu]ser-[Aa]gent:[ ].+", bots))
  Disallow_dir<-vector()
  allow_dir<-vector()
  for (i in 1:length(useragent)){
    if (useragent[i] == "*") useragent[i]<-"\\*"
    Gua_pos <- which(grepl(paste("[Uu]ser-[Aa]gent:[ ]{0,}", useragent[i], "$", sep=""),bots))
    if (length(Gua_pos)!=0 ){
    Gua_rules_start <- Gua_pos+1
    Gua_rules_end <- ua_positions[which(ua_positions==Gua_pos)+1]-1
    if(is.na(Gua_rules_end)) Gua_rules_end<- length(bots)
    Gua_rules <- bots[Gua_rules_start:Gua_rules_end]
    Disallow_rules<-Gua_rules[grep("[Dd]isallow",Gua_rules)]
    Disallow_dir<-c(Disallow_dir,gsub(".*\\:.","",Disallow_rules))
    allow_rules<-Gua_rules[grep("^[Aa]llow",Gua_rules)]
    allow_dir<-c(allow_dir,gsub(".*\\:.","",allow_rules))
    }
    }
  if ("/" %in% Disallow_dir){
    Blocked=TRUE
    print ("This bot is blocked from the site")} else{ Blocked=FALSE }

  Rules<-list(Allow=allow_dir,Disallow=Disallow_dir,Blocked=Blocked )
  return (Rules)
  }
