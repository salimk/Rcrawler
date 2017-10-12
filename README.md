# An R web crawler and scraper 

Rcrawler is an R package for web crawling web sites and extracting structured data which can be used for a wide range of useful applications, like data mining, information processing or historical archival.
## RCrawler main features  

## Installation 

Install the release version from CRAN:
```
install.packages("Rcrawler")
```
Or the development version from github:
```
# install.packages("devtools")
devtools::install_github("salimk/Rcrawler")
```
## How to use Rcrawler
In order to show you what Rcrawler brings to the table, we’ll walk you through some use case examples:
Start by loading the library
```
library(Rcrawler)
```

###### 1- Collecting web pages from a website
```
Rcrawler(Website = "http://www.glofile.com", no_cores = 4, no_conn = 4)
```
This command allows downloading all HTML files of a website from the server to your computer. It can be useful if you want to do analysis on the whole web page (HTML file). Also, if you want to use a specific data extraction technique on collected web pages.

At the end of crawling process this function will return :

- A variable named "INDEX" in global environment: It's a data frame representing the generic URL index, which includes all crawled/scraped web pages with their details (content type, HTTP state, the number of out-links and in-links, encoding type, and level). 
![INDEX variable](https://user-images.githubusercontent.com/17308124/31500701-0a153c9c-af60-11e7-85ea-15d40f7fe6cf.PNG)
- A directory named as the website's domain, in this case, "glofile.com" it's by default located in your working directory (R workspace). This directory contains all crawled and downloaded web pages (.html files). Files are named with the same numeric "id" they have in INDEX.
![File repository](https://user-images.githubusercontent.com/17308124/31500728-1ff15e6a-af60-11e7-89c9-b1aa1c4448eb.PNG)

NOTE: Make sure that the website you want to crawl is not so big, as it may take more computer resources and time to finish. Stay polite, avoid overloading the server, the chance to get banned from the host server is bigger when you use many parallel connections. 

###### 2- Filtering collected/parsed Urls by Regular expression
As you know a Web page might be a category page (list of elements,) or a detail page (like product/article page). For some reason, you may want to collect just the detail pages or you may want to collect just pages in a particular website section. In this case, you need to use Regular expressions as it's shown below:
```
Rcrawler(Website = "http://www.glofile.com", no_cores = 4, no_conn = 4, urlregexfilter ="/[0-9]{4}/[0-9]{2}/[0-9]{2}/" )
```
This command collect all URLs matching this regular expression "/[0-9]{4}/[0-9]{2}/[0-9]{2}/". Ulrs having 4-digit/2-digit/2-digit/, which are blog post pages in our example .
```
 http://www.glofile.com/2017/06/08/sondage-quel-budget-prevoyez-vous
 http://www.glofile.com/2017/06/08/jcdecaux-reconduction-dun-cont
 http://www.glofile.com/2017/06/08/taux-nette-detente-en-italie-bc
```
###### 3-Scrape data while crawling a website
In the example below , we will try to extract articles and titles from our demo blog. To do this we need to filter out blog post pages (see 2), also we need to specify xpath pattern of elements to extract.  
```
Rcrawler(Website = "http://www.glofile.com", no_cores = 4, no_conn = 4, urlregexfilter ="/[0-9]{4}/[0-9]{2}/[0-9]{2}/", ExtractPatterns = c("//h1","//article"))
```
As result this function will return in addition to "INDEX" variable and file repository :
- A variable named "DATA" in global environment: It's a list of extracted contents. 
![DATA and INDEX variable](https://user-images.githubusercontent.com/17308124/31500758-3532af40-af60-11e7-9fed-0aab2eb0ff5b.PNG)

###### 4-Filter collected/ scraped web page by search terms/keywords
If you want to crawl a website and collect/scrape only some web pages related to a specific topic, Rcrawler function has two useful parameters KeywordsFilter and KeywordsAccuracy

KeywordsFilter : a character vector, here you should provide keywords/temrs of the topic you are looking, Rcrawler will calculate an accuracy score based matched keywords and their occurence on the page, then by default it collects or scrape only webpage with at lease a score of 1% wich mean at least on keyword is founded one time on the page. This parameter must be a vector with at least one keyword like c("mykeyword").

KeywordsAccuracy. integer value range bewteen 0 and 100, used only with KeywordsFilter parameter to determine the accuracy of web pages to collect. You can use one or more search terms, the accuracy will be calculated based on how many provided keywords exist on the page plus their occurrence rate.    
```
Rcrawler(Website = "http://www.example.com/", KeywordsFilter = c("keyword1", "keyword2"))`
```
Crawl the website and collect only webpages containing keyword1 or keyword2 or both.

```
Rcrawler(Website = "http://www.example.com/", KeywordsFilter = c("keyword1", "keyword2"), KeywordsAccuracy = 50)
```
Crawl the website and collect only webpages that has an accuracy percentage higher than 50%
of matching keyword1 and keyword2.


## Design and Implementation
If you want to learn more about web scraper/crawler architecture, functional properties and implementation using R language, you can download the published paper for free from this link :  [R web scraping](http://www.sciencedirect.com/science/article/pii/S2352711017300110)
## How to cite Rcrawler
Our paper is submitted, you can cite our work

###### APA :
`
Khalil, S., & Fakir, M. (2017). RCrawler: An R package for parallel web crawling and scraping. SoftwareX, 6, 98-106.
`

###### Bibtex :
`
@article{khalil2017rcrawler,
  title={RCrawler: An R package for parallel web crawling and scraping},
  author={Khalil, Salim and Fakir, Mohamed},
  journal={SoftwareX},
  volume={6},
  pages={98--106},
  year={2017},
  publisher={Elsevier}
}
`
## Brief on Updates
UPDATE V 0.1.3 :

- Support HTTPS protocole
- Scraping articles filtered by term search using keywords matching. 
- Fixing the subscript out of band error 

UPDATE V 0.1.2 :

- Fixing some issues opened on github
- Drop  simhash dulicate detection using java call due to many problems loading the package and rjava environement for many users.

UPDATE V 0.1.1 :

- Fix an issue in some examples (ignore special character which had effect on generated PDF ) 
- Add SystemRequirements field to Description with Java (>= 1.5)
- Compile java classe with a lower JDK (1.5), to overcome this error (Unsupported major.minor version 52.0) encountered during package check with r-patched-solaris-x86 and r-oldrel-osx-x86_64 
