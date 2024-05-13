#!/usr/bin/env Rscript

# creator: Elizabeth Brooks
# updated: 4 May 2024

# install any missing packages
packageList <- c("BiocManager", "shiny", "shinythemes", "ggplot2", "rcartocolor", "dplyr", "statmod", "pheatmap", "ggplotify")
biocList <- c("edgeR")
newPackages <- packageList[!(packageList %in% installed.packages()[,"Package"])]
newBioc <- biocList[!(biocList %in% installed.packages()[,"Package"])]
if(length(newPackages)){
  install.packages(newPackages)
}
if(length(newBioc)){
  BiocManager::install(newBioc)
}

# load packages 
suppressPackageStartupMessages({
  library(shiny)
  library(shinythemes)
  library(ggplot2)
  library(rcartocolor)
  library(edgeR)
  library(dplyr)
  library(pheatmap)
  library(ggplotify)
})

#  plotting palettes
plotColors <- carto_pal(12, "Safe")
plotColorSubset <- c(plotColors[4], plotColors[5], plotColors[6])


##
# Data Input
##

# import gene count data
inputData <- read.csv(file="/Users/bamflappy/Repos/freeCount/data/DA_DEAnalysis/example2_tribolium_counts.csv", row.names=1)

# trim the data table of htseq stats
removeList <- c("__no_feature", "__ambiguous", "__too_low_aQual", "__not_aligned", "__alignment_not_unique")
countsTable <- inputData[!row.names(inputData) %in% removeList,]

# import grouping factor
targets <- read.csv(file="/Users/bamflappy/Repos/freeCount/data/DA_DEAnalysis/example2_tribolium_design_edgeR.csv", row.names=1)

# set LFC cut off
cutLFC <- log2(1.2)

# set FDR cut off
cutFDR <- 0.05


##
# Data Setup
##

# setup a design matrix
group <- factor(targets[,1])

# create DGE list object
countsList <- DGEList(counts=countsTable,group=group)
colnames(countsList) <- rownames(targets)

# combine all columns into one period separated
exp_factor <- data.frame(Sample = unlist(targets, use.names = FALSE))
rownames(exp_factor) <- colnames(inputData)

# plot the library sizes before normalization
barplot(countsList$samples$lib.size*1e-6, names=1:ncol(countsList), ylab="Library size (millions)")

# retrieve raw counts in log2 CPM
rawCounts <- cpm(countsList, log=TRUE, normalized.lib.sizes=FALSE)

# create heatmap of raw CPM
pheatmap(rawCounts, scale="row", annotation_col = exp_factor, 
         main="Heatmap of Raw CPM", show_rownames = FALSE, fontsize = 12,
         color = colorRampPalette(c(plotColors[5], "white", plotColors[6]))(100))


##
# Data Filtering & Normalization
##

# retain genes only if it is expressed at a minimum level
keep <- filterByExpr(countsList)
summary(keep)
list <- countsList[keep, , keep.lib.sizes=FALSE]

# use TMM normalization to eliminate composition biases between libraries
list <- calcNormFactors(list)

# plot the library sizes after normalization (not useful)
# see: https://support.bioconductor.org/p/112276/
# "So if you are asking 'does calcNormFactors directly affect my library size?', then no, not until the modeling step"
barplot(list$samples$lib.size*1e-6, names=1:ncol(list), ylab="Library size (millions)")

# retrieve normalized counts in CPM
normList <- cpm(list, normalized.lib.sizes=TRUE)

# add gene row name tag
normList <- as_tibble(normList, rownames = "gene")

# calculate the log CPM of the normalized counts data
logcpm <- cpm(list, log=TRUE)

# create heatmap of normalized CPM
pheatmap(logcpm, scale="row", annotation_col = exp_factor, 
           main="Heatmap of Normalized CPM", show_rownames = FALSE, fontsize = 12,
           color = colorRampPalette(c(plotColors[5], "white", plotColors[6]))(100))

# verify TMM normalization using a MD plot
plotMD(logcpm, column=1)
abline(h=0, col=plotColorSubset[3], lty=2, lwd=2)

# setup for MDS plotting
points <- c(0,1,2,3,15,16,17,18)
colors <- rep(c(plotColors[4], plotColors[5], plotColors[6], plotColors[11]), 2)

# use a MDS plot to visualizes the differences
# between the expression profiles of different samples
# it may be necessary to adjust legend placement
par(mar=c(5.1, 4.1, 4.1, 11.1), xpd=TRUE)
plotMDS(list, col=colors[group], pch=points[group])
legend("topright", inset=c(-0.8,0), legend=levels(group), pch=points, col=colors, ncol=2)

# create a PCA plot
# it may be necessary to adjust legend placement
par(mar=c(5.1, 4.1, 4.1, 11.1), xpd=TRUE)
plotMDS(list, col=colors[group], pch=points[group], gene.selection="common")
legend("topright", inset=c(-0.8,0), legend=levels(group), pch=points, col=colors, ncol=2)


##
# Analysis Setup
##
# the experimental design is parametrized with a one-way layout, 
# where one coefficient is assigned to each group
design <- model.matrix(~ 0 + group)
colnames(design) <- levels(group)

#Next, the NB dispersion is estimated
list <- estimateDisp(list, design, robust=TRUE)

# visualize the dispersion estimates with a BCV plot
plotBCV(list)

# estimate and plot the QL dispersions
fit <- glmQLFit(list, design, robust=TRUE)

# show QL dispersions plot
plotQLDisp(fit)

# view column order
colnames(fit)


##
# Analysis
##

###
## Exact Test
###
# exact test
treat.exact <- exactTest(list, pair=c("treat.24h", "cntrl.24h"))

# summary table
summary(decideTests(treat.exact))

# retrieve tables of DE genes
resultsTbl_exact <- topTags(treat.exact, n=nrow(treat.exact$table), adjust.method="fdr")$table

# MD plot of DGE
plotMD(treat.exact)
abline(h=c((-1*cutLFC), cutLFC), col="blue")

# filter by FDR and LFC cut off
DGESubset_exact <- resultsTbl_exact[(resultsTbl_exact$logFC > cutLFC & resultsTbl_exact$FDR < cutFDR) | (resultsTbl_exact$logFC < (-1*cutLFC) & resultsTbl_exact$FDR < cutFDR),]

# subset the counts by the DE gene set
DGESubset_exact.keep <- rownames(logcpm) %in% rownames(DGESubset_exact)
logcountsSubset_exact <- logcpm[DGESubset_exact.keep, ]

# create heatmap of DE genes CPM
pheatmap(logcountsSubset_exact, scale="row", annotation_col = exp_factor, 
        main="Heatmap of DE Genes CPM (Exact Test)", show_rownames = FALSE, fontsize = 12,
        color = colorRampPalette(c(plotColors[5], "white", plotColors[6]))(100))

###
## GLM
###
# setup contrast
con.treat <- makeContrasts(treatment = treat.24h - cntrl.24h,
                              levels=design)

# testing explicit nested contrast
treat.anov <- glmTreat(fit, contrast=con.treat[,"treatment"], lfc=cutLFC)

# summary table
summary(decideTests(treat.anov))

# retrieve tables of DE genes
resultsTbl_anov <- topTags(treat.anov, n=nrow(treat.anov$table), adjust.method="fdr")$table

# MD plot of DGE
plotMD(treat.anov)
abline(h=c((-1*cutLFC), cutLFC), col="blue")

# filter by FDR and LFC cut off
DGESubset_anov <- resultsTbl_anov[(resultsTbl_anov$logFC > cutLFC & resultsTbl_anov$FDR < cutFDR) | (resultsTbl_anov$logFC < (-1*cutLFC) & resultsTbl_anov$FDR < cutFDR),]

# subset the counts by the DE gene set
DGESubset_anov.keep <- rownames(logcpm) %in% rownames(DGESubset_anov)
logcountsSubset_anov <- logcpm[DGESubset_anov.keep, ]

# create heatmap of DE genes CPM
pheatmap(logcountsSubset_anov, scale="row", annotation_col = exp_factor, 
         main="Heatmap of DE Genes CPM (GLM)", show_rownames = FALSE, fontsize = 12,
         color = colorRampPalette(c(plotColors[5], "white", plotColors[6]))(100))
