# RegenRangersODC
On-Chain Graph-Style Analysis with Gitcoin

A Network Exploration of StampDNA and GrantDNA

## Datasets and Codebase in the Repo
`data` Folder contains the ODC datasets which were hosted by ODC team on Ocean Protocol.

`data/all_projects.csv` Passport Data : [Oceanprotocol Link](https://odc.oceanprotocol.com/asset/did:op:7b4a1d9a7bfc234f5d02403d8715217facb237abf71a1e5a325f9e016533ae63) : The scrape of passport stamps from gitcoin passport API for all 58946 Gitcoin Donors with a valid passport in a csv file.

`data_out` Folder contains the intermediate datasets saved out during the analysis like GrantDNA, StampDNA

`grantNetwork.R` R script to perform the network analysis on Grants data and save GrantDNA network plot and GrantDNA heatmap.

`passNetwork.R` R script to perform the network analysis on Stamps data and save StampDNA network plot and StampDNA heatmap.

`passScrape.R` R script used to scrpae all the stamp data from the Gitcoin Passport API.

## Visualisations
`StampClusters.html` StampDNA Cluster Network Interactive HTML : [Oceanprotocol Link](https://odc.oceanprotocol.com/asset/did:op:1bf67860af7fd3091dff12b17b0a6328464b1c5c8a32aa800b2c2e610ff8beb6) : A network plot showing the clusters identified within stamps who share a sufficient amount of passports holding them.

`StampHeatmap.html` StampDNA Cluster Heatmap Interactive HTML : [Oceanprotocol Link](https://odc.oceanprotocol.com/asset/did:op:d5f8758129a82a7f672451e03ffa467462b71049cfb261395efa98fa4a0279dc) : Heatmap for all stamps showing the Jaccard Distance between them.

`GrantClusters.html` GrantDNA Cluster Network Interactive HTML : [Oceanprotocol Link](https://odc.oceanprotocol.com/asset/did:op:bd42523b92fb44c367394eb7ae87a9eaf83ae758526a5e0cd56446449dd525b9) : A network plot showing the clusters identified within grants who share a sufficient amount of donors between them.

`GrantHeatmap.html` GrantDNA Cluster Heatmap Interactive HTML : [Oceanprotocol Link](https://odc.oceanprotocol.com/asset/did:op:20a18bd37220f9dc6fa2a1464e921606844998975d5f2b661c5074e89a6d3ffb) : Heatmap for all grants showing the Jaccard Distance between them.
