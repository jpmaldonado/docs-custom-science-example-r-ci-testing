#' Example custom KBC application in R
#' @import methods
#' @import keboola.r.docker.application
#' @export CustomApplicationExample
#' @exportClass CustomApplicationExample
CustomApplicationExample <- setRefClass(
    'CustomApplicationExample',
    contains = c("DockerApplication"),
    fields = list(),
    methods = list(
        run = function() {
            "Main application run function."

            # intialize application
            readConfig()
	
			# Authentication request
			library(RCurl)
			library(httr)
			library(XML)
			apiURL <- getParameters()$apiURL
			UserName <- app$getParameters()$UserName
			PassWord <- app$getParameters()$PassWord
						
						# Authentication request
			body1 <- "<Envelope><Body>
			<Login>
			<USERNAME>UserName</USERNAME>
			<PASSWORD>PassWord</PASSWORD>
			</Login>
			</Body></Envelope>"

			body1 <- gsub("UserName", UserName, body1)
			body1 <- gsub("PassWord", PassWord, body1)

			test1 <- POST(url = apiURL, body = body1, 
						  verbose(), content_type("text/xml"))

			print("XML from the first response")
			print(test1)			  
						  
			parsed <- htmlParse(test1)
			js <- xpathSApply(parsed, "//session_encoding", xmlValue)
			
			print("Parsed session encoding")
			print(js)


			#Gather sessionid for future requests
			jsessionid <- gsub(";","?",js)
			
			print("Cookie for session id")
			print(jsessionid)


			body2 <- "<Envelope>
						<Body>           
						  <GetAggregateTrackingForOrg>
							<DATE_START>09/12/2016 00:00:00</DATE_START>              
							<DATE_END>01/01/2020 23:59:59</DATE_END> 
						  </GetAggregateTrackingForOrg>       
						</Body> 
					  </Envelope> "

			test2 <- POST(url = paste(apiURL,jsessionid,sep=""), body = body2, 
							  verbose(),
							  content_type("text/xml"))
				

			xml_data <- xmlParse(test2)

			print(test2)

			## 
			nodes <- getNodeSet(xml_data, "//Mailing")

			## Final data frame
			final_data <- xmlToDataFrame(nodes)
			print(head(final_data))
			print('hi')
			## You can save this in KBC using
			write.csv(final_data, "out/tables/aggregate.csv", row.names = F, quote = F)
        }
    )
)
