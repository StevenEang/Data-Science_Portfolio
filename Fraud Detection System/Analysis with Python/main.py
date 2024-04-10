# Fraud Detection System Project

import pandas as pd

# Path to dataset
file_path = r"C:\Users\eangs\OneDrive\Documents\Github\Fraud Detection System\creditcard_2023.csv"
# Load the dataset
df = pd.read_csv(file_path)

# Display the first few rows
print(df.head())

# Get a concise summary of the DataFrame
print(df.info())

# Statistical summary of numerical features
print(df.describe())

# Check for missing values in each column
print(df.isnull().sum())

# Distribution of the target variable 'Class'
print(df['Class'].value_counts(normalize=True))

# Visualizing Distribution
import seaborn as sns
import matplotlib.pyplot as plt

sns.countplot(x='Class', data=df)
plt.title('Class Distribution (0: Non-Fraud, 1: Fraud)')
plt.show()

