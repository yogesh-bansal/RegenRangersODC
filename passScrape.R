## Load Required Libraries
library(httr)
library(readr)
library(jsonlite)
library(parallel)

## Read Data
data <- fromJSON("~/Desktop/odc/data/passport_valid.json")

###########################################################################
## Function to get passport
###########################################################################
robustGETsps <- function(url)
{
	tridx <- 0
	while(TRUE)
	{
		keyset <- c("key1","key2","key3","key4","key5")
		query <- GET(url,add_headers("X-API-Key" = sample(keyset,1)))
		if(query$status_code==200 | tridx > 0) return(query)
		tridx <- tridx+1
		Sys.sleep(300)
	}
}
get_passport <- function(wall)
{
	res <- robustGETsps(paste0("https://api.scorer.gitcoin.co/registry/stamps/",wall,"?limit=1000"))
	if(res$status_code!=200) message("429")
	parsed <- content(res)$items
	if(length(parsed)!=0)
	{
		parseddf <- do.call(rbind,lapply(parsed,as.data.frame))
		passdata <- data.frame(
								address = wall,
								has_passport=TRUE,
								pass_cred_ame = parseddf$credential.credentialSubject.provider,
								pass_cred_issuer = parseddf$credential.issuer,
								pass_cred_issue_date = parseddf$credential.issuanceDate,
								pass_cred_expiry_date = parseddf$credential.expirationDate
					)
		write_csv(passdata,paste0("~/Desktop/passres/",wall,".csv"))
	}
}
###########################################################################
###########################################################################


###########################################################################
## Scrape Passport Data
###########################################################################
## Fetch PassData
while(TRUE)
{
	## Remaining
	doneF <- gsub(".csv","",list.files("~/Desktop/passres"))
	remF <- data[!data %in% doneF]
	message(paste0(length(doneF),"/",length(data),":",Sys.time()))

	## Run In parallel
	mclapply(remF,get_passport,mc.cores=12,mc.preschedule=FALSE)
}
###########################################################################
###########################################################################


###########################################################################
## Parse Passport Data
###########################################################################
## Load Libraries
library(readr)
library(tidyverse)

## Load all data
all_csvs <- list.files("~/Desktop/passres/",full.names=TRUE)
passdatal <- list()
for(idx in 1:length(all_csvs))
{
	passdatal[[idx]] <- read_csv(all_csvs[idx],show_col_types = FALSE)
	message(paste0(idx,"/",length(all_csvs)))
}
passdata <- bind_rows(passdatal)
write_csv(passdata,"~/Desktop/odc/data/PassStamps.csv")
###########################################################################
###########################################################################


