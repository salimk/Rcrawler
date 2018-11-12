#' Open a logged in Session
#'
#' Simulate authentifaction using web driver automation
#' This function Fetch login page using phantomjs web driver(virtual browser), sets login and password values + other required values then clicks on login button.
#' You should provide these agruments for the function to work correctly :
#' - Login page URL
#' - Login Credentials eg: email & password
#' - css Or Xpath of Login Credential fields
#' - css or xpath of Login Button
#' - If a checkbox is required in the login page then provide provide its css or xpath pattern
#'
#' @param Browser object, phatomjs web driver use \code{\link{run_browser}} function to create this object.
#' @param LoginURL  character, login page URL
#' @param LoginCredentials, login Credentials values eg: email and password
#' @param cssLoginFields, vector of login fields css pattern.
#' @param XpathLoginFields, vector of login fields xpath pattern.
#' @param cssLoginButton, the css pattern of the login button that should be clicked to access protected zone.
#' @param XpathLoginButton, the xpath pattern of the login button.
#' @param cssRadioToCheck,  the radio/checkbox css pattern to be checked(if exist)
#' @param XpathRadioToCheck the radio/checkbox xpath pattern to be checked(if exist)
#'
#' @return return authentified browser session object
#'
#' @author salim khalil
#' @import  webdriver
#' @examples
#'
#'\dontrun{
#'
#'
#'  #This function is based on web browser automation, so, before start,
#'  make sure you have successfully installed web driver (phantomjs).
#'  install_browser()
#'  # Run browser process and get its reference object
#'  br<- run_browser()
#'
#'   brs<-LoginSession(Browser = br, LoginURL = 'http://glofile.com/wp-login.php',
#'                 LoginCredentials = c('demo','rc@pass@r'),
#'                 cssLoginFields =c('#user_login', '#user_pass'),
#'                 cssLoginButton='#wp-submit' )
#'
#'  # To make sure that you have been successfully authenticated
#'  # Check URL of the current page after login redirection
#'  brs$getUrl()
#'  # Or Take screenshot of the website dashborad
#'  brs$takeScreenshot(file = "sc.png")
#'
#'
#'  brs$delete()
#'  brs$status()
#'  brs$go(url)
#'  brs$getUrl()
#'  brs$goBack()
#'  brs$goForward()
#'  brs$refresh()
#'  brs$getTitle()
#'  brs$getSource()
#'  brs$takeScreenshot(file = NULL)
#'  brs$findElement(css = NULL, linkText = NULL,
#'               partialLinkText = NULL, xpath = NULL)
#'  brs$findElements(css = NULL, linkText = NULL,
#'                partialLinkText = NULL, xpath = NULL)
#'  brs$executeScript(script, ...)
#'  brs$executeScriptAsync(script, ...)
#'  brs$setTimeout(script = NULL, pageLoad = NULL, implicit = NULL)
#'  brs$moveMouseTo(xoffset = 0, yoffset = 0)
#'  brs$click(button = c("left", "middle", "right"))
#'  brs$doubleClick(button = c("left", "middle", "right"))
#'  brs$mouseButtonDown(button = c("left", "middle", "right"))
#'  brs$mouseButtonUp(button = c("left", "middle", "right"))
#'  brs$readLog(type = c("browser", "har"))
#'  brs$getLogTypes()
#'
#' }
#' @export
#'
#'
LoginSession<-function (Browser, LoginURL, LoginCredentials,
                       cssLoginFields, cssLoginButton, cssRadioToCheck,
                       XpathLoginFields, XpathLoginButton, XpathRadioToCheck ){

  if(missing(Browser))  stop("browser argument should be specified, use run_browser() to create a browser object")
  if(missing(LoginURL))  stop("LoginURL argument should be specified")
  if(missing(LoginCredentials))  stop("LoginCredentials argument should be specified,eg: c(\"email@acc.com\",\"password\")")

  if(missing(cssLoginFields) && missing(XpathLoginFields) ) stop("You should provide either cssLoginFields OR XpathLoginFields (css or xpath of Login Credential fields)")
  if(missing(cssLoginButton) && missing(XpathLoginButton) ) stop("You should provide either cssLoginButton OR XpathLoginButton (css or xpath of Login Button)")
  #if(missing(cssRadioToCheck) && missing(XpathRadioToCheck) ) stop("You should provide either cssRadioToCheck OR XpathRadioToCheck (css or xpath of Radios To Check)")

  #if(!missing(cssLoginFields) && !missing(XpathLoginFields) ) stop("Only one argument should be specified cssLoginFields OR XpathLoginFields \n You should provide either css or xpath of Login Credential fields")
  #if(!missing(cssLoginButton) && !missing(XpathLoginButton) ) stop("Only one argument should be specified cssLoginButton OR XpathLoginButton  \n You should provide either css or xpath of LoginButton")
  #if(!missing(cssRadioToCheck) && !missing(XpathRadioToCheck) ) stop("Only one argument should be specified cssRadioToCheck OR XpathRadioToCheck  \n You should provide either css or xpath of RadioToCheck")



  Browser$session$initialize(port=Browser$process$port)
  Browser$session$go(LoginURL)

  if(!missing(cssLoginFields) && !is.null(cssLoginFields)){
      for(i in 1:length(cssLoginFields)){
        e <- Browser$session$findElement(css = cssLoginFields[i])
        e$setValue(LoginCredentials[i])
      }
    XpathLoginFields<-NULL
  }

  if(!missing(XpathLoginFields) && !is.null(XpathLoginFields) ){
      for(i in 1:length(XpathLoginFields)){
        e <- Browser$session$findElement(xpath = XpathLoginFields[i])
        e$setValue(LoginCredentials[i])
      }
    cssLoginFields<-NULL
  }

  if(!missing(cssRadioToCheck) && !is.null(cssRadioToCheck)){
    for(i in 1:length(cssRadioToCheck)){
      e <- Browser$session$findElement(css = cssRadioToCheck[i])
      e$click()
    }
    XpathRadioToCheck<-NULL
  }

  if(!missing(XpathRadioToCheck) &&  !is.null(XpathRadioToCheck)){
    for(i in 1:length(XpathRadioToCheck)){
      e <- Browser$session$findElement(xpath = XpathRadioToCheck[i])
      e$click()
    }
    cssRadioToCheck<-NULL
  }

  if(missing(cssRadioToCheck) && missing(XpathRadioToCheck)){
    cssRadioToCheck<-NULL
    XpathRadioToCheck<-NULL
  }

  if(!missing(cssLoginButton) && !is.null(cssLoginButton)){
    e <- Browser$session$findElement(css = cssLoginButton)
    e$click()
    XpathLoginButton<-NULL
  }

  if(!missing(XpathLoginButton) && !is.null(XpathLoginButton)){
    e <- Browser$session$findElement(xpath = XpathLoginButton)
    e$click()
    cssLoginButton<-NULL
  }

  Browser[["loginInfo"]]<-list(LoginURL=LoginURL,LoginCredentials=LoginCredentials,
      cssLoginFields=cssLoginFields, cssLoginButton=cssLoginButton,cssRadioToCheck=cssRadioToCheck,
      XpathLoginFields=XpathLoginFields, XpathLoginButton=XpathLoginButton, XpathRadioToCheck=XpathRadioToCheck)

  Browser
}

