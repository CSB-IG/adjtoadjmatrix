args = commandArgs(trailingOnly=TRUE)
if(length(args) < 1) {
  stop("You need to provide the path to the adj file.")
}
adj.file <- args[1]
out.file <- ifelse(is.na(args[2]), "adjmatrix.RData", args[2])

cat("Loading file\n")
aracne.inter <- read.delim(adj.file, stringsAsFactors = F, header = F)
genes <- as.character(aracne.inter[1,  c(1, seq(2, ncol(aracne.inter), by=2))])
nueva.matriz <- matrix(nrow =length(genes), ncol = length(genes), dimnames = list(genes,genes) )
aracne.inter.num <- aracne.inter[,  seq(3, ncol(aracne.inter), by=2)]

adj.to.adjmatrix = function(adj, genelist, no.cores = 6){
  n = length(genelist)
  indices = 1:(n-1)
  r = parallel::mclapply(X = indices, 
                         mc.cores = no.cores, 
                         FUN = function(i){
    v = c(rep(NA, i-1), c(1.0, as.numeric(adj[i, 1:(n -i)])))
  })
  cat("Parallel computations done\n")
  r = plyr::ldply(r)
  r[n,n] = 1
  rownames(r) = genelist
  colnames(r) = genelist
  return(r)
}

adjmatrix <- adj.to.adjmatrix(aracne.inter.num, genes, 6)
cat("Saving file\n")
save(adjmatrix, file = out.file, compress = "xz")
