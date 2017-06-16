#' Rcrawler
#'
#' The crawler's main function, by providing only the website URL and the Xpath patterns to extract
#' this function can crawl the whole website (traverse web pages and collect links) and scrape/extract
#' its contents in an automated manner to produce a structured dataset. The process of a crawling
#' operation is performed by several concurrent processes or nodes in parallel, so it's recommended to
#' use 64bit version of R.
#'
#'
#' @param Website character, the root URL of the website to crawl and scrape.
#' @param no_cores integer, specify the number of clusters (logical cpu) for parallel crawling, by default it's the numbers of available cores.
#' @param no_conn integer, it's the number of concurrent connections per one core, by default it takes the same value of no_cores.
#' @param MaxDepth integer, repsents the max deph level for the crawler, this is not the file depth in a directory structure, but 1+ number of links between this document and root document, default to 10.
#' @param DIR character, correspond to the path of the local repository where all crawled data will be stored ex, "C:/collection" , by default R working directory.
#' @param RequestsDelay integer, The time interval between each round of parallel http requests, in seconds used to avoid overload the website server. default to 0.
#' @param duplicatedetect boolean, if true the crawler performs a near duplicate detection using SimHash algorithm to ignore documents that has been scraped.
#' @param Obeyrobots boolean, if TRUE, the crawler will parse the website\'s robots.txt file and obey its rules allowed and disallowed directories.
#' @param Useragent character, the User-Agent HTTP header that is supplied with any HTTP requests made by this function.it is important to simulate different browser's user-agent to continue crawling without getting banned.
#' @param Timeout integer, the maximum request time, the number of seconds to wait for a response until giving up, in order to prevent wasting time waiting for responses from slow servers or huge pages, default to 5 sec.
#' @param URLlenlimit integer, the maximum URL length limit to crawl, to avoid spider traps; default to 255.
#' @param urlExtfilter character's vector, by default the crawler avoid irrelevant files for data scraping such us xml,js,css,pdf,zip ...etc, it's not recommanded to change the default value until you can provide all the list of filetypes to be escaped.
#' @param urlregexfilter character's vector, filter crawled Urls by regular expression pattern, this is useful when you try to scrape content or index only specific web pages (product pages, post pages).
#' @param ignoreUrlParams character's vector, the list of Url paremeter to be ignored during crawling .
#' @param statslinks boolean, if TRUE, the crawler counts the number of input and output links of each crawled web page.
#' @param Encod character, set the website caharacter encoding, by default the crawler will automatically detect the website defined character encoding.
#' @param ExtractPatterns character's vector, vector of xpath patterns to use for data extraction process.
#' @param PatternsNames character vector, given names for each xpath pattern to extract.
#' @param ExcludePatterns character's vector, vector of xpath patterns to exclude from selected ExtractPatterns.
#' @param ExtractAsText boolean, default is TRUE, HTML and PHP tags is stripped from the extracted piece.
#'
#'
#' @return
#'
#' The crawling and scraping process may take a long time to finish, therefore, to avoid data loss in the case that a function crashes or stopped in the middle of action, some important data are exported at every iteration to R global environement:
#'
#' - INDEX: A data frame in global environement representing the generic URL index,including the list of fetched URLs and page details
#'   (contenttype,HTTP state, number of out-links and in-links, encoding type, and level).
#'
#' - A repository in workspace that contains all downloaded pages (.html files)
#'
#' In addition, if data scraping is enabled :
#'
#' - DATA: A vector in global environement contains scraped contents.
#'
#' - A csv file 'extracted_contents.csv' holding all extracted data.
#'
#' @details
#'
#' To start Rcrawler task you need the provide the root URL of the website you want to scrape, it can be a domain, a subdomain or a website section (eg. http://www.domain.com, http://sub.domain.com or http://www.domain.com/section/). The crawler then will go through all its internal links. The process of a crawling is performed by several concurrent processes or nodes in parallel, So, It is recommended to use R 64-bit version.
#'
#' For complexe charcter content such as arabic execute Sys.setlocale("LC_CTYPE","Arabic_Saudi Arabia.1256") then set the encoding of the web page in Rcrawler function.
#'
#' If you want to learn more about web scraper/crawler architecture, functional properties and implementation using R language, Follow this link and download the published paper for free .
#'
#' Link: http://www.sciencedirect.com/science/article/pii/S2352711017300110
#'
#' Don't forget to cite Rcrawler paper:
#'
#' Khalil, S., & Fakir, M. (2017). RCrawler: An R package for parallel web crawling and scraping. SoftwareX, 6, 98-106.
#'
#'  @examples
#'
#' \\dontrun{
#'  Rcrawler(Website ="http://glofile.com/", no_cores = 2, no_conn = 6)
#'  #Crawl, index, and store web pages using 2 cores and 2 parallel requests
#'
#'  #Rcrawler(Website = "http://glofile.com/", urlregexfilter =  "/\\d{4}/\\d{2}/",
#'  ExtractPatterns = c("//*/article","//*/h1"), PatternsNames = c("content","title"))
#'
#'  #Crawl the website using the default configuration and scrape content matching two XPath
#'   patterns only from post pages matching a specific regular expression. Note that the user can
#'   use the excludepattern  parameter to exclude a node from being extracted,
#'   e.g., in the case that a desired node includes (is a parent of) an undesired "child" node.
#'   Rcrawler(Website = "http://www.example.com/", no_cores=8, no_conn=8, Obeyrobots = TRUE,
#'  Useragent="Mozilla 3.11")
#'
#'  # Crawl and index the website using 8 cores and 8 parallel requests with respect to
#'  robot.txt rules.
#'
#'  Rcrawler(Website = "http://www.example.com/", no_cores = 4, no_conn = 4,
#'  urlregexfilter =  "/\\d{4}/\\d{2}/", DIR = "./myrepo", MaxDepth=3)
#'
#'  # Crawl the website using  4 cores and 4 parallel requests. However, this will only
#'   index URLs matching the regular expression pattern (/\\d{4}/\\d{2}/), and stores pages
#'   in a custom directory "myrepo". The crawler stops when it reaches the third level.
#'
#' }
#'
#' @author salim khalil
#' @import foreach doParallel parallel data.table
#' @export
#' @importFrom utils write.table
#' @importFrom utils flush.console

#'


Rcrawler <- function(Website, no_cores,no_conn, MaxDepth, DIR, RequestsDelay=0,
                     duplicatedetect=FALSE, Obeyrobots=FALSE,
                     Useragent, Timeout=5, URLlenlimit=255, urlExtfilter,
                     urlregexfilter, ignoreUrlParams, statslinks=FALSE, Encod,
                     ExtractPatterns,PatternsNames,ExcludePatterns,ExtractAsText=TRUE) {

  if (missing(DIR)) DIR<-getwd()
  if (missing(ignoreUrlParams)) ignoreUrlParams<-""
  if (missing(MaxDepth)) MaxDepth<-10
  if (missing(no_cores)) no_cores<-parallel::detectCores()-1
  if (missing(no_conn)) no_conn<-no_cores
  if (missing(Obeyrobots)) Obeyrobots<-FALSE
  if (missing(urlregexfilter)){ urlregexfilter<-".*" }
      else { urlregexfilter<-paste(urlregexfilter,collapse="|")}
  if(missing(Useragent)) {Useragent="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0"}
  if(missing(Encod)) {
    Encod<- Getencoding(Website)
    if (Encod=="NULL") { Encod="UTF-8" }
    }
  if(missing(urlExtfilter)){ urlExtfilter<-c("flv","mov","swf","txt","xml","js","css","zip","gz","rar","7z","tgz","tar","z","gzip","bzip","tar","mp3","mp4","aac","wav","au","wmv","avi","mpg","mpeg","pdf","doc","docx","xls","xlsx","ppt","pptx","jpg","jpeg","png","gif","psd","ico","bmp","odt","ods","odp","odb","odg","odf") }

  domain<-strsplit(gsub("http://|https://|www\\.", "", Website), "/")[[c(1, 1)]]

  if (Obeyrobots) {
    rules<-RobotParser(Website,Useragent)
    urlbotfiler<-rules[[2]]
    urlbotfiler<-gsub("^\\/", paste("http://www.",domain,"/", sep = ""), urlbotfiler , perl=TRUE)
    urlbotfiler<-gsub("\\*", ".*", urlbotfiler , perl=TRUE)
  } else {urlbotfiler=" "}


  IndexErrPages<-c(200)

  #create repository
  path<-paste(DIR,"/",domain, sep = "")
  dir.create(path, recursive = TRUE, mode = "0777")
  #if(Backup) {
  #   Fileindex <- file(paste(path,"/","index.csv", sep = ""), "w")
  #  Filefrontier <- file(paste(path,"/","frontier.csv", sep = ""), "w")
  #  Filestat<-file(paste(path,"/","state.txt", sep = ""), "w")
  #  }

  if(!missing(ExtractPatterns)) {
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
  pkg.env <- new.env()
  if (!missing(ExtractPatterns)) { pkg.env$Exdata<-list() }
  pkg.env$shema<-data.frame(id,urls,status,level,out,inn,httpstat,contenttype,encoding,hashcode)
  names(pkg.env$shema) <- c("Id","Url","Stats","Level","OUT","IN","Http Resp","Content Type","Encoding","Hash")
  #
  #timev<<- vector()
  #timef<<-vector()
  shemav <- vector()
  shemav<-c(shemav,Website)
  t<-1
  M<-1
  lev<-0
  posx<-0
  i<-0
  posenv <- 1
  envi = as.environment(posenv)
  #cluster initialisation
   cl <- makeCluster(no_cores)
  registerDoParallel(cl)
  clusterEvalQ(cl, library(xml2))
  clusterEvalQ(cl, library(httr))
  clusterExport(cl, c("LinkExtractor","LinkNormalization"))
  clusterExport(cl, c("shema"),envir = pkg.env)
  #tmparallelreq<<-vector()
  #tmparallel<<-vector()
  #tminsertion<<-vector()
  #tminsertionreq<<-vector()
  while (t<=length(shemav) && MaxDepth!=lev){
    # extraire les liens sur la page
    rest<-length(shemav)-t
   #if(rest==0){ rest<-rest+1 }

    if (no_conn<rest){
      l<-t+no_conn-1
    } else {
      l<-t+rest
    }
    #cat("l:",l)
    #get links & pageinfo
    if (RequestsDelay!=0) {Sys.sleep(RequestsDelay)}
    #ptm <- proc.time()
        allpaquet <- foreach(i=t:l,  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass')  %dopar%
          {
          LinkExtractor(shemav[i],i,lev, IndexErrPages, Useragent, Timeout, URLlenlimit, urlExtfilter=urlExtfilter, statslinks=statslinks , encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams )
          }
    # deb<<-allpaquet
    #for (j in t:l){
    #    cat(shemav[i]);
    #}
    #tmparallelreq<<-c(tmparallelreq,(proc.time() - ptm )[3])
    #tmparallel<<-c(tmparallel,format(Sys.time(), "%M,%S"))
    cat("In process : ")
    if (no_conn<rest){
      f<-no_conn
    } else if (no_conn>rest) {
      f<-rest
    }
    if(0==rest) {
      f<-l-t+1
    }
    #cat("f:",f,"t:",t,"conn",no_conn,"r:",rest)
    #if(f==0){f<-f+1}
    # combine all links.package in one list & insert pageinfo in shema one-by-one
    for (s in 1:f){
      # pos :  Global positon (regarding to shemav)
      pos<-s+t-1
      cat(pos,"..")
      flush.console()
     # timev[pos]<<-Sys.time()
     # timef[pos]<<-format(Sys.time(), "%M,%S")
      links<-c(links,allpaquet[[s]][2])
      # Les page null ne sont pas ajouter au shema
      #debugg<<-allpaquet
      #debugg2<<-shemav
      if(!is.null(allpaquet[[s]][[2]])){
          if (allpaquet[[s]][[1]][[3]]!="NULL" && allpaquet[[s]][[1]][[10]]!="NULL" ){
        #index filter
          if (grepl(urlregexfilter,allpaquet[[s]][[1]][[2]])) {
            #check for duplicate webpage & checksum calculation
            contentx<-allpaquet[[s]][[1]][[10]]
            if (duplicatedetect==TRUE){
            hash<-getsimHash(contentx,128)
            # Ajouter au shema uniqument les liens non-repete
            if (!(hash %in% pkg.env$shema$hashcode)){
              # posx, actual position of DF shema
              posx<-posx+1
              pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],hash)
              filename<-paste(posx,".html")
              filepath<-paste(path,"/",filename, sep = "")
              write(allpaquet[[s]][[1]][[10]],filepath) }
            } else {
              posx<-posx+1
              pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],'')
              filename<-paste(posx,".html")
              filepath<-paste(path,"/",filename, sep = "")
              write(allpaquet[[s]][[1]][[10]],filepath)
              if (!missing(ExtractPatterns)) {
                if (missing(ExcludePatterns)){
                excontent<-ContentScraper(webpage = allpaquet[[s]][[1]][[10]],patterns = ExtractPatterns, patnames = PatternsNames, encod=Encod )
                excontent<-c(posx,excontent)
                excontent2<-ContentScraper(webpage = allpaquet[[s]][[1]][[10]],patterns = ExtractPatterns,patnames = PatternsNames, astext = ExtractAsText, encod=Encod)
                pkg.env$Exdata<-c(pkg.env$Exdata, list(excontent2))
                write.table(excontent, file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                }
                else {
                  #x<<-allpaquet[[s]][[1]][[10]]
                excontent<-ContentScraper(webpage = allpaquet[[s]][[1]][[10]],patterns = ExtractPatterns, patnames = PatternsNames, excludepat = ExcludePatterns ,encod=Encod )
                excontent<-c(posx,excontent)
                excontent2<-ContentScraper(webpage = allpaquet[[s]][[1]][[10]],patterns = ExtractPatterns, patnames = PatternsNames, astext = ExtractAsText, excludepat = ExcludePatterns, encod=Encod)
                pkg.env$Exdata<-c(pkg.env$Exdata, list(excontent2))
                write.table(excontent, file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                }

                assign("DATA", pkg.env$Exdata, envir = envi )
              }
            }
          }
      #calculate level
      #if(M==pos){
       # M=nrow(shema)
        #lev<-lev+1}
      }
      }
    }
    cat("\n")
    links <- unlist(links)
    links <- unique(links)
    # ptm <- proc.time()
    # remplir le shema
    if (length(links)>0){
      #for (i in 1:length(links)){
        # Ajouter au shema uniqument les urls non repete
       # if (!(links[i] %in% shemav) ){
        #  shemav<-c(shemav,links[i])
          #shema[length(shemav),]<<-c(length(shemav),links[i],"waiting","","","1","","","")
        #}}
      shemav<-c( shemav , links[ ! links %chin% shemav ] )
      }
    #tminsertion<<-c(tminsertion,(proc.time() - ptm )[3])
    #tminsertionreq<<-c(tminsertionreq,format(Sys.time(), "%M,%S"))
    cat(format(round(((t/length(shemav))*100), 2),nsmall = 2),"%  : ",t, " parssed from ",length(shemav),"\n")

    t<-l+1
    assign("INDEX", pkg.env$shema, envir = envi )
   #tmp<<-shemav
  }
  if(!missing(ExtractPatterns)) {
    close(Filecontent)
  }

  #save(shema, file="masterma2.rda")
  stopCluster(cl)
  stopImplicitCluster()
  rm(cl)

  return(pkg.env$shema)
}

