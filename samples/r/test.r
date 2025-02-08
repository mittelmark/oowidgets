#!/usr/bin/env Rscript
png=commandArgs(trailingOnly=TRUE)[1]
png(png,width=600,height=600,pointsize=14)
plot(1:20,pch=15,col=rainbow(20),cex=2)
dev.off()




