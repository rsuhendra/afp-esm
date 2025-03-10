library(seqinr)
library(protr)
library(randomForest)
library(rstudioapi)     
library(Matrix)
library(data.table)
library(Biostrings)

setwd(dirname(getActiveDocumentContext()$path)) 

# Model Building
training <- read.csv("training_extracted.csv", header = TRUE, stringsAsFactors = TRUE )

fit <- randomForest(Class ~ ., data = training, ntree= 100, importance=TRUE,
                    proximity=TRUE)


# Model Building
external <- read.csv("external.csv", header = TRUE)

for (i in 1:length(external$Sequence)) {
  seq <- external$Sequence[i]
  # Use tryCatch to handle potential errors
  result <- tryCatch({
    # Apply protcheck to the sequence
    seq <- seq[(sapply(seq, protcheck))]
    extractAAC(seq)
    # extractAAC(seq)
    # If successful, do nothing (or store the result if needed)
  }, error = function(e) {
    # Print the sequence and error message if an error occurs
    print(paste("Error with sequence at index", i, ":"))
    print(seq)
    print(paste("Error message:", e$message))
  })
}

sequence_lengths <- nchar(external$Sequence)
hist(sequence_lengths, main="Distribution of Sequence Lengths", xlab="Sequence Length", col="lightblue", border="black", breaks=30)



# Apply the protcheck and extraction functions across all rows
AAC <- t(sapply(external$Sequence, function(seq) {
  seq <- seq[(sapply(seq, protcheck))]
  extractAAC(seq)
}))

DPC <- t(sapply(external$Sequence, function(seq) {
  seq <- seq[(sapply(seq, protcheck))]
  extractDC(seq)
}))

# Convert AAC and DPC to data frames
AAC_df <- data.frame(AAC)
DPC_df <- data.frame(DPC)

# Combine the original external data with the new features
external <- cbind(external, AAC_df, DPC_df)

# Drop the 'Protein_ID' and 'Sequence' columns
external <- external[, !(colnames(external) %in% c("Protein_ID", "Sequence"))]
# Remove row names (index)
rownames(external) <- NULL
# Turn Class to Factor
external$Class <- as.factor(external$Class)

# Now `training_combined` contains the original training data with the added AAC and DPC features
print(training_combined)

write.csv(training_combined, "training_extracted.csv", row.names = FALSE)
