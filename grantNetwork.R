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
data <- read_csv("~/Desktop/odc/data/GR15.csv")
data <- data[data$grant_id!=12,]
###########################################################################
###########################################################################


###########################################################################
## Create Binary Matrix for Grant as rows and donors as columns
###########################################################################
all_grants <- sort(unique(data$grant_id))
all_users <- sort(unique(data$address))
data_split <- split(data,data$grant_id)
matlist <- list()
for(idx in 1:length(all_grants))
{
	t_data <- data_split[[as.character(all_grants[idx])]]
	matlist[[idx]] <- as.numeric(all_users %in% t_data$address)
	message(idx)
}
data_mat <- do.call(rbind,matlist)
rownames(data_mat) <- as.character(all_grants)
colnames(data_mat) <- all_users
saveRDS(data_mat,"~/Desktop/odc/data_out/GrantsBinmat.RDS")
write_csv(data_mat,"~/Desktop/odc/data_out/GrantsBinmat.RDS")
###########################################################################
###########################################################################


###########################################################################
## Create Distance Matrix 
###########################################################################
dist_mat_grant <- parDist(data_mat,method="binary")
saveRDS(dist_mat_grant,"~/Desktop/odc/data_out/GrantsDistmat.RDS")
###########################################################################
###########################################################################


###########################################################################
## Visualising Similar Grants (Cluster Network)
###########################################################################
dist_cutoff_is_match = .05

dist_mat_grant <- as.matrix(readRDS("~/Desktop/odc/data_out/GrantsDistmat.RDS"))
diag(dist_mat_grant) <- 1
matches <- apply(dist_mat_grant,1,function(x,dist_cutoff_is_match) names(which(x<=dist_cutoff_is_match)),dist_cutoff_is_match=dist_cutoff_is_match)
matches <- matches[sapply(matches,length)>0]
matches_nodes <- data.frame(
							name = unique(c(names(matches),unlist(matches))),
							size = 1,
							group = "Grant"
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
) %>% prependContent(htmltools::tags$h1(paste0("GrantDNA Clusters Sharing more than ",100*(1-dist_cutoff_is_match),"% Donors, Each Node is a GrantID"))) %>% 
  saveNetwork(file = 'GrantClusters.html')
###########################################################################
###########################################################################


###########################################################################
## Visualising Similar Grants (Heatmap)
###########################################################################
dist_cutoff_is_match = .2
dist_mat_grant <- as.matrix(readRDS("~/Desktop/odc/data_out/GrantsDistmat.RDS"))
diag(dist_mat_grant) <- 1
if_match <- apply(dist_mat_grant,1,function(x,dist_cutoff_is_match) any(x<=dist_cutoff_is_match),dist_cutoff_is_match=dist_cutoff_is_match,simplify=TRUE)
dist_mat_grant_matches <- dist_mat_grant[if_match,if_match]
heatmaply_cor(
	dist_mat_grant_matches,
	scale_fill_gradient_fun = ggplot2::scale_fill_gradient2(low = "red", high = "white", midpoint = .99, limits = c(0, 1)),
	dendrogram=TRUE,
	limits=c(0,1),
	fontsize_row = 4,
	fontsize_col = 5,
	label_names = c("GrantID ", "GrantID", "Distance"),
	row_text_angle=0,
	column_text_angle=90,
	file = "GrantHeatmap.html"
)
###########################################################################
###########################################################################

