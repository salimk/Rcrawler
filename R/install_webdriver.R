## This is from the webshot package, see https://github.com/wch/webshot

#' Install PhantomJS webdriver
#'
#' Download the zip package, unzip it, and copy the executable to a system
#' directory in which \pkg{webdriver} can look for the PhantomJS executable.
#'
#' This function was designed primarily to help Windows users since it is
#' cumbersome to modify the \code{PATH} variable. Mac OS X users may install
#' PhantomJS via Homebrew. If you download the package from the PhantomJS
#' website instead, please make sure the executable can be found via the
#' \code{PATH} variable.
#'
#' On Windows, the directory specified by the environment variable
#' \code{APPDATA} is used to store \file{phantomjs.exe}. On OS X, the directory
#' \file{~/Library/Application Support} is used. On other platforms (such as
#' Linux), the directory \file{~/bin} is used. If these directories are not
#' writable, the directory \file{PhantomJS} under the installation directory of
#' the \pkg{webdriver} package will be tried. If this directory still fails, you
#' will have to install PhantomJS by yourself.
#' @param version The version number of PhantomJS.
#' @param baseURL The base URL for the location of PhantomJS binaries for
#'   download. If the default download site is unavailable, you may specify an
#'   alternative mirror, such as
#'   \code{"https://bitbucket.org/ariya/phantomjs/downloads/"}.
#' @return \code{NULL} (the executable is written to a system directory).
#'
#' @export

install_browser <- function(version = '2.1.1',
                              baseURL = 'https://github.com/wch/webshot/releases/download/v0.3.1/') {

  if (!grepl("/$", baseURL))
    baseURL <- paste0(baseURL, "/")

  owd <- setwd(tempdir())
  on.exit(setwd(owd), add = TRUE)
  if (is_windows()) {
    zipfile <- sprintf('phantomjs-%s-windows.zip', version)
    download(paste0(baseURL, zipfile), zipfile, mode = 'wb')
    utils::unzip(zipfile)
    zipdir <- sub('.zip$', '', zipfile)
    exec <- file.path(zipdir, 'bin', 'phantomjs.exe')
  } else if (is_osx()) {
    zipfile <- sprintf('phantomjs-%s-macosx.zip', version)
    download(paste0(baseURL, zipfile), zipfile, mode = 'wb')
    utils::unzip(zipfile)
    zipdir <- sub('.zip$', '', zipfile)
    exec <- file.path(zipdir, 'bin', 'phantomjs')
    Sys.chmod(exec, '0755')  # chmod +x
  } else if (is_linux()) {
    zipfile <- sprintf(
      'phantomjs-%s-linux-%s.tar.bz2', version,
      if (grepl('64', Sys.info()[['machine']])) 'x86_64' else 'i686'
    )
    download(paste0(baseURL, zipfile), zipfile, mode = 'wb')
    utils::untar(zipfile)
    zipdir <- sub('.tar.bz2$', '', zipfile)
    exec <- file.path(zipdir, 'bin', 'phantomjs')
    Sys.chmod(exec, '0755')  # chmod +x
  } else {
    # Unsupported platform, like Solaris
    message("Sorry, this platform is not supported.")
    return(invisible())
  }
  success <- FALSE
  dirs <- phantom_paths()
  for (destdir in dirs) {
    dir.create(destdir, showWarnings = FALSE)
    success <- file.copy(exec, destdir, overwrite = TRUE)
    if (success) break
  }
  unlink(c(zipdir, zipfile), recursive = TRUE)
  if (!success) stop(
    'Unable to install PhantomJS to any of these dirs: ',
    paste(dirs, collapse = ', ')
  )
  message('phantomjs has been installed to ', normalizePath(destdir))
  invisible()
}

# Possible locations of the PhantomJS executable
phantom_paths <- function() {
  if (is_windows()) {
    path <- Sys.getenv('APPDATA', '')
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else if (is_osx()) {
    path <- '~/Library/Application Support'
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else {
    path <- '~/bin'
  }
  path <- c(path, system.file('PhantomJS', package = 'webdriver'))
  path
}

# Find PhantomJS from PATH, APPDATA, system.file('webdriver'), ~/bin, etc
find_phantom <- function() {

  for (d in phantom_paths()) {
    exec <- if (is_windows()) "phantomjs.exe" else "phantomjs"
    path <- file.path(d, exec)
    if (utils::file_test("-x", path)) break else path <- ""
  }

  if (path == "") {
    path <- Sys.which( "phantomjs" )
    if (path != "") return(path)
  }

  if (path == "") {
    # It would make the most sense to throw an error here. However, that would
    # cause problems with CRAN. The CRAN checking systems may not have phantomjs
    # and may not be capable of installing phantomjs (like on Solaris), and any
    # packages which use webdriver in their R CMD check (in examples or vignettes)
    # will get an ERROR. We'll issue a message and return NULL; other
    message(
      "PhantomJS not found. You can install it with webdriver::install_phantomjs(). ",
      "If it is installed, please make sure the phantomjs executable ",
      "can be found via the PATH variable."
    )
    return(NULL)
  }
  path.expand(path)
}


## This is from the webshot package, see https://github.com/wch/webshot

# Wrapper for utils::download.file which works around a problem with R 3.3.0 and
# 3.3.1. In these versions, download.file(method="libcurl") issues a HEAD
# request to check if a file is available, before sending the GET request. This
# causes problems when downloading attached files from GitHub binary releases
# (like the PhantomJS binaries), because the url for the GET request returns a
# 403 for HEAD requests. See
# https://stat.ethz.ch/pipermail/r-devel/2016-June/072852.html
download <- function(url, destfile, mode = "w") {
  if (getRversion() >= "3.3.0") {
    download_no_libcurl(url, destfile, mode = mode)

  } else if (is_windows() && getRversion() < "3.2") {
    # Older versions of R on Windows need setInternet2 to download https.
    download_old_win(url, destfile, mode = mode)

  } else {
    utils::download.file(url, destfile, mode = mode)
  }
}


# Adapted from downloader::download, but avoids using libcurl.
download_no_libcurl <- function(url, ...) {
  # Windows
  if (is_windows()){
    if(capabilities("libcurl")){
      method <- "libcurl"
    } else {
      method <- "wininet"
    }
    utils::download.file(url, method = method, ...)

  } else {
    # If non-Windows, check for libcurl/curl/wget/lynx, then call download.file with
    # appropriate method.

    if (nzchar(Sys.which("wget")[1])) {
      method <- "wget"
    } else if (nzchar(Sys.which("curl")[1])) {
      method <- "curl"

      # curl needs to add a -L option to follow redirects.
      # Save the original options and restore when we exit.
      orig_extra_options <- getOption("download.file.extra")
      on.exit(options(download.file.extra = orig_extra_options))

      options(download.file.extra = paste("-L", orig_extra_options))

    } else if (nzchar(Sys.which("lynx")[1])) {
      method <- "lynx"
    } else {
      stop("no download method found")
    }

    utils::download.file(url, method = method, ...)
  }
}
# Adapted from downloader::download, for R<3.2 on Windows
download_old_win <- function(url, ...) {
  # If we directly use setInternet2, R CMD CHECK gives a Note on Mac/Linux
  seti2 <- `::`(utils, 'setInternet2')

  # Check whether we are already using internet2 for internal
  internet2_start <- seti2(NA)

  # If not then temporarily set it
  if (!internet2_start) {
    # Store initial settings, and restore on exit
    on.exit(suppressWarnings(seti2(internet2_start)))

    # Needed for https. Will get warning if setInternet2(FALSE) already run
    # and internet routines are used. But the warnings don't seem to matter.
    suppressWarnings(seti2(TRUE))
  }

  method <- "internal"

  # download.file will complain about file size with something like:
  #       Warning message:
  #         In download.file(url, ...) : downloaded length 19457 != reported length 200
  # because apparently it compares the length with the status code returned (?)
  # so we supress that
  utils::download.file(url, method = method, ...)
}


#' Return browser (webdriver) location path
#'
#' After installing webdriver using \code{\link{install_browser}},
#' you can check its location path by running this function.
#'
#' @return
#'   path as character
#'
#' @author salim khalil
#' @examples
#'
#' \dontrun{
#'
#' browser_paths()
#' }
#' @export

browser_path <- function() {

  if (is_windows()) {
    path <- Sys.getenv('APPDATA', '')
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else if (is_osx()) {
    path <- '~/Library/Application Support'
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else {
    path <- '~/bin'
  }
  path <- c(path, system.file('PhantomJS', package = 'webdriver'))
  path
}

