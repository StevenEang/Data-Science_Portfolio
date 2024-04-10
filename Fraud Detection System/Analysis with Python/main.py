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

#### Data Visualization ####
import matplotlib.pyplot as plt
import seaborn as sns

# Setting the visual style of seaborn
sns.set_style('whitegrid')

# Plotting the distribution of transaction amounts
plt.figure(figsize=(10, 6))
sns.histplot(df[df['Class'] == 0]['Amount'], bins=100, color='green', alpha=0.7, label='Non-Fraud')
sns.histplot(df[df['Class'] == 1]['Amount'], bins=100, color='red', alpha=0.7, label='Fraud')
plt.legend()
plt.xlabel('Amount ($)')
plt.ylabel('Number of Transactions')
plt.title('Transaction Amount Distribution')
plt.xlim((0, 20000))  # Limiting x-axis for better visibility
plt.show()

# Plotting the distribution of classes
plt.figure(figsize=(6, 4))
sns.countplot(x='Class', data=df)
plt.title('Class Distribution (0: Non-Fraud, 1: Fraud)')
plt.show()

# Check for any missing values
df = df.dropna() 

# Feature Scaling
from sklearn.preprocessing import StandardScaler

# Assuming 'Amount' or similar needs scaling
scaler = StandardScaler()
df['Scaled_Amount'] = scaler.fit_transform(df[['Amount']])
df.drop(['Amount'], axis=1, inplace=True)  # Removing the original 'Amount' column

# Checking for imbalance
from imblearn.over_sampling import SMOTE

smote = SMOTE(random_state=42)
X_res, y_res = smote.fit_resample(df.drop('Class', axis=1), df['Class'])

# Splitting Dataset
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X_res, y_res, test_size=0.2, random_state=42)

from sklearn.ensemble import RandomForestClassifier

# Initialize the model
model = RandomForestClassifier(random_state=42)

# Train the model
model.fit(X_train, y_train)

### Model Evaluation ###
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# Predictions
predictions = model.predict(X_test)

# Evaluation
print("Confusion Matrix:")
print(confusion_matrix(y_test, predictions))
print("\nClassification Report:")
print(classification_report(y_test, predictions))
print("ROC AUC Score:", roc_auc_score(y_test, predictions))

### Preparing for Deployment ###
from joblib import dump, load

# To save the model to a file
dump(model, 'model_filename.joblib')

# To load the model from the file
loaded_model = load('model_filename.joblib')

# Feature Analysis
feature_importances = pd.DataFrame(model.feature_importances_,
                                   index = X_train.columns,
                                   columns=['importance']).sort_values('importance', ascending=False)
print(feature_importances)

# Advanced Model Interpretability using SHAP 
import shap
import numpy as np

# Generate SHAP values
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)

# This time, let's ensure we're understanding the structure correctly
if isinstance(shap_values, list):
    # Expected for multi-class outputs
    print(f"List of arrays, one for each class. Number of classes: {len(shap_values)}")
    print(f"Shape of SHAP values for class 0: {np.array(shap_values[0]).shape}")
    print(f"Shape of SHAP values for class 1: {np.array(shap_values[1]).shape}")
else:
    # Expected for binary output in some SHAP versions
    print(f"Array shape (for binary classification): {np.array(shap_values).shape}")

# For binary classification, it's common to focus on one set of SHAP values, usually for the positive class
# Adjust the indexing if necessary based on your understanding of the SHAP values' structure
shap.summary_plot(shap_values[:, :, 1], X_test)  # Assuming the second index in the last dimension corresponds to the positive class

# Select a single prediction to visualize
instance_index = 0  # Example index, choose based on your interest
shap.force_plot(explainer.expected_value[1], shap_values[instance_index, :, 1], X_test.iloc[instance_index, :])

# Adjust the extraction of SHAP values for the positive class
shap_values_class1 = shap_values[:, :, 1]  # Assuming the last dimension represents classes

# Now try the dependence plot again, using the adjusted SHAP values
shap.dependence_plot("V14", shap_values_class1, X_test, interaction_index="V14")

# Feature Analysis
feature_importances = pd.DataFrame(model.feature_importances_,
                                   index = X_train.columns,
                                   columns=['importance']).sort_values('importance', ascending=False)
print(feature_importances)
# Features V14, V10, V4, V12 and V17 appear to be significant in determining the model's predictons.
# Now refining model by removing the low importance features

# Model Hyperparameter Tuning
from sklearn.model_selection import GridSearchCV

# RandomForestClassifier
param_grid = {
    'n_estimators': [100, 200, 500],
    'max_depth': [10, 20, 30],
    'min_samples_split': [2, 5, 10]
}
grid_search = GridSearchCV(RandomForestClassifier(random_state=42), param_grid, cv=5, scoring='roc_auc')
grid_search.fit(X_train, y_train)
print("Best parameters:", grid_search.best_params_)

# Cross-Validation
from sklearn.model_selection import cross_val_score

# Example for RandomForestClassifier with the best parameters
scores = cross_val_score(grid_search.best_estimator_, X_train, y_train, cv=5, scoring='roc_auc')
print("Average cross-validation score: ", scores.mean())

# Test set
test_score = grid_search.best_estimator_.score(X_test, y_test)
print(f"Test set score: {test_score}")
