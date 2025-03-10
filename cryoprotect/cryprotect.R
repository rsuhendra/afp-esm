library(seqinr)
library(protr)
library(randomForest)
library(rstudioapi)     
library(Matrix)
library(data.table)
library(Biostrings)

setwd(dirname(getActiveDocumentContext()$path)) 

# Model Building
training <- read.csv("train.csv", header = TRUE)

# Apply the protcheck and extraction functions across all rows
AAC <- t(sapply(training$Sequence, function(seq) {
  seq <- seq[(sapply(seq, protcheck))]
  extractAAC(seq)
}))

DPC <- t(sapply(training$Sequence, function(seq) {
  seq <- seq[(sapply(seq, protcheck))]
  extractDC(seq)
}))

# Convert AAC and DPC to data frames
AAC_df <- data.frame(AAC)
DPC_df <- data.frame(DPC)

# Combine the original training data with the new features
training_combined <- cbind(training, AAC_df, DPC_df)

# Drop the 'Protein_ID' and 'Sequence' columns
training_combined <- training_combined[, !(colnames(training_combined) %in% c("Protein_ID", "Sequence"))]
# Remove row names (index)
rownames(training_combined) <- NULL
# Turn Class to Factor
training_combined$Class <- as.factor(training_combined$Class)

# Now `training_combined` contains the original training data with the added AAC and DPC features
print(training_combined)

write.csv(training_combined, "training_extracted.csv", row.names = FALSE)

# Model Building
training <- read.csv("training_extracted.csv", header = TRUE, stringsAsFactors = TRUE )

fit <- randomForest(Class ~ ., data = training, ntree= 100, importance=TRUE,
                    proximity=TRUE)
