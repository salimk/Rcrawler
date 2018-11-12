#'LoadHTMLFiles
#'  @rdname LoadHTMLFiles
#' @param ProjectName character, the name of the folder holding collected HTML files, use \code{ListProjects} fnuction to see all projects.
#' @param type character, the type of returned variable, either vector or list.
#' @param max Integer, maximum number of files to load.
#' @return
#' \code{LoadHTMLFiles}, a character vector or a list;
#' @author salim khalil
#' @export
#' @examples
#' \dontrun{
#' ListProjects()
#' #show all crawling project folders stored in your local R wokspace folder
#' DataHTML<-LoadHTMLFiles("glofile.com-301010")
#' #Load all HTML files in DataHTML vector
#' DataHTML2<-LoadHTMLFiles("glofile.com-301010",max = 10, type = "list")
#' #Load only 10 first HTMl files in DataHTML2 list
#' }

LoadHTMLFiles <- function(ProjectName, type="vector", max) {
  Listfiles<-list.files(paste0(getwd(),"/",ProjectName),pattern = ".*\\.html")

  if(type=="vector") result<-vector()
  else if(type=="list") result<-list()
  else stop ("Unknown type , choose either vector or list")
  if(length(Listfiles)>0){
    if (missing(max)){
      for (f in Listfiles ){
        filetxt<-readChar(paste0(getwd(),"/",ProjectName,"/",f),file.info(paste0(getwd(),"/",ProjectName,"/",f))$size )
        result<-c(result, filetxt)
      }
    } else {
      i=1
      while(i<=max){
        filetxt<-readChar(paste0(getwd(),"/",ProjectName,"/",Listfiles[i]),file.info(paste0(getwd(),"/",ProjectName,"/",Listfiles[i]))$size )
        result<-c(result, filetxt)
        i<-i+1
      }
    }
  } else stop("Folder does not contain any html file")
  return (result)
}

