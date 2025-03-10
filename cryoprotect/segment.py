import pandas as pd

df = pd.read_csv("Dataset.csv")

# Assuming your DataFrame is named df and the class column is named 'class'
df_class1 = df[df['Class'] == 'NON-AFP']
df_class2 = df[df['Class'] == 'AFP']

randstate = 420

# Randomly sample 300 from each class
sampled_class1 = df_class1.sample(n=300, random_state=randstate)
sampled_class2 = df_class2.sample(n=300, random_state=randstate)

# Concatenate sampled data
sampled_df = pd.concat([sampled_class1, sampled_class2])

# Get the remaining data
remaining_df = df.drop(sampled_df.index)

# Save to files
sampled_df.to_csv("train.csv", index=False)
remaining_df.to_csv("external.csv", index=False)
