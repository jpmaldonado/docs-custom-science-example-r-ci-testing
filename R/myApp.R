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

            # read input
            #data <- read.csv(file = file.path(dataDir, "in/tables/source.csv"));

            # do something clever
            #data['double_number'] <- data['number'] * getParameters()$multiplier

            # write output
            #write.csv(data, file = file.path(dataDir, "out/tables/result.csv"), row.names = FALSE)
			
			
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


			parsed <- htmlParse(test1)
			js <- xpathSApply(parsed, "//session_encoding", xmlValue)

			#Gather sessionid for future requests
			jsessionid <- gsub(";","?",js)


			## Date parameters: COULD WE PASS DATE PARAMETERS FROM THE ORCHESTRATION LAYER?
			body2 <- "<Envelope><Body>           
			<GetAggregateTrackingForOrg>
			<DATE_START>09/12/2016 00:00:00</DATE_START>              
			<DATE_END>12/31/2017 23:59:59</DATE_END> 
			</GetAggregateTrackingForOrg>       
			</Body> </Envelope> "




			attempts <- 2
			delay <- 20
			attempt <- 1
			test2 <- NULL

			while(is.null(test2) && attempt <= attempts ) {
			  attempt <- attempt + 1
			  Sys.sleep(delay)
			  try(
				
				test2 <- POST(url = paste(apiURL,jsessionid,sep=""), body = body2, 
							  verbose(),
							  content_type("text/xml"))
				
			  )
			} 

			xml_data <- xmlParse(test2)

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
