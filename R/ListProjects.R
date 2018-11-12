#' ListProjects
#'
#' List all crawling project in your R local directory, or in a custom directory
#' @param DIR character By default it's your local R workspace, if you set a custom folder for your crawling project then user DIR param to access this folder.
#' @return
#' \code{ListProjects}, a character vector.
#' @author salim khalil
#' @examples
#' \dontrun{
#' ListProjects()
#' }
#' @export
ListProjects <- function(DIR) {
  result<-""
  if(missing(DIR)){
    result<-list.files(paste0(getwd()),pattern = ".*-[0-9]{6}")
  } else {
    result<-list.files(paste0(DIR),pattern = ".*-[0-9]{6}")
  }
  if (length(result)==0) result<-"no project yet"
  return (result)
}
