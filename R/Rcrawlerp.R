#' Rcrawler
#'
#' The crawler's main function, by providing only the website URL and the Xpath or CSS selector patterns
#' this function can crawl the whole website (traverse all web pages) download webpages, and scrape/extract
#' its contents in an automated manner to produce a structured dataset. The process of a crawling
#' operation is performed by several concurrent processes or nodes in parallel, so it's recommended to
#' use 64bit version of R.
#'
#'
#' @param Website character, the root URL of the website to crawl and scrape.
#' @param no_cores integer, specify the number of clusters (logical cpu) for parallel crawling, by default it's the numbers of available cores.
#' @param no_conn integer, it's the number of concurrent connections per one core, by default it takes the same value of no_cores.
#' @param MaxDepth integer, repsents the max deph level for the crawler, this is not the file depth in a directory structure, but 1+ number of links between this document and root document, default to 10.
#' @param RequestsDelay integer, The time interval between each round of parallel http requests, in seconds used to avoid overload the website server. default to 0.
#' @param Obeyrobots boolean, if TRUE, the crawler will parse the website\'s robots.txt file and obey its rules allowed and disallowed directories.
#' @param Useragent character, the User-Agent HTTP header that is supplied with any HTTP requests made by this function.it is important to simulate different browser's user-agent to continue crawling without getting banned.
#' @param use_proxy object created by httr::use_proxy() function, if you want to use a proxy (does not work with webdriver).
#' @param Timeout integer, the maximum request time, the number of seconds to wait for a response until giving up, in order to prevent wasting time waiting for responses from slow servers or huge pages, default to 5 sec.
#' @param URLlenlimit integer, the maximum URL length limit to crawl, to avoid spider traps; default to 255.
#' @param urlExtfilter character's vector, by default the crawler avoid irrelevant files for data scraping such us xml,js,css,pdf,zip ...etc, it's not recommanded to change the default value until you can provide all the list of filetypes to be escaped.
#' @param crawlUrlfilter character's vector, filter Urls to be crawled by one or more regular expression patterns. Useful for large websites to control the crawler behaviour and which URLs should be crawled. For example, In case you want to crawl a website's search resutls (guided/oriented crawling). without start ^ and end $ regex.
#' @param dataUrlfilter character's vector, filter Urls to be scraped/collected by one or more regular expression patterns.Useful to control which pages should be collected/scraped, like product, post, detail or category pages if they have a commun URL pattern. without start ^ and end $ regex.
#' @param crawlZoneCSSPat one or more css pattern of page sections from where the crawler should gather links to be followed, to avoid navigating through all visible links and to have more control over the crawler behaviour in target website.
#' @param crawlZoneXPath one or more xpath pattern of page sections from where the crawler should gather links to be followed.
#' @param ignoreUrlParams character's vector, the list of Url paremeter to be ignored during crawling. Some URL parameters are ony related to template view if not ignored will cause duplicate page (many web pages having the same content but have different URLs) .
#' @param ignoreAllUrlParams, boolean, choose to ignore all Url parameter after "?" (Not recommended for Non-SEF CMS websites because only the index.php will be crawled)
#' @param statslinks boolean, if TRUE, the crawler counts the number of input and output links of each crawled web page.
#' @param DIR character, correspond to the path of the local repository where all crawled data will be stored ex, "C:/collection" , by default R working directory.
#' @param saveOnDisk boolean, By default is true, the crawler will store crawled Html pages and extracted data CSV file on a specific folder. On the other hand you may wish to have DATA only in memory.
#' @param KeywordsFilter character vector,  For users who desires to scrape or collect only web pages that contains some keywords one or more. Rcrawler calculate an accuracy score based of the number of founded keywords. This parameter must be a vector with at least one keyword like c("mykeyword").
#' @param KeywordsAccuracy integer value range bewteen 0 and 100, used only with KeywordsFilter parameter to determine the accuracy of web pages to collect. The web page Accuracy value is calculated using the number of matched keywords and their occurence.
#' @param FUNPageFilter function, filter out pages to be collected/scraped by a custom function (conditions, prediction, calssification model). This function should take a \link{LinkExtractor} object as arument then finally returns TRUE or FALSE.
#' @param Encod character, set the website caharacter encoding, by default the crawler will automatically detect the website defined character encoding.
#' @param ExtractXpathPat character's vector, vector of xpath patterns to match for data extraction process.
#' @param ExtractCSSPat character's vector, vector of CSS selector pattern to match for data extraction process.
#' @param PatternsNames character vector, given names for each xpath pattern to extract.
#' @param ExcludeXpathPat character's vector, one or more Xpath pattern to exclude from extracted content ExtractCSSPat or ExtractXpathPat (like excluding quotes from forum replies or excluding middle ads from Blog post) .
#' @param ExcludeCSSPat character's vector, similar to ExcludeXpathPat but using Css selectors.
#' @param ExtractAsText boolean, default is TRUE, HTML and PHP tags is stripped from the extracted piece.
#' @param ManyPerPattern boolean, ManyPerPattern boolean, If False only the first matched element by the pattern is extracted (like in Blogs one page has one article/post and one title). Otherwise if set to True  all nodes matching the pattern are extracted (Like in galleries, listing or comments, one page has many elements with the same pattern )
#' @param NetworkData boolean, If set to TRUE, then the crawler map all the internal hyperlink connections within the given website and return DATA for Network construction using igraph or other tools.(two global variables is returned see details)
#' @param NetwExtLinks boolean, If TRUE external hyperlinks (outlinks) also will be counted on Network edges and nodes.
#' @param Vbrowser boolean, If TRUE the crawler will use web driver phantomsjs (virtual browser) to fetch and parse web pages instead of GET request
#' @param LoggedSession A loggedin browser session object, created by \link{LoginSession} function
#' @param IndexErrPages character vector, http error code-statut that can be processed, by default, it's \code{IndexErrPages<-c(200)} which means only successfull page request should be parsed .Eg, To parse also 404 error pages add, \code{IndexErrPages<-c(200,404)}.
#' @return
#'
#' The crawling and scraping process may take a long time to finish, therefore, to avoid data loss in the case that a function crashes or stopped in the middle of action, some important data are exported at every iteration to R global environement:
#'
#' - INDEX: A data frame in global environement representing the generic URL index,including the list of fetched URLs and page details
#'   (contenttype,HTTP state, number of out-links and in-links, encoding type, and level).
#'
#' - A repository in workspace that contains all downloaded pages (.html files)
#'
#' Data scraping is enabled by setting ExtractXpathPat or ExtractCSSPat parameter:
#'
#' - DATA: A list of lists in global environement holding scraped contents.
#'
#' - A csv file 'extracted_contents.csv' holding all extracted data.
#'
#' If NetworkData is set to TRUE two additional global variables returned by the function are:
#'
#' - NetwIndex : Vector maps alls hyperlinks (nodes) with a unique integer ID
#'
#' - NetwEdges : data.frame representing edges of the network, with these column : From, To, Weight (the Depth level where the link connection has been discovered) and Type (1 for internal hyperlinks 2 for external hyperlinks).
#'
#' @details
#'
#' To start Rcrawler task you need to provide the root URL of the website you want to scrape, it could be a domain, a subdomain or a website section (eg. http://www.domain.com, http://sub.domain.com or http://www.domain.com/section/).
#' The crawler then will retreive the web page and go through all its internal links. The crawler continue to follow and parse all website's links automatically on the site until all website's pages have been parsed.
#'
#' The process of a crawling is performed by several concurrent processes or nodes in parallel, So, It is recommended to use R 64-bit version.
#'
#' For more tutorials check https://github.com/salimk/Rcrawler/
#'
#' To scrape content with complex character such as Arabic or Chinese, you need to run Sys.setlocale function then set the appropriate encoding in Rcrawler function.
#'
#' If you want to learn more about web scraper/crawler architecture, functional properties and implementation using R language, Follow this link and download the published paper for free .
#'
#' Link: http://www.sciencedirect.com/science/article/pii/S2352711017300110
#'
#' Dont forget to cite Rcrawler paper:
#'
#' Khalil, S., & Fakir, M. (2017). RCrawler: An R package for parallel web crawling and scraping. SoftwareX, 6, 98-106.
#'
#' @examples
#'
#' \dontrun{
#'
#'  ######### Crawl, index, and store all pages of a websites using 4 cores and 4 parallel requests
#'  #
#'  Rcrawler(Website ="http://glofile.com/", no_cores = 4, no_conn = 4)
#'
#'  ######### Crawl and index the website using 8 cores and 8 parallel requests with respect to
#'  # robot.txt rules using Mozilla string in user agent.
#'
#'  Rcrawler(Website = "http://www.example.com/", no_cores=8, no_conn=8, Obeyrobots = TRUE,
#'  Useragent="Mozilla 3.11")
#'
#'  ######### Crawl the website using the default configuration and scrape specific data from
#'  # the website, in this case we need all posts (articles and titles) matching two XPath patterns.
#'  # we know that all blog posts have datesin their URLs like 2017/09/08 so to avoid
#'  # collecting category or other pages we can tell the crawler that desired page's URLs
#'  # are like 4-digit/2-digit/2-digit/ using regular expression.
#'  # Note thatyou can use the excludepattern  parameter to exclude a node from being
#'  # extracted, e.g., in the case that a desired node includes (is a parent of) an
#'  # undesired "child" node. (article having inner ads or menu)
#'
#'  Rcrawler(Website = "http://www.glofile.com/", dataUrlfilter =  "/[0-9]{4}/[0-9]{2}/",
#'  ExtractXpathPat = c("//*/article","//*/h1"), PatternsNames = c("content","title"))
#'
#'  ######### Crawl the website. and collect pages having URLs matching this regular expression
#'  # pattern (/[0-9]{4}/[0-9]{2}/). Collected pages will be stored in a local repository
#'  # named "myrepo". And The crawler stops After reaching the third level of website depth.
#'
#'   Rcrawler(Website = "http://www.example.com/", no_cores = 4, no_conn = 4,
#'   dataUrlfilter =  "/[0-9]{4}/[0-9]{2}/", DIR = "./myrepo", MaxDepth=3)
#'
#'
#'  ######### Crawl the website and collect/scrape only webpage related to a topic
#'  # Crawl the website and collect pages containing keyword1 or keyword2 or both.
#'  # To crawl a website and collect/scrape only some web pages related to a specific topic,
#'  # like gathering posts related to Donald trump from a news website. Rcrawler function
#'  # has two useful parameters KeywordsFilter and KeywordsAccuracy.
#'  #
#'  # KeywordsFilter : a character vector, here you should provide keywords/terms of the topic
#'  # you are looking for. Rcrawler will calculate an accuracy score based on matched keywords
#'  # and their occurrence on the page, then it collects or scrapes only web pages with at
#'  # least a score of 1% wich mean at least one keyword is founded one time on the page.
#'  # This parameter must be a vector with at least one keyword like c("mykeyword").
#'  #
#'  # KeywordsAccuracy: Integer value range between 0 and 100, used only in combination with
#'  # KeywordsFilter parameter to determine the minimum accuracy of web pages to be collected
#'  # /scraped. You can use one or more search terms; the accuracy will be calculated based on
#'  # how many provided keywords are found on on the page plus their occurrence rate.
#'  # For example, if only one keyword is provided c("keyword"), 50% means one occurrence of
#'  # "keyword" in the page 100% means five occurrences of "keyword" in the page
#'
#'   Rcrawler(Website = "http://www.example.com/", KeywordsFilter = c("keyword1", "keyword2"))
#'
#'  # Crawl the website and collect webpages that has an accuracy percentage higher than 50%
#'  # of matching keyword1 and keyword2.
#'
#'   Rcrawler(Website = "http://www.example.com/", KeywordsFilter = c("keyword1", "keyword2"),
#'    KeywordsAccuracy = 50)
#'
#'
#'  ######### Crawl a website search results
#'  # In the case of scraping web pages specific to a topic of your interest; The methods
#'  # above has some disadvantages which are complexity and time consuming as the whole
#'  # website need to be crawled and each page is analyzed to findout desired pages.
#'  # As result you may want to make use of the search box of the website and then directly
#'  # crawl only search result pages. To do so, you may use \code{crawlUrlfilter} and
#'  # \code{dataUrlfilter} arguments or \code{crawlZoneCSSPat}/\code{CrawlZoneXPath} with
#'  \code{dataUrlfilter}.
#'  #- \code{crawlUrlfilter}:what urls shoud be crawled (followed).
#'  #- \code{dataUrlfilter}: what urls should be collected (download HTML or extract data ).
#'  #- \code{crawlZoneCSSPat} Or \code{CrawlZoneXPath}: the page section where links to be
#'      crawled are located.
#'
#'  # Example1
#'  # the command below will crawl all result pages knowing that result pages are like :
#'     http://glofile.com/?s=sur
#'     http://glofile.com/page/2/?s=sur
#'     http://glofile.com/page/2/?s=sur
#'  # so they all have "s=sur" in common
#'  # Post pages should be crawled also, post urls are like
#'    http://glofile.com/2017/06/08/placements-quelles-solutions-pour-dper/
#'    http://glofile.com/2017/06/08/taux-nette-detente/
#'  # which contain a date format march regex "[0-9]{4}/[0-9]{2}/[0-9]{2}
#'
#'  Rcrawler(Website = "http://glofile.com/?s=sur", no_cores = 4, no_conn = 4,
#'  crawlUrlfilter = c("[0-9]{4}/[0-9]{2}/[0-9]d{2}","s=sur"))
#'
#'  # In addition by using dataUrlfilter we specify that :
#'  #  1- only post pages should be collected/scraped not all crawled result pages
#'  #  2- additional urls should not be retreived from post page
#'  #  (like post urls listed in 'related topic' or 'see more' sections)
#'
#'  Rcrawler(Website = "http://glofile.com/?s=sur", no_cores = 4, no_conn = 4,
#'  crawlUrlfilter = c("[0-9]{4}/[0-9]{2}/[0-9]d{2}","s=sur"),
#'  dataUrlfilter = "[0-9]{4}/[0-9]{2}/[0-9]{2}")
#'
#'  # Example 2
#'  # collect job pages from indeed search result of "data analyst"
#'
#'  Rcrawler(Website = "https://www.indeed.com/jobs?q=data+analyst&l=Tampa,+FL",
#'   no_cores = 4 , no_conn = 4,
#'   crawlUrlfilter = c("/rc/","start="), dataUrlfilter = "/rc/")
#'  # To include related post jobs on each collected post remove dataUrlfilter
#'
#'  # Example 3
#'  # One other way to control the crawler behaviour, and to avoid fetching
#'  # unnecessary links is to indicate to crawler the page zone of interest
#'  # (a page section from where links should be grabed and crawled).
#'  # The follwing example is similar to the last one,except this time we provide
#'  # the xpath pattern of results search section to be crawled with all links within.
#'
#'  Rcrawler(Website = "https://www.indeed.com/jobs?q=data+analyst&l=Tampa,+FL",
#'   no_cores = 4 , no_conn = 4,MaxDepth = 3,
#'   crawlZoneXPath = c("//*[\@id='resultsCol']"), dataUrlfilter = "/rc/")
#'
#'
#'  ######### crawl and scrape a forum posts and replays, each page has a title and
#'  # a list of replays , ExtractCSSPat = c("head>title","div[class=\"post\"]") .
#'  # All replays have the same pattern, therfore we set TRUE ManyPerPattern
#'  # to extract all of them.
#'
#'  Rcrawler(Website = "https://bitcointalk.org/", ManyPerPattern = TRUE,
#'  ExtractCSSPat = c("head>title","div[class=\"post\"]"),
#'  no_cores = 4, no_conn =4, PatternsName = c("Title","Replays"))
#'
#'
#'  ######### scrape data/collect pages meeting your custom criteria,
#'  # This is useful when filetring by keyword or urls does not fullfil your needs, for example
#'  # if you want to detect target pages  by classification/prediction model, or simply by checking
#'  # a sppecifi text value/field in the web page, you can create a custom filter function for
#'  # page selection as follow.
#'  # First will create and test our function and test it with un one page .
#'
#'  pageinfo<-LinkExtractor(url="http://glofile.com/index.php/2017/06/08/sondage-quel-budget/",
#'  encod=encod, ExternalLInks = TRUE)
#'
#'  Customfilterfunc<-function(pageinfo){
#'   decision<-FALSE
#'   # put your conditions here
#'     if(pageinfo$Info$Source_page ... ) ....
#'   # then return a boolean value TRUE : should be collected / FALSE should be escaped
#'
#'   return TRUE or FALSE
#'  }
#'   # Finally, you just call it inside Rcrawler function, Then the crawler will evaluate each
#'    page using your set of rules.
#'
#'  Rcrawler(Website = "http://glofile.com", no_cores=2, FUNPageFilter= Customfilterfunc )
#'
#'  ######### Website Network
#'  # Crawl the entire website, and create network edges DATA of internal links.
#'  # Using Igraph for exmaple you can plot the network by the following commands
#'
#'    Rcrawler(Website = "http://glofile.com/" , no_cores = 4, no_conn = 4, NetworkData = TRUE)
#'    library(igraph)
#'    network<-graph.data.frame(NetwEdges, directed=T)
#'    plot(network)
#'
#'   # Crawl the entire website, and create network edges DATA of internal and external links .
#'   Rcrawler(Website = "http://glofile.com/" , no_cores = 4, no_conn = 4, NetworkData = TRUE,
#'   NetwExtLinks = TRUE)
#'
#' ###### Crawl a website using a web driver (Vitural browser)
#' ###########################################################################
#' ## In some case you may need to retreive content from a web page which
#' ## requires authentication via a login page like private forums, platforms..
#' ## In this case you need to run \link{LoginSession} function to establish a
#' ## authenticated browser session; then use \link{LinkExtractor} to fetch
#' ## the URL using the auhenticated session.
#' ## In the example below we will try to fech a private blog post which
#' ## require authentification .
#'
#' If you retreive the page using regular function LinkExtractor or your browser
#' page<-LinkExtractor("http://glofile.com/index.php/2017/06/08/jcdecaux/")
#' The post is not visible because it's private.
#' Now we will try to login to access this post using folowing creditentials
#' username : demo and password : rc@pass@r
#'
#' #1 Download and install phantomjs headless browser (skip if installed)
#' install_browser()
#'
#' #2 start browser process
#' br <-run_browser()
#'
#' #3 create auhenticated session
#' #  see \link{LoginSession} for more details
#'
#'  LS<-LoginSession(Browser = br, LoginURL = 'http://glofile.com/wp-login.php',
#'                 LoginCredentials = c('demo','rc@pass@r'),
#'                 cssLoginCredentials =c('#user_login', '#user_pass'),
#'                 cssLoginButton='#wp-submit' )
#'
#' #check if login successful
#' LS$session$getTitle()
#' #Or
#' LS$session$getUrl()
#' #Or
#' LS$session$takeScreenshot(file = 'sc.png')
#' LS$session$getUrl()
# Scrape data from web page that require authentification
#' LS<-run_browser()
#' LS<-LoginSession(Browser = LS, LoginURL = 'https://manager.submittable.com/login',
#'    LoginCredentials = c('your email','your password'),
#'    cssLoginFields =c('#email', '#password'),
#'    XpathLoginButton ='//*[\@type=\"submit\"]' )
#'
#'
#' # page<-LinkExtractor(url='https://manager.submittable.com/beta/discover/119087',
#' LoggedSession = LS)
#' # cont<-ContentScraper(HTmlText = page$Info$Source_page,
#' XpathPatterns = c("//*[\@id=\"submitter-app\"]/div/div[2]/div/div/div/div/div[3]",
#' "//*[\@id=\"submitter-app\"]/div/div[2]/div/div/div/div/div[2]/div[1]/div[1]" ),
#' PatternsName = c("Article","Title"),astext = TRUE )
#'
#'}
#'
#'
#' @author salim khalil
#' @import foreach doParallel parallel
#' @export
#' @importFrom  selectr css_to_xpath
#' @import  webdriver
#' @importFrom  httr GET
#' @importFrom  httr user_agent
#' @importFrom  httr timeout
#' @importFrom  httr content
#' @importFrom  data.table %chin% %like% chmatch
#' @importFrom  xml2  xml_find_all
#' @importFrom  utils write.table
#' @importFrom  utils flush.console
#'


Rcrawler <- function(Website, no_cores,no_conn, MaxDepth, DIR, RequestsDelay=0,Obeyrobots=FALSE,
                     Useragent, use_proxy=NULL, Encod, Timeout=5, URLlenlimit=255, urlExtfilter,
                     dataUrlfilter, crawlUrlfilter, crawlZoneCSSPat=NULL, crawlZoneXPath=NULL,
                     ignoreUrlParams,ignoreAllUrlParams=FALSE, KeywordsFilter,KeywordsAccuracy,FUNPageFilter,
                     ExtractXpathPat, ExtractCSSPat, PatternsNames, ExcludeXpathPat, ExcludeCSSPat,
                     ExtractAsText=TRUE, ManyPerPattern=FALSE, saveOnDisk=TRUE, NetworkData=FALSE, NetwExtLinks=FALSE,
                     statslinks=FALSE, Vbrowser=FALSE, LoggedSession, IndexErrPages) {

  if (missing(IndexErrPages)) errstat<-c(200) else errstat<-c(200, IndexErrPages)
  if (missing(DIR)) DIR<-getwd()
  if (missing(KeywordsAccuracy)) KeywordsAccuracy<-1
  if (missing(ignoreUrlParams)) ignoreUrlParams<-""
  if (missing(MaxDepth)) MaxDepth<-10
  if (missing(no_cores)) no_cores<-parallel::detectCores()-1
  if (missing(no_conn)) no_conn<-no_cores
  if (missing(Obeyrobots)) Obeyrobots<-FALSE


  if (missing(dataUrlfilter)){
    dataUrlfilter<-".*"
    dataUrlfilterMissing<-TRUE
  }
  else {
    dataUrlfilter<-paste(dataUrlfilter,collapse="|")
    dataUrlfilterMissing<-FALSE
  }

  if (missing(crawlUrlfilter)){
    crawlUrlfilter <-".*"
    crawlUrlfilterMissing<-TRUE
    }
  else {
    crawlUrlfilter<-paste(crawlUrlfilter,collapse="|")
    crawlUrlfilterMissing<-FALSE
  }

  if(missing(Useragent)) {Useragent="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0"}
  if(missing(Encod)) {
    Encod<- Getencoding(Website)
    if (length(Encod)!=0){
      if(Encod=="NULL") Encod="UTF-8" ;
    }
  }

  if (!is.null(use_proxy) && (!missing(Vbrowser) || !missing(LoggedSession))) stop("webdriver cant be configured to use a proxy")


  if (!missing(FUNPageFilter)){
    if (!is.function(FUNPageFilter)) stop("FUNPageFilter parameter must be a function")
  }

  if(!missing(KeywordsFilter)){
    if(!is.vector(KeywordsFilter)){
      stop("KeywordsFilter parameter must be a vector with at least one element !")
    }
  }
  if(!is.numeric(KeywordsAccuracy)){
    stop ("KeywordsAccuracy parameter must be a numeric value between 1 and 100")
  } else {
    if(KeywordsAccuracy<=0 && KeywordsAccuracy>100) {
      stop ("KeywordsAccuracy parameter must be a numeric value between 1 and 100")
    }
  }
  if(!missing(KeywordsFilter) && !missing(FUNPageFilter) ){
    stop("Please supply KeywordsFilter or FUNPageFilter, not both !")
  }

  if(!missing(ExcludeXpathPat) && !missing(ExcludeCSSPat) ){
    stop("Please supply ExcludeXpathPat or ExcludeCSSPat, not both !")
  }
  if ((!missing(ExcludeXpathPat) || !missing(ExcludeCSSPat)) && (missing(ExtractXpathPat) && missing(ExtractCSSPat))){
    stop("ExcludeXpathPat or ExcludeCSSPat should work only if ExtractXpathPat or ExtractCSSPat are used !")
  }
  if(!missing(ExtractXpathPat) && !missing(ExtractCSSPat) ){
    stop("Please supply ExtractXpathPat or ExtractCSSPat, not both !")
  }
  if(!missing(ExtractCSSPat)) {
    if(is.vector(ExtractCSSPat)){
      ExtractXpathPat<- unlist(lapply(ExtractCSSPat, FUN = function(x) { tryCatch(selectr::css_to_xpath(x, prefix = "//") ,error=function(e) stop("Unable to translate supplied css selector, Please check ExtractCSSPat syntax !"))}))
    } else {
      stop("ExtractCSSPat parameter must be a vector with at least one element !")
    }
  }
  if(!missing(ExcludeCSSPat)) {
    if(is.vector(ExcludeCSSPat)){
      ExcludeXpathPat<- unlist(lapply(ExcludeCSSPat, FUN = function(x) { tryCatch(selectr::css_to_xpath(x, prefix = "//") ,error=function(e) stop("Unable to translate supplied css selector, Please check ExcludeCSSPat syntax !"))}))
    }
  }
  if(missing(ExcludeCSSPat) && missing(ExcludeXpathPat) ){
    ExcludeXpathPat=NULL
  }
  if(!is.null(crawlZoneCSSPat)){
    crawlZoneXPath<- unlist(lapply(crawlZoneCSSPat, FUN = function(x) { tryCatch(selectr::css_to_xpath(x, prefix = "//") ,error=function(e) stop("Unable to translate supplied css selector, Please check CrawlZoneCSSPat syntax !"))}))

  }

   if(missing(urlExtfilter)){ urlExtfilter<-c("flv","mov","swf","txt","xml","js","css","zip","gz","rar","7z","tgz","tar","z","gzip","bzip","tar","mp3","mp4","aac","wav","au","wmv","avi","mpg","mpeg","pdf","doc","docx","xls","xlsx","ppt","pptx","jpg","jpeg","png","gif","psd","ico","bmp","odt","ods","odp","odb","odg","odf") }
  keywordCheck<-FALSE
  if(missing(KeywordsFilter) ){
    keywordCheck<-FALSE
  } else {
    if(is.vector(KeywordsFilter)) {
      keywordCheck<-TRUE
    }
  }
  if(!missing(LoggedSession)){
    if(length(LoggedSession)!=3){
      stop("Error in LoggedSession Argurment, use run_browser() and LogginSession() functions to create a valid browser session object")
    }
  }
  domain<-strsplit(gsub("http://|https://|www\\.", "", Website), "/")[[c(1, 1)]]
  if (Obeyrobots) {
    rules<-RobotParser(Website,Useragent)
    urlbotfiler<-rules[[2]]
    urlbotfiler<-gsub("^\\/", paste("http://www.",domain,"/", sep = ""), urlbotfiler , perl=TRUE)
    urlbotfiler<-gsub("\\*", ".*", urlbotfiler , perl=TRUE)
  } else {urlbotfiler=" "}


  IndexErrPages<-c(200)

  #create repository
  tryCatch(curdate<-format(Sys.time(), "%d%H%M"),error=function(e) curdate<-sample(1000:9999, 1) )
  if(saveOnDisk){
    foldename<-paste(domain,"-",curdate,sep = "")
    path<-paste(DIR,"/", foldename ,sep = "")
    dir.create(path, recursive = TRUE, mode = "0777")
  }
  #if(Backup) {
  #   Fileindex <- file(paste(path,"/","index.csv", sep = ""), "w")
  #  Filefrontier <- file(paste(path,"/","frontier.csv", sep = ""), "w")
  #  Filestat<-file(paste(path,"/","state.txt", sep = ""), "w")
  #  }

  if(!missing(ExtractXpathPat)) {
    if(saveOnDisk){
      Filecontent <- file(paste(path,"/","extracted_data.csv", sep = ""), "w")
    }
  }
  duplicatedetect<-FALSE
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
  Accuracy<-vector()
  allpaquet<-list()

  pkg.env <- new.env()
  if (!missing(ExtractXpathPat)) { pkg.env$Exdata<-list() }
  pkg.env$shema<-data.frame(id,urls,status,level,out,inn,httpstat,contenttype,encoding,Accuracy)
  names(pkg.env$shema) <- c("Id","Url","Stats","Level","OUT","IN","Http Resp","Content Type","Encoding","Accuracy")
  if(NetworkData){
    FromNode<-vector()
    ToNode<-vector()
    Weight<-vector()
    Type<-vector()
    pkg.env$GraphINDEX<-vector()
    pkg.env$GraphINDEX<-c(pkg.env$GraphINDEX,Website)
    pkg.env$GraphEgdes<-data.frame(FromNode,ToNode,Weight,Type)
    names(pkg.env$GraphEgdes) <- c("From","To","Weight","Type")
  }

  pkg.env$Lbrowsers<-list()


  if(!missing(LoggedSession)){

      no_conn<-no_cores
      cat("Preparing browser process ")
      pkg.env$Lbrowsers[[1]]<-LoggedSession

      if(no_cores>=2){
        for(i in 2:no_cores){
          pkg.env$Lbrowsers[[i]]<-run_browser()
          pkg.env$Lbrowsers[[i]]<-LoginSession(Browser = pkg.env$Lbrowsers[[i]], LoginURL = LoggedSession$loginInfo$LoginURL, LoginCredentials =LoggedSession$loginInfo$LoginCredentials,
                                               cssLoginFields = LoggedSession$loginInfo$cssLoginFields,cssLoginButton =LoggedSession$loginInfo$cssLoginButton,cssRadioToCheck = LoggedSession$loginInfo$cssRadioToCheck,
                                               XpathLoginFields = LoggedSession$loginInfo$XpathLoginFields, XpathLoginButton = LoggedSession$loginInfo$XpathLoginButton, XpathRadioToCheck = LoggedSession$loginInfo$XpathRadioToCheck)
          cat("browser:",i," port: ",pkg.env$Lbrowsers[[i]]$process$port)
          Sys.sleep(1)
          cat("..")
          flush.console()
        }
      }
  } else if(Vbrowser){
      #if(RequestsDelay==0) RequestsDelay=2
      no_conn<-no_cores
      cat("Preparing browser process ")
      for(i in 1:no_cores){
        pkg.env$Lbrowsers[[i]]<-run_browser()
        cat("browser:"+i+" port:"+pkg.env$Lbrowsers[[i]]$process$port)
        Sys.sleep(1)
        cat(".")
        flush.console()
      }
  }


  cat("\n")
  #timev<<- vector()
  #timef<<-vector()
  Error403 <- vector()
  shemav <- vector()
  shemav<-c(shemav,Website)
  Lshemav<-list(shemav)
  M=Listlength(Lshemav)
  lev<-0
  t<-1
  posx<-0
  i<-0
  posenv <- 1
  chunksize<-10000
  envi = as.environment(posenv)
  #cluster initialisation
  cl <- makeCluster(no_cores)

  cat("Preparing multihreading cluster .. ")
  registerDoParallel(cl)

  clusterEvalQ(cl, library(xml2))
  clusterEvalQ(cl, library(httr))
  clusterEvalQ(cl, library(data.table))
  clusterEvalQ(cl, library(webdriver))
  clusterEvalQ(cl, library(jsonlite))
  clusterExport(cl, c("LinkExtractor","LinkNormalization","Drv_fetchpage"))
  clusterExport(cl, c("shema","Lbrowsers"), envir = pkg.env)
  #tmparallelreq<<-vector()
  #tmparallel<<-vector()
  #tminsertion<<-vector()
  #tminsertionreq<<-vector()
  Iter<-0
  while (t<=Listlength(Lshemav) && MaxDepth>=lev){

    Iter<-Iter+1
    # extraire les liens sur la page
    rest<-Listlength(Lshemav)-t
    #if(rest==0){ rest<-rest+1 }
    if (no_conn<=rest){
      l<-t+no_conn-1
    } else {
      l<-t+rest
    }
    #cat(t,"to",l,"size:",length(shemav))
    #get links & pageinfo
    if(missing(Vbrowser) && missing(LoggedSession)){
      if (RequestsDelay!=0) {
        Sys.sleep(RequestsDelay)
      }
    }
    #ptm <- proc.time()
    if(t<chunksize){
      tt<-t
      VposT<-1
    } else {
      VposT<-(t%/%chunksize)+1
      tt<-t%%(chunksize*(t%/%chunksize))+1
    }

    if(l<chunksize){
      ll<-l
      VposL<-1
    }else{
      VposL<-(l%/%chunksize)+1
      ll<-l%%(chunksize*(l%/%chunksize))+1
    }
    tmpshemav<-vector()
    if(VposT!=VposL){
      for(k in tt:(chunksize-1)) {
          #bcat("k:",k)
          tmpshemav<-c(tmpshemav,Lshemav[[VposT]][[k]])
       }
      for(r in 1:ll){
        tmpshemav<-c(tmpshemav,Lshemav[[VposL]][[r]])
        #cat("r:",r)
      }

      #topshemav<<-tmpshemav
      #cat("VposT :",VposT," tt :",tt, " VposL :",VposL, " ll :",ll," tmpshema:",length(tmpshemav))
      if(Vbrowser || !missing(LoggedSession)){
        allpaquet <- foreach(i=1:length(tmpshemav),  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass')  %dopar%
        {
          LinkExtractor(url = tmpshemav[[i]], id = i,lev = lev, IndexErrPages = IndexErrPages, Useragent = Useragent, Timeout = Timeout, URLlenlimit = URLlenlimit, urlExtfilter=urlExtfilter, encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams, ExternalLInks=NetwExtLinks, Browser =pkg.env$Lbrowsers[[1]], RenderingDelay = RequestsDelay, removeAllparams = ignoreAllUrlParams, urlregexfilter =crawlUrlfilter, urlsZoneXpath = crawlZoneXPath)
        }
      }else{
        allpaquet <- foreach(i=1:length(tmpshemav),  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass')  %dopar%
        {
          LinkExtractor(url = tmpshemav[[i]], id = i,lev = lev, IndexErrPages = IndexErrPages, Useragent = Useragent, Timeout = Timeout, URLlenlimit = URLlenlimit, urlExtfilter=urlExtfilter, encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams, ExternalLInks=NetwExtLinks, removeAllparams = ignoreAllUrlParams, use_proxy = use_proxy, urlregexfilter = crawlUrlfilter, urlsZoneXpath = crawlZoneXPath)
        }
      }
    } else {
      if(Vbrowser || !missing(LoggedSession) ){
        #cat("\n VposT :",VposT," tt :",tt, " VposL :",VposL, " ll :",ll,"((j%%tt)+1)=",((tt%%tt)+1) , " \n")
        j<-0
        #qq<<-LinkExtractor(url = Lshemav[[VposT]][1],id = i,lev = lev, IndexErrPages = IndexErrPages, Useragent = Useragent, Timeout = Timeout, URLlenlimit = URLlenlimit, urlExtfilter=urlExtfilter, encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams, ExternalLInks=NetwExtLinks, VBrowser =pkg.env$Lbrowsers[[1]])
        allpaquet <- foreach(j=tt:ll,  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass')  %dopar%
        {
          LinkExtractor(url = Lshemav[[VposT]][j],id = i,lev = lev, IndexErrPages = IndexErrPages, Useragent = Useragent, Timeout = Timeout, URLlenlimit = URLlenlimit, urlExtfilter=urlExtfilter, encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams, ExternalLInks=NetwExtLinks, Browser =pkg.env$Lbrowsers[[((j%%tt)+1)]], removeAllparams = ignoreAllUrlParams, urlregexfilter = crawlUrlfilter, urlsZoneXpath = crawlZoneXPath)
        }
      } else{
        #for(k in tt:ll ){
        #  cat("\n -",Lshemav[[VposT]][k])
        #}
        # cat("\n VposT :",VposT," tt :",tt, " VposL :",VposL, " ll :",ll, " \n")
        j<-0
        allpaquet <- foreach(j=tt:ll,  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass')  %dopar%
        {
          LinkExtractor(url = Lshemav[[VposT]][j],id = i,lev = lev, IndexErrPages = IndexErrPages, Useragent = Useragent, Timeout = Timeout, URLlenlimit = URLlenlimit, urlExtfilter=urlExtfilter, encod = Encod, urlbotfiler = urlbotfiler, removeparams=ignoreUrlParams, ExternalLInks=NetwExtLinks, removeAllparams = ignoreAllUrlParams, use_proxy = use_proxy, urlregexfilter = crawlUrlfilter, urlsZoneXpath = crawlZoneXPath)
        }
      }

    }


    #deb<<-allpaquet
    #for (j in t:l){
    #    cat(shemav[i]);
    #}
    #tmparallelreq<<-c(tmparallelreq,(proc.time() - ptm )[3])
    #tmparallel<<-c(tmparallel,format(Sys.time(), "%M,%S"))
    cat("In process : ")
    #if (no_conn<=rest){
    #  f<-no_conn
    #} else if (no_conn>rest) {
    #  f<-rest
    #}
    #if(0==rest) {
    #  f<-l-t+1
    #}
    #cat("f:",f,"t:",t,"conn",no_conn,"r:",rest)
    #if(f==0){f<-f+1}
    # combine all links.package in one list & insert pageinfo in shema one-by-one
    Error403[[Iter]]<-0
    for (s in 1:length(allpaquet)){
      # pos :  Global positon (regarding to shemav)
      pos<-s+t-1
      #cat("s1",s)
      cat(pos,"..", sep = "")
      flush.console()
      # timev[pos]<<-Sys.time()
      # timef[pos]<<-format(Sys.time(), "%M,%S")
      # Les page null ne sont pas ajouter au shema
      #debugg<<-allpaquet
      #debugg2<<-shemav
      #cat("x :",allpaquet[[s]]$Info$Url,"\n");

      if(!is.null(allpaquet[[s]]$InternalLinks) && !("call" %in% names(allpaquet[[s]]$InternalLinks))) {
      #cat("x2");
        if(allpaquet[[s]]$Info$Status_code==403){
          Error403[[Iter]]<-1
          }

        if (NetworkData) {
          tmplinks<-vector()
          tmplinks<-c(tmplinks,unlist(allpaquet[[s]][2]))
          #tmplinks<-c(tmplinks,debugg[[s]][[1]][[2]])
          if(length(tmplinks) > 0){
            pkg.env$GraphINDEX<-c( pkg.env$GraphINDEX , tmplinks[ ! tmplinks %chin% pkg.env$GraphINDEX ] )
            for(NodeElm in tmplinks){
              posNodeFrom<-chmatch(c(allpaquet[[s]][[1]][[2]]),pkg.env$GraphINDEX)
              pkg.env$GraphEgdes[nrow(pkg.env$GraphEgdes) + 1,]<-c(posNodeFrom,chmatch(c(NodeElm),pkg.env$GraphINDEX),lev,1)
            }
          }
          if(NetwExtLinks){
            tmplinks2<-vector()
            tmplinks2<-c(tmplinks2,unlist(allpaquet[[s]][3]))
            if(length(tmplinks2) > 0){
              pkg.env$GraphINDEX<-c( pkg.env$GraphINDEX , tmplinks2[ ! tmplinks2 %chin% pkg.env$GraphINDEX ] )
              for(NodeElm in tmplinks2){
                posNodeFrom<-chmatch(c(allpaquet[[s]][[1]][[2]]),pkg.env$GraphINDEX)
                pkg.env$GraphEgdes[nrow(pkg.env$GraphEgdes) + 1,]<-c(posNodeFrom,chmatch(c(NodeElm),pkg.env$GraphINDEX),lev,2)
              }
            }
          }
        }
        if (statslinks){
          tmplinks<-vector()
          tmplinks<-c(tmplinks,unlist(allpaquet[[s]][[2]]))
          if(length(tmplinks) > 0 && length(pkg.env$shema[[2]])>0){
            for(NodeElm in tmplinks){
              index<-chmatch(c(NodeElm),pkg.env$shema[[2]])
              if(!is.na(index)){
                pkg.env$shema[[6]][index]<-as.numeric(pkg.env$shema[[6]][index])+1
              }
            }
          }
        }
        #cat("s2")
        if (!dataUrlfilterMissing && !crawlUrlfilterMissing){
          if(length(allpaquet[[s]]$InternalLinks)>0){
            if(!grepl(pattern = dataUrlfilter,x = allpaquet[[s]]$Info$Url)){
              links<-c(links,allpaquet[[s]]$InternalLinks)
            }
          }
        } else {
        links<-c(links,allpaquet[[s]]$InternalLinks)
        }
        #cat("s3")
        #debugg2<<-allpaquet[[s]][2]
        #amdebugg3<<-allpaquet[[s]][1]
        if (allpaquet[[s]][[1]][[3]]!="NULL" && allpaquet[[s]][[1]][[10]]!="NULL" ){
          #index URL filter
          if (grepl(dataUrlfilter,allpaquet[[s]][[1]][[2]]) && (allpaquet[[s]]$Info$Status_code %in% IndexErrPages)){

            if(!missing(FUNPageFilter)){
              contentx<-allpaquet[[s]][[1]][[10]]
              Notagcontentx<-RemoveTags(contentx)
              isPagevalid<-FUNPageFilter(allpaquet[[s]])
              if(!is.logical(isPagevalid)) stop ("FUNPageFilter function must return a logical value TRUE/FALSE")
              if (isPagevalid){
                if (!missing(ExtractXpathPat)) {
                  excontent2<-ContentScraper(HTmlText = allpaquet[[s]][[1]][[10]],XpathPatterns = ExtractXpathPat, PatternsName = PatternsNames, ManyPerPattern=ManyPerPattern, astext = ExtractAsText, encod=Encod)
                  posx<-posx+1
                  pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],paste0(Accuracy,"%"))
                  DES<-isTarget(excontent2)
                  if(DES){
                  excontent2<-c(posx,excontent2)
                  pkg.env$Exdata<-c(pkg.env$Exdata, list(excontent2))
                  assign("DATA", pkg.env$Exdata, envir = envi )
                  }
                  if(saveOnDisk){
                      filename<-paste0(posx,".html")
                      filepath<-paste(path,"/",filename, sep = "")
                      filepath<-file(filepath, open = "w",  encoding = Encod)
                      write(allpaquet[[s]][[1]][[10]],filepath)
                      close(filepath)
                      if(DES){
                      write.table(NormalizeForExcel(excontent2), file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                      }
                  }
                }
                else {
                  posx<-posx+1
                  pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],Encod,paste0(Accuracy,"%"))
                  if(saveOnDisk){
                    filename<-paste(posx,".html")
                    filepath<-paste(path,"/",filename, sep = "")
                    filepath<-file(filepath, open = "w",  encoding = Encod)
                    write(allpaquet[[s]][[1]][[10]],filepath)
                    close(filepath)
                  }
                }
              }
            }
            else if(keywordCheck){
              #check if page content contain some specific keywords
               contentx<-allpaquet[[s]][[1]][[10]]
               Notagcontentx<-tolower(gsub("\\W", " ",RemoveTags(contentx), perl=TRUE))

               AccuracyResult <- foreach(i=1:length(KeywordsFilter),  .verbose=FALSE, .inorder=FALSE, .errorhandling='pass', .combine=c)  %dopar%
                {
                  Precifunc(KeywordsFilter[i],length(KeywordsFilter),Notagcontentx)
                }
               Accuracy<-sum(AccuracyResult)
              if (Accuracy>=KeywordsAccuracy){
                #if(containtag) {
                #check for duplicate webpage & checksum calculation
                # if (duplicatedetect==TRUE){
                # hash<-getsimHash(contentx,128)
                # Ajouter au shema uniqument les liens non-repete
                # if (!(hash %in% pkg.env$shema$hashcode)){
                # posx, actual position of DF shema
                #  posx<-posx+1
                #  pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],hash)
                #  filename<-paste(posx,".html")
                #  filepath<-paste(path,"/",filename, sep = "")
                #  write(allpaquet[[s]][[1]][[10]],filepath) }
                #  } else {
                  if (!missing(ExtractXpathPat)) {
                    excontent2<-ContentScraper(HTmlText = allpaquet[[s]][[1]][[10]],XpathPatterns = ExtractXpathPat,PatternsName = PatternsNames, ManyPerPattern=ManyPerPattern, astext = ExtractAsText, encod=Encod)
                    posx<-posx+1
                    pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],allpaquet[[s]][[1]][[9]],paste0(Accuracy,"%"))
                    DES<-isTarget(excontent2)
                    if(DES){
                    excontent2<-c(posx,excontent2)
                    pkg.env$Exdata<-c(pkg.env$Exdata, list(excontent2))
                    assign("DATA", pkg.env$Exdata, envir = envi )
                    }
                    if(saveOnDisk){
                        filename<-paste(posx,".html")
                        filepath<-paste(path,"/",filename, sep = "")
                        filepath<-file(filepath, open = "w",  encoding = Encod)
                        write(allpaquet[[s]][[1]][[10]],filepath)
                        close(filepath)
                        if(DES){
                        write.table(NormalizeForExcel(excontent2), file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                        }
                    }
                  }
                  else {
                    posx<-posx+1
                    pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],Encod,paste0(format(round(Accuracy, 2),nsmall = 2),"%"))
                    if(saveOnDisk){
                      filename<-paste(posx,".html")
                      filepath<-paste(path,"/",filename, sep = "")
                      filepath<-file(filepath, open = "w",  encoding = Encod)
                      write(allpaquet[[s]][[1]][[10]],filepath)
                      close(filepath)
                    }
                 }
              }
            }
            else {
              if (!missing(ExtractXpathPat)) {
                  excontent2<-ContentScraper(HTmlText = allpaquet[[s]][[1]][[10]],XpathPatterns = ExtractXpathPat, PatternsName = PatternsNames, ManyPerPattern = ManyPerPattern, astext = ExtractAsText, ExcludeXpathPat = ExcludeXpathPat, encod=Encod)
                 #if(isTarget(excontent)){
                  posx<-posx+1
                  pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],"",allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],Encod,'')
                  DES<-isTarget(excontent2)
                  if(DES){
                  excontent2<-c(PageID=posx,excontent2)
                  pkg.env$Exdata<-c(pkg.env$Exdata, list(excontent2))
                  assign("DATA", pkg.env$Exdata, envir = envi )
                  }
                  # save on html and data on file
                  if(saveOnDisk){
                    filename<-paste(posx,".html")
                    filepath<-paste(path,"/",filename, sep = "")
                    filepath<-file(filepath, open = "w",  encoding = Encod)
                    write(allpaquet[[s]][[1]][[10]],filepath)
                    close(filepath)
                    if(DES){
                    #excontent2<<-excontent2
                    #Normexcontent2<<-NormalizeForExcel(excontent2)
                    write.table(NormalizeForExcel(excontent2), file = Filecontent, sep = ";", qmethod="double" ,row.names = FALSE, col.names = FALSE, na = "NA" )
                    }
                  }
                #}
              }
              else {
                posx<-posx+1
                pkg.env$shema[posx,]<-c(posx,allpaquet[[s]][[1]][[2]],"finished",allpaquet[[s]][[1]][[4]],allpaquet[[s]][[1]][[5]],1,allpaquet[[s]][[1]][[7]],allpaquet[[s]][[1]][[8]],Encod,'')
                if(saveOnDisk){
                  filename<-paste(posx,".html")
                  filepath<-paste(path,"/",filename, sep = "")
                  filepath<-file(filepath, open = "w",  encoding = Encod)
                  write(allpaquet[[s]][[1]][[10]],filepath)
                  close(filepath)
                }
              }
            }
          }
        }
      }

    if(pos==M){
        lev<-lev+1;
        getNewM<-TRUE
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
      #shemav<-c( shemav , links[ ! links %chin% shemav ] )

      for (L in links){
        LshemaSize<-length(Lshemav)
        s<-length(Lshemav[[LshemaSize]])+1
        if (s<chunksize){
          dec<-1
          for (vec in Lshemav){
            if( L %chin% vec) dec<-bitwAnd(0,dec)
          }
          if(dec==1) {
            Lshemav[[LshemaSize]][s]<-L
            s<-s+1
          }
        } else {
          LshemaSize<-LshemaSize+1
          s<-1
          dec<-1
          for (vec in Lshemav){
            if( L %chin% vec) dec<-bitwAnd(0,dec)
          }
          if(dec==1){
            Lshemav<-c(Lshemav,c(L))
            s<-s+1
          }
        }
      }
      #Lshemavv<<-Lshemav
      #cat ("shemav:", length(shemav), " Lshema:",Listlength(Lshemav))



    }
      Error403[is.na(Error403)]<-0
      if(length(Error403)>4){
        #cat(Error403[Iter])
        #cat(Error403[Iter-1])
        #cat(Error403[Iter-2])
        #cat(Error403[Iter-3])

        if(Error403[Iter]==Error403[Iter-1] && Error403[Iter-1]==Error403[Iter-2] &&
           Error403[Iter-2]==Error403[Iter-3] && Error403[Iter-3]==1)
          cat("Warning !! Many concurrent requests are blocked (403 forbidden error). Use less parallel requests in no_cores and no_conn to avoid overloading the website server.")
      }

      #calculate level
      if(getNewM){
        M=Listlength(Lshemav)
        getNewM<-FALSE
      }
    #tminsertion<<-c(tminsertion,(proc.time() - ptm )[3])
    #tminsertionreq<<-c(tminsertionreq,format(Sys.time(), "%M,%S"))
    cat("Progress:",format(round(((t/Listlength(Lshemav))*100), 2),nsmall = 2),"%  : ",t, " parssed from ",Listlength(Lshemav)," | Collected pages:",length(pkg.env$shema$Id)," | Level:",lev,"\n")
    # t<-l+1
    t<-t+length(allpaquet)
    if(NetworkData){
      assign("NetwEdges", pkg.env$GraphEgdes, envir = envi )
      assign("NetwIndex", pkg.env$GraphINDEX, envir = envi )
    }
    assign("INDEX", pkg.env$shema, envir = envi )
    #tmp<<-shemav
  }
  if(!missing(ExtractXpathPat)) {
    if(saveOnDisk){
      close(Filecontent)
    }
  }

  if(Vbrowser){
  cat("Shutting-down browsers ")
      for(i in 1:no_cores){
      stop_browser(pkg.env$Lbrowsers[[i]])
      Sys.sleep(1)
      cat(".")
      }
      rm(pkg.env$Lbrowsers)
  }
  #assign("Browsers", pkg.env$browsers, envir = envi )
  #rm(Browsers, envir = envi)
  #cat("Shutting-down multihrading cluster ..")
  #save(shema, file="masterma2.rda")
  stopCluster(cl)
  stopImplicitCluster()
  rm(cl)

  #return(pkg.env$shema)
  cat("+ Check INDEX dataframe variable to see crawling details \n")
  cat("+ Collected web pages are stored in Project folder \n" )
  if(saveOnDisk){
    cat("+ Project folder name :", foldename,"\n")
    cat("+ Project folder path :", path,"\n")
  }
  if(!missing(ExtractXpathPat)){
    cat("+ Scraped data are stored in a variable named : DATA \n")
    if(saveOnDisk){
      cat("+ Scraped data are stored in a CSV file named : extracted_data.csv \n")
    }
  }
  if(NetworkData){
    cat("+ Network nodes are stored in a variable named : NetwIndex \n")
    cat("+ Network eadges are stored in a variable named : NetwEdges \n")
  }

}
