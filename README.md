# An R web crawler and scraper 

Rcrawler is an R package for web crawling websites and extracting structured data which can be used for a wide range of useful applications, like data mining, information processing or historical archival. The difference between Rcrawler and rvest, is that rvest enable you to extract data from one specific page, However Rcrawler function automaticaly traverse and parse all web pages of website, and extrat all data you need from them at once. For example collect all published posts on a blog, or extract all products on a shopping website ..etc.
## Summary
1- [RCrawler main features](https://github.com/salimk/Rcrawler#rcrawler-main-features)

2- [Installation](https://github.com/salimk/Rcrawler#installation)

3- [How to use Rcrawler (Tutorials)](https://github.com/salimk/Rcrawler#how-to-use-rcrawler)

4- [Design and Implementation](https://github.com/salimk/Rcrawler#design-and-implementation)

5- [How to cite Rcrawler](https://github.com/salimk/Rcrawler#how-to-cite-rcrawler)

6- [Updates history](https://github.com/salimk/Rcrawler#brief-on-updates)

## RCrawler main features  
With one single command Rcrawler function enable you to :

- Download all website's HTML pages, ([see 1](https://github.com/salimk/Rcrawler#1--collecting-web-pages-from-a-website))

- Extract structured DATA from all pages: Titles, posts, Films, descriptions etc ([see 3](https://github.com/salimk/Rcrawler#3-scrape-data-while-crawling-a-website))

- Scraping targeted contents using search terms, by providing desired keywords Rcrawler can traverse all wbesite links and collect/extract only web pages related to your topic. ([see 4](https://github.com/salimk/Rcrawler#4-filter-collected-scraped-web-page-by-search-termskeywords))

Some websites are so big, you don't have sufficient time or ressources to crawl them, So you are only interested in a particular section of the website for these reason we provided some useful parameters to control the crawling process such as : 

- Filtering collected/scraped Urls by URLS having some keyword or matching a specific pattern ([see 2](https://github.com/salimk/Rcrawler#2--filtering-collectedparsed-urls-by-regular-expression)) 

- Control how deep the crawler will go, how many levels Should be crawled from the start point.([see 5](https://github.com/salimk/Rcrawler#5-liming-the-crawling-process-to-a-level-maxdepth-parameter)) 

...

## Installation 

Install the release version from CRAN:
```
install.packages("Rcrawler")
```
Or the development version from GitHub:
```
# install.packages("devtools")
devtools::install_github("salimk/Rcrawler")
```
## How to use Rcrawler
To show you what Rcrawler brings to the table, we’ll walk you through some use case examples:
Start by loading the library
```
library(Rcrawler)
```

###### 1- Collecting web pages from a website
```
Rcrawler(Website = "http://www.glofile.com", no_cores = 4, no_conn = 4)
```
This command allows downloading all HTML files of a website from the server to your computer. It can be useful if you want to analyze or apply something on the whole web page (HTML file).  

At the end of crawling process this function will return :

- A variable named "INDEX" in the global environment: It's a data frame representing the general URL index, which includes all crawled/scraped web pages with their details (content type, HTTP state, the number of out-links and in-links, encoding type, and level). 
![INDEX variable](https://user-images.githubusercontent.com/17308124/31500701-0a153c9c-af60-11e7-85ea-15d40f7fe6cf.PNG)
- A directory named as the website's domain, in this case, "glofile.com" it's by default located in your working directory (R workspace). This directory contains all crawled and downloaded web pages (.html files). Files are named with the same numeric "id" they have in INDEX.
![File repository](https://user-images.githubusercontent.com/17308124/31500728-1ff15e6a-af60-11e7-89c9-b1aa1c4448eb.PNG)

NOTE: Make sure that the website you want to crawl is not so big, as it may take more computer resources and time to finish. Stay polite, avoid overloading the server, the chance to get banned from the host server is bigger when you use many parallel connections. 

###### 2- Filtering collected/parsed Urls by Regular expression
For some reason, you may want to collect just web pages having a specific urls pattern , like a website section, posts webpages. In this case, you need filter urls byuse Regular expressions . 

In the example below we know that all blog post has dates like 2017/09/08  in their URLs so we can tell the crawler to collect only these pages by flitging only URLs matching this regular expression "/[0-9]{4}/[0-9]{2}/[0-9]{2}/". Ulrs having 4-digit/2-digit/2-digit/, which are blog post pages in our example .
```
Rcrawler(Website = "http://www.glofile.com", no_cores = 4, no_conn = 4, urlregexfilter ="/[0-9]{4}/[0-9]{2}/[0-9]{2}/" )
```
Collected pages are like :
```
 http://www.glofile.com/2017/06/08/sondage-quel-budget-prevoyez-vous
 http://www.glofile.com/2017/06/08/jcdecaux-reconduction-dun-cont
 http://www.glofile.com/2017/06/08/taux-nette-detente-en-italie-bc
```
In the following example we crawl the whole website but we collect only pages in section "sport" in url.
```
Rcrawler(Website = "http://www.glofile.com/sport/", urlregexfilter ="/sport/" )
```
Downloded/Extracted Pages are like : 
```
http://www.glofile.com/sport/marseille-vitoria-guimaraes.html
http://www.glofile.com/sport/balotelli-a-la-conclusion-d-une-belle.html
http://www.glofile.com/sport/la-reprise-acrobatique-gagnante.html
```

**Note:** filtering URLs by a Regular expression, means the crawler will parse content (collect page) only from these specific URLs, It does not mean limiting the crawling process to only those particular URLs. In fact, if a website has 1000 links and just 200 matching the given regex, the crawler still need to crawl all 1000 link to find out these 200. if you want to limit the crawling process you can use MaxDepth parameter (refer to 5th section in this presentation)

###### 3-Scrape data while crawling a website
In the example below , we will try to extract articles and titles from our demo blog. To do this we need to filter out blog post pages (see 2), also we need to specify xpath pattern of elements to extract.  
```
Rcrawler(Website = "http://www.glofile.com", no_cores = 4, no_conn = 4, urlregexfilter ="/[0-9]{4}/[0-9]{2}/[0-9]{2}/", ExtractPatterns = c("//h1","//article"))
```
As result this function will return in addition to "INDEX" variable and file repository :
- A variable named "DATA" in global environment: It's a list of extracted contents. 
![DATA and INDEX variable](https://user-images.githubusercontent.com/17308124/31500758-3532af40-af60-11e7-9fed-0aab2eb0ff5b.PNG)

**Note :** before using ExtractPatterns on RCrawler function, try first to test your Xpath patterns on a single webpage to ensure that they extract targeted data, by using :
```
pageinfo<-LinkExtractor("http://glofile.com/index.php/2017/06/08/athletisme-m-a-rome/")
Data<-ContentScraper(pageinfo[[1]][[10]],c("//head/title","//*/article"))
```
Then check Data variable it should handle the extracted data, if it contain "NA", This means no data matching the given xpath are founded on the page. 
If you want to learn how to make your Xpath expression follow [this tutorial](https://www.w3schools.com/xml/xpath_syntax.asp)
More examples (here)

###### 4-Filter collected/ scraped web page by search terms/keywords
If you want to crawl a website and collect/scrape only some web pages related to a specific topic, Rcrawler function has two useful parameters KeywordsFilter and KeywordsAccuracy

KeywordsFilter: a character vector, here you should provide keywords/terms of the topic you are looking. Rcrawler will calculate an accuracy score based matched keywords and their occurrence on the page, then by default, it collects or scrapes only web pages with at least a score of 1% wich mean at least one keyword is founded one time on the page. This parameter must be a vector with at least one keyword like c("mykeyword").

KeywordsAccuracy. Integer value range between 0 and 100, used only with the KeywordsFilter parameter to determine the accuracy of web pages to collect. You can use one or more search terms; the accuracy will be calculated based on how many provided keywords exist on the page plus their occurrence rate. For example, if only one keyword is provided c("keyword") so ,
50% means one occurrence of "keyword" in the page
100% means five occurrences of "keyword" in the page 

```
Rcrawler(Website = "http://www.example.com/", KeywordsFilter = c("keyword1", "keyword2"))`
```
Crawl the website and collect only webpages containing keyword1 or keyword2 or both.

```
Rcrawler(Website = "http://www.example.com/", KeywordsFilter = c("keyword1", "keyword2"), KeywordsAccuracy = 50)
```
Crawl the website and collect only webpages that has an accuracy percentage higher than 50%
of matching keyword1 and keyword2.

###### 5-Liming the crawling process to a level (MaxDepth parameter) 
Some popular websites are too big, and you don't have time or don't want to crawl the whole website for a specific reason, or sometimes you may just need to crawl the top links in the specific web page. For this purpose, you could use Maxdepth parameter to limit the crawler from going so deep. 
Example to understand : A(B,C(E(H),F(G,k)),D) . Page A contain link B, C, D ; Page C contain E and F, page F contain G and K and page E contain H, In this example A is level 0 ,C represend Level 1 and E,F are both level 2 . 

```
Rcrawler(Website="http://101greatgoals.com/betting/" ,MaxDepth=1)
```
This command will parse only pages related to this link http://101greatgoals.com/betting/ (only links on that page will be crawled)

```
Rcrawler(Website="http://101greatgoals.com/betting/" ,MaxDepth=4, urlregexfilter = "/betting/")
```
In this example the crawler start from this http://101greatgoals.com/betting/ and continue crawling until it reach the 4th level , however it will only collect pages of "betting" section ( having /betting/ in their url)

###### Other Examples
Other example : 
```
Rcrawler(Website = "http://www.master-maroc.com", KeywordsFilter = c("casablanca", "master"), KeywordsAccuracy = 50, ExtractPatterns = c("//*[@class='article-content']","//*[@class='contentheading clearfix']"))
```
This command will crawl  http://www.master-maroc.com website and look for pages containing  keywords "casablanca" or "master", then data matching given Xpaths patterns are extracted .

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
## Updates history
Upcoming UPDATEs :
- when scraping a website with a given xpath patterns, the crawler should avoid scraping and extracting data from non-content pages ( webpages that does not matches any given pattern)
- MaxDeph params issue fixed
- Map all internal hyperlink connections within a given website and then construct Edges & Nodes Dataframe, Useful for Web structure mining.

UPDATE V 0.1.3 :

- Support HTTPS protocol
- Scraping articles by term search using keywords matching. 
- Fixing the subscript out of band error 

UPDATE V 0.1.2 :

- Fixing some issues opened on GitHub
- Drop simhash duplicate detection using java call due to many problems loading the package and rjava environment for many users.

UPDATE V 0.1.1 :

- Fix an issue in some examples (ignore special character which affected generated PDF ) 
- Add SystemRequirements field to Description with Java (>= 1.5)
- Compile java classes with a lower JDK (1.5), to overcome this error (Unsupported major.minor version 52.0) encountered during package check with r-patched-solaris-x86 and r-oldrel-osx-x86_64 


## How to make your Xpath expression 
1. First learn these expressions 

Expressions	 |Description
------------ | -------------
nodename | 	Selects all nodes with the name "nodename" might be div, table, span,tr,td, h1 ..etc 
/ 	| Selects from the root node
// |	Selects nodes in the document from the current node that match the selection no matter where they are
.  |	Selects the current node
.. | Selects the parent of the current node
@	 | Selects attributes

2-Start your browser Chrome or Firefox, then open your target web page sample to extarct, assume we want to extract this movie cast
http://www.imdb.com/title/tt1490017/ 

3- If you are using chrome, then right-click on one of the elements you want then select "Inspect" you shoud have a view similar to this one  
![xpath1](https://user-images.githubusercontent.com/17308124/31853011-908dbf7c-b679-11e7-9a7d-b1cde43f8933.PNG)4

4- As you can see at the bottom we have a field , its there where you shoud write and test your xpath expression first,  Above the field, there an inmportant list of elements all started with #  all those node#class represents the way from the document root to the element you have selected. We picked up three of them to build our xpath (1 2 3 marked in yellow).

5- Then we try to build and expression from those nodes : 
```
//*/div[@id='titleCast']//span[@class='itemprop']
```
This expression means : We look for any span with class='itemprop' no mather what they are BUT located under a div[@id='titleCast']  

6- At the end after writing your expression on the xpath search field, you shoud see how many nodes are founded. If no one match your expression then try to fix it out until you get some result. 
![xpath2](https://user-images.githubusercontent.com/17308124/31853205-cfb00a04-b67c-11e7-8a8c-66f3e75f085b.PNG)

###### Other Xpath examples :


