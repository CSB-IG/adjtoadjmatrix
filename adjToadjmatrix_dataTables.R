if(!require(data.table)){
  install.packages("data.table")
  library(data.table)
}

args = commandArgs(trailingOnly=TRUE)
if(length(args) < 1) {
  stop("You need to provide the path to the adj file.")
}
adj.file <- args[1]
out.file <- ifelse(is.na(args[2]), "adjmatrix.RData", args[2])

cat("Loading file\n")
aracne.inter <- fread(adj.file, stringsAsFactors = F, header = F, fill = T)
cindex <- c(1, seq(2, ncol(aracne.inter), by=2))
genes <- as.character(unlist(aracne.inter[1, ..cindex]))
cindex <- c(1, seq(3, ncol(aracne.inter), by=2))
aracne.inter.num <- aracne.inter[, ..cindex]

adj.to.adjmatrix = function(adj, genelist, no.cores = 6){
  n = length(genelist)
  indices = 1:(n-1)
  r = parallel::mclapply(X = indices, 
                         mc.cores = no.cores, 
                         FUN = function(i){
    cat("Row: ", i , "\n")
    v = c(rep(NA, i-1), c(1.0, as.numeric(adj[i, 1:(n -i)])))
  })
  cat("Parallel computations done\n")
  m <- plyr::ldply(r)
  r <- rbindlist(r)
  r[n,n] = 1
  rownames(r) = genelist
  colnames(r) = genelist
  return(r)
}

adjmatrix <- adj.to.adjmatrix(aracne.inter.num, genes, 6)
cat("Saving file\n")
fwrite(adjmatrix, file = out.file, row.names = F, col.names = T, sep = "\t")
