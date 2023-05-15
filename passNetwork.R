###########################################################################
## Load raw data clean it and save for further processing
###########################################################################
## Load Required Libraries
library(readr)
library(jsonlite)
library(parallelDist)
library(networkD3)
library(magrittr)
library(htmlwidgets)
library(heatmaply)
options(scipen=999)
rmarkdown::find_pandoc(dir="/opt/homebrew/bin")

## Load contribution Data for a Round
data <- read_csv("~/Desktop/odc/data/passStamps.csv")
###########################################################################
###########################################################################


###########################################################################
## Create Binary Matrix for Grant as rows and donors as columns
###########################################################################
all_stamps <- unique(data$pass_cred_ame)
all_users <- sort(unique(data$address))
data_split <- split(data,data$pass_cred_ame)
matlist <- list()
for(idx in 1:length(all_stamps))
{
	t_data <- data_split[[as.character(all_stamps[idx])]]
	matlist[[idx]] <- as.numeric(all_users %in% t_data$address)
	message(idx)
}
data_mat <- do.call(rbind,matlist)
rownames(data_mat) <- as.character(all_stamps)
colnames(data_mat) <- all_users
saveRDS(data_mat,"~/Desktop/odc/data_out/StampsBinmat.RDS")
###########################################################################
###########################################################################


###########################################################################
## Create Distance Matrix 
###########################################################################
dist_mat_stamp <- parDist(data_mat,method="binary")
saveRDS(dist_mat_stamp,"~/Desktop/odc/data_out/StampsDistmat.RDS")
###########################################################################
###########################################################################


###########################################################################
## Visualising Similar Grants (Cluster Network)
###########################################################################
dist_cutoff_is_match = .4

dist_mat_stamp <- as.matrix(readRDS("~/Desktop/odc/data_out/StampsDistmat.RDS"))
diag(dist_mat_stamp) <- 1
matches <- apply(dist_mat_stamp,1,function(x,dist_cutoff_is_match) names(which(x<=dist_cutoff_is_match)),dist_cutoff_is_match=dist_cutoff_is_match)
matches <- matches[sapply(matches,length)>0]
matches_nodes <- data.frame(
							name = unique(c(names(matches),unlist(matches))),
							size = 1,
							group = "Stamp"
					)
matches_links <- data.frame(source=numeric(0),target=numeric(0),value=numeric(0))
for(idx in 1:length(matches))
{
	if(length(matches[[idx]])==0) next()
	tdata <- data.frame(
						source = match(names(matches)[idx],matches_nodes$name)-1,
						target = match(matches[[idx]],matches_nodes$name)-1,
						value=1
					)
	matches_links <- rbind(matches_links,tdata)
}
forceNetwork(
				Links = matches_links,
				Nodes = matches_nodes,
				Source = "source", 
				Target = "target",
				Value = "value", 
				NodeID = "name",
				Nodesize = "size",
				Group = "group",
				opacity = 1,
				legend = FALSE,
				opacityNoHover=1,
				fontSize = 10,
				bounded=TRUE
) %>% prependContent(htmltools::tags$h1(paste0("StampDNA Clusters Sharing more than ",100*(1-dist_cutoff_is_match),"% Passport Holders, Each Node is a Stamp"))) %>% 
  saveNetwork(file = 'StampClusters.html')
###########################################################################
###########################################################################


###########################################################################
## Visualising Similar Grants (Heatmap)
###########################################################################
dist_cutoff_is_match = .01
dist_mat_stamp <- as.matrix(readRDS("~/Desktop/odc/data_out/StampsDistmat.RDS"))
diag(dist_mat_stamp) <- 1
# if_match <- apply(dist_mat_stamp,1,function(x,dist_cutoff_is_match) any(x<=dist_cutoff_is_match),dist_cutoff_is_match=dist_cutoff_is_match,simplify=TRUE)
# dist_mat_stamp_matches <- dist_mat_stamp[if_match,if_match]
heatmaply_cor(
	dist_mat_stamp,
	scale_fill_gradient_fun = ggplot2::scale_fill_gradient2(low = "red", high = "white", midpoint = .99, limits = c(0, 1)),
	dendrogram=TRUE,
	limits=c(0,1),
	fontsize_row = 4,
	fontsize_col = 5,
	label_names = c("Stamp", "Stamp ", "Distance"),
	row_text_angle=0,
	column_text_angle=90,
	file = "StampHeatmap.html"
)
###########################################################################
###########################################################################

