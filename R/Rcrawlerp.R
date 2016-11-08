#' Rcrawler
#'
#' A function that take a _charachter_ as input, and generate it's simhash.
#' @param Website character, the root URL of the web site to crawl
#' @param no_cores integer, specify the number of clusters for parallel crawling, by default is the numbers of available cores – 1
#' @param MaxDepth integer, repsent the max deph level for the crawler, this is not the file depth in a directory structure, but 1+ number of links between this document and root document, default to 10
#' @param DIR character, correspond to the path of the local repository the crawler will use to store crawled data ex, "C:/collection" , by default R working directory
#'
#' @return return the simhash as a nmeric value
#' @author salim khalil
#' @details
#' This funcion call an external java class
#' for arabic use Sys.setlocale("LC_CTYPE","Arabic_Saudi Arabia.1256") and set encoding of the web page
#' @import  foreach doParallel parallel data.table
#' @export
#'
#'
#'
Rcrawler <- function(Website, no_cores,nbcon, MaxDepth, DIR, RequestsDelay=0, duplicatedetect=FALSE, Obeyrobots=FALSE, IndexErrPages, Useragent, Timeout=5, URLlenlimit=255, urlExtfilter, urlregexfilter, ignoreUrlParams, statslinks=FALSE, Encod, patterns, excludepattern, Backup=FALSE ) {
  if (missing(DIR)) DIR<-getwd()
  if (missing(ignoreUrlParams)) ignoreUrlParams<-""
  if (missing(MaxDepth)) MaxDepth<-10
  if (missing(no_cores)) no_cores<-parallel::detectCores()-1
  if (missing(nbcon)) nbcon<-no_cores
  if (missing(Obeyrobots)) Obeyrobots<-FALSE
  if (missing(IndexErrPages)) IndexErrPages<-c(200) else IndexErrPages<-c(200,IndexErrPages)
  if (missing(urlregexfilter)){ urlregexfilter<-".*" }
      else { urlregexfilter<-paste(urlregexfilter,collapse="|")}
  if(missing(Useragent)) {Useragent="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0"}
  if(missing(Encod)) {
    Encod<- Getencoding(Website)}
    else {Encod="UTF-8"}
  if(missing(urlExtfilter)){ urlExtfilter<-c("flv","mov","swf","txt","xml","js","css","zip","gz","rar","7z","tgz","tar","z","gzip","bzip","tar","mp3","mp4","aac","wav","au","wmv","avi","mpg","mpeg","pdf","doc","docx","xls","xlsx","ppt","pptx","jpg","jpeg","png","gif","psd","ico","bmp","odt","ods","odp","odb","odg","odf") }
  domain<-strsplit(gsub("http://|https://|www\\.", "", Website), "/")[[c(1, 1)]]
  if (Obeyrobots) {
    rules<-RobotParser(Website,Useragent)
    urlbotfiler<-rules[[2]]
    urlbotfiler<-gsub("^\\/", paste("http://www.",domain,"/", sep = ""), urlbotfiler , perl=TRUE)
    urlbotfiler<-gsub("\\*", ".*", urlbotfiler , perl=TRUE)
  } else {urlbotfiler=" "}

  #create repository
  path<-paste(DIR,"/",domain, sep = "")
  dir.create(path, recursive = TRUE, mode = "0777")
  if(Backup) {
    Fileindex <- file(paste(path,"/","index.csv", sep = ""), "w")
    Filefrontier <- file(paste(path,"/","frontier.csv", sep = ""), "w")
    Filestat<-file(paste(path,"/","state.txt", sep = ""), "w")
    }

  if(!missing(patterns)) {
    Filecontent <- file(paste(path,"/","extracted_contents.csv", sep = ""), "w")
      }

  #create Dataframe
  id<-vector()
  urls<-vector()
  links<-vector()
  status<-vector()
  level<-vector()
  inn<-numeric()
  out<-numeric()
  httpstat<-vector()
  contenttype<-vector()
  encoding<-vector()
  hashcode<-vector()
  allpaquet<-list()
  if (!missing(patterns)) { Exdata<<-list() }
  shema<<-data.frame(id,urls,status,level,out,inn,httpstat,contenttype,encoding,hashcode)
  names(shema) <- c("Id","Url","Stats","Level","OUT","IN","Http Resp","Content Type","Encoding","Hash")
  #
  #timev<<- vector()
  #timef<<-vector()
  shemav <- vector()
  shemav<-c(shemav,Website)
  t<-1
  M<-1
  lev<-0
  posx<-0
  #cluster initialisation
   cl <- makeCluster(no_cores)
  registerDoParallel(cl)
  clusterEvalQ(cl, library(xml2))
  clusterEvalQ(cl, library(httr))
  clusterExport(cl, c("LinkExtractor","LinkNormalization"))
  clusterExport(cl, c("shema"))
  #tmparallelreq<<-vector()
  #tmparallel<<-vector()
  #tminsertion<<-vector()
  #tminsertionreq<<-vector()
  while (t<=length(shemav) && MaxDepth!=lev){
    # extraire les liens sur la page
    rest<-length(shemav)-t
    if(rest==0){rest<-rest+1}
    if (nbcon<=rest){l<-t+nbcon} else { l<-t}
    #get links & pageinfo
    if (RequestsDelay!=0) {Sys.sleep(RequestsDelay)}
    #ptm <- proc.time()
        allpaquet <- foreach(i=t:l,  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass')  %dopar% {
          LinkExtractor(shemav[i],i,lev, IndexErrPages, Useragent, Timeout, URLlenlimit, urlExtfilter=urlExtfilter, statslinks=statslinks , encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams )
        }
    #for (j in t:l){
    #    cat(shemav[i]);
    #}
    #tmparallelreq<<-c(tmparallelreq,(proc.time() - ptm )[3])
    #tmparallel<<-c(tmparallel,format(Sys.time(), "%M,%S"))
    cat("In process : ")
    f<-l-t
    if(f==0){f<-f+1}
    # combine all links.package in one list & insert pageinfo in shema one-by-one
    for (s in 1:f){
      # pos :  Global positon (regarding to shemav)
      pos<-s+t-1
      cat(pos,"..")
     # timev[pos]<<-Sys.time()
     # timef[pos]<<-format(Sys.time(), "%M,%S")
      links<-c(links,allpaquet[[s]][2])
      # Les page null ne sont pas ajouter au shema
      #debugg<<-allpaquet
      #debugg2<<-shemav
      if (allpaquet[[s]][[1]][[3]]!="NULL" && allpaquet[[s]][[1]][[10]]!="NULL" ){
        #index filter
          if (grepl(urlregexfilter,allpaquet[[s]][[1]][[2]])) {
            #check for duplicate webpage & checksum calculation
            contentx<-allpaquet[[s]][[1]][[10]]
            if (duplicatedetect==TRUE){
            hash<-getsimHash(contentx,128)
            # Ajouter au shema uniqument les liens non-repeté
            if (!(hash %in% shema$hashcode)){
              # posx, actual position of DF shema
              posx<-posx+1
              shema[posx,]<<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],hash)
              filename<-paste(posx,".html")
              filepath<-paste(path,"/",filename, sep = "")
              write(allpaquet[[s]][[1]][[10]],filepath) }
            } else {
              posx<-posx+1
              shema[posx,]<<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],'')
              filename<-paste(posx,".html")
              filepath<-paste(path,"/",filename, sep = "")
              write(allpaquet[[s]][[1]][[10]],filepath)
              if (!missing(patterns)) {
                if (missing(excludepattern)){
                excontent<-contentscraper(webpage = allpaquet[[s]][[1]][[10]],patterns = patterns, encod=Encod )
                excontent<-c(posx,excontent)
                excontent2<-contentscraper(webpage = allpaquet[[s]][[1]][[10]],patterns = patterns, astext = FALSE, encod=Encod)
                Exdata<<-c(Exdata, list(excontent2))
                write.table(excontent, file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                }
                else {
                  x<<-allpaquet[[s]][[1]][[10]]
                excontent<-contentscraper(webpage = allpaquet[[s]][[1]][[10]],patterns = patterns, excludepat = excludepattern ,encod=Encod )
                excontent<-c(posx,excontent)
                excontent2<-contentscraper(webpage = allpaquet[[s]][[1]][[10]],patterns = patterns, astext = FALSE, excludepat = excludepattern, encod=Encod)
                Exdata<<-c(Exdata, list(excontent2))
                write.table(excontent, file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                }
              }
            }


          }
      #calculate level
      #if(M==pos){
       # M=nrow(shema)
        #lev<-lev+1}
      }
    }
    cat("\n")
    links <- unlist(links)
    links <- unique(links)
    # ptm <- proc.time()
    # remplir le shema
    if (length(links)>0){
      #for (i in 1:length(links)){
        # Ajouter au shema uniqument les urls non repet�
       # if (!(links[i] %in% shemav) ){
        #  shemav<-c(shemav,links[i])
          #shema[length(shemav),]<<-c(length(shemav),links[i],"waiting","","","1","","","")
        #}}
      shemav<-c( shemav , links[ ! links %chin% shemav ] )
      }
    #tminsertion<<-c(tminsertion,(proc.time() - ptm )[3])
    #tminsertionreq<<-c(tminsertionreq,format(Sys.time(), "%M,%S"))
    cat(t, " parssed from ",length(shemav), "\n")
    t<-t+f
  }
  close(Filecontent)
  #save(shema, file="masterma2.rda")
  stopImplicitCluster()
  rm(cl)
  return(shemav)
}

