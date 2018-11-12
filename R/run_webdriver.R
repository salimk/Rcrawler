#' Start up web driver process on localhost, with a random port
#'
#'  Phantomjs is a headless browser, it provide automated control of a web page in
#'  an environment similar to web browsers, but via a command-line. It's able
#'  to render and understand HTML the same way a regular browser would, including
#'  styling elements such as page layout, colors, font selection and execution of
#'  JavaScript and AJAX which are usually not available when using GET request methods.
#'
#'  This function will throw an error if webdriver(phantomjs) cannot be found, or cannot be started.
#'  It works with a timeout of five seconds.
#'
#'  If you got the forllwing error, this means that your operating system or antivirus
#'  is bloking the webdriver (phantom.js) process, try to disable your antivirus temporarily or
#'  adjust your system configuration to allow phantomjs and processx executable (\link{browser_path}
#'  to know where phantomjs is located).
#'  Error in supervisor_start() :  processx supervisor was not ready after 5 seconds.
#'
#' @param debugLevel debug level, possible values: 'INFO', 'ERROR', 'WARN', 'DEBUG'
#' @param timeout How long to wait (in milliseconds) for the webdriver connection to be established to the phantomjs process.
#'
#'
#' @return A list of \code{callr::process} object, and
#'   \code{port}, the local port where phantom is running.
#'
#'
#' @examples
#' \dontrun{
#'
#' #If driver is not installed yet then
#' install_browser()
#'
#' br<-run_browser()
#'
#' }
#'
#'
#' @import  webdriver
#' @export
#'

run_browser <- function(debugLevel = "DEBUG",
                          timeout = 5000){

  Drv<-webdriver::run_phantomjs(debugLevel = debugLevel, timeout = timeout)
  Ses <- Session$new(port = Drv$port)
  list(session=Ses,process=Drv)
}


#' Stop web driver process and Remove its Object
#'
#' At the end of All your operations with the web river, you should stop its process
#' and remove the driver R object else you may have troubles restarting R normaly.
#' Throws and error if webdriver phantomjs cannot be found, or cannot be started.
#' It works with a timeout of five seconds.
#'
#' @param browser the web driver object created by \code{\link{run_browser}}
#'
#' @return A list of \code{process}, the \code{callr::process} object, and
#'   \code{port}, the local port where phantom is running.
#'
#' @examples
#' \dontrun{
#'
#' #Start the browser
#' br<-run_browser()
#'
#' #kill the browser process
#' stop_browser(br)
#' #remove the object reference
#' rm(br)
#'
#'  }
#'
#'
#' @importFrom callr process
#' @importFrom webdriver Session
#' @export

stop_browser <- function(browser){
  browser$session$delete()
  browser$process$process$suspend()
  browser$process$process$finalize()
  browser$process$process$kill_tree()
}
