import pandas as pd

# Load dataset
df = pd.read_csv("../data/Loan_default.csv")

# Remove unnecessary identifier
df = df.drop(columns=["LoanID"])

# Separate features and target
X = df.drop(columns=["Default"])
# Convert loan date into datetime
X["Loan Date (DD/MM/YYYY)"] = pd.to_datetime(
    X["Loan Date (DD/MM/YYYY)"],
    errors="coerce"
)

# Extract year and month
X["Loan_Year"] = X["Loan Date (DD/MM/YYYY)"].dt.year
X["Loan_Month"] = X["Loan Date (DD/MM/YYYY)"].dt.month

# Drop original date column
X = X.drop(columns=["Loan Date (DD/MM/YYYY)"])

print("\nDate processing completed!")
print(X[["Loan_Year", "Loan_Month"]].head())
y = df["Default"]

# Display dataset information
print("Feature dataset shape:", X.shape)
print("Target dataset shape:", y.shape)

print("\nTarget distribution:")
print(y.value_counts())

print("\nTarget percentage:")
print(y.value_counts(normalize=True) * 100)

print("\nColumn data types:")
print(X.dtypes)

print("\nCategorical columns:")
print(X.select_dtypes(include=["object"]).columns.tolist())

print("\nNumerical columns:")
print(X.select_dtypes(include=["number"]).columns.tolist())

print("\nMissing values in each column:")
print(X.isnull().sum())

print("\nTotal missing values:", X.isnull().sum().sum())

print("\nUnique values in categorical columns:")

categorical_columns = X.select_dtypes(
    include=["object"]
).columns

for column in categorical_columns:
    print(f"\n{column}:")
    print(X[column].unique())

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.pipeline import Pipeline

# Identify numerical and categorical columns
categorical_columns = X.select_dtypes(include=["str", "object"]).columns.tolist()
numerical_columns = X.select_dtypes(include=["number"]).columns.tolist()

# Create preprocessing pipelines
numerical_pipeline = Pipeline([
    ("scaler", StandardScaler())
])

categorical_pipeline = Pipeline([
    ("encoder", OneHotEncoder(handle_unknown="ignore"))
])

# Combine preprocessing
preprocessor = ColumnTransformer([
    ("num", numerical_pipeline, numerical_columns),
    ("cat", categorical_pipeline, categorical_columns)
])

# Split dataset
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

# Fit preprocessing only on training data
X_train_processed = preprocessor.fit_transform(X_train)
X_test_processed = preprocessor.transform(X_test)

print("\nTrain-test split completed!")

print("Training features:", X_train_processed.shape)
print("Testing features:", X_test_processed.shape)

print("Training target:", y_train.shape)
print("Testing target:", y_test.shape)    


from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    classification_report
)

# Create Logistic Regression model
model = LogisticRegression(
    max_iter=1000,
    class_weight="balanced",
    random_state=42
)

# Train model
model.fit(X_train_processed, y_train)

# Make predictions
y_pred = model.predict(X_test_processed)
y_prob = model.predict_proba(X_test_processed)[:, 1]

# Evaluate model
print("\nLOGISTIC REGRESSION RESULTS")

print("Accuracy:", round(accuracy_score(y_test, y_pred), 4))
print("Precision:", round(precision_score(y_test, y_pred), 4))
print("Recall:", round(recall_score(y_test, y_pred), 4))
print("F1 Score:", round(f1_score(y_test, y_pred), 4))
print("ROC-AUC:", round(roc_auc_score(y_test, y_prob), 4))

print("\nClassification Report:")
print(classification_report(y_test, y_pred))

from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt

# Generate confusion matrix
cm = confusion_matrix(y_test, y_pred)

print("\nConfusion Matrix:")
print(cm)

# Visualise confusion matrix
display = ConfusionMatrixDisplay(
    confusion_matrix=cm,
    display_labels=["Non-Default", "Default"]
)

display.plot(cmap="Blues")
plt.title("Logistic Regression - Confusion Matrix")
plt.show()

from sklearn.ensemble import RandomForestClassifier

# Create Random Forest model
rf_model = RandomForestClassifier(
    n_estimators=100,
    max_depth=15,
    min_samples_split=10,
    class_weight="balanced",
    random_state=42,
    n_jobs=-1
)

# Train model
rf_model.fit(X_train_processed, y_train)

# Predictions
rf_pred = rf_model.predict(X_test_processed)
rf_prob = rf_model.predict_proba(X_test_processed)[:, 1]

# Evaluation
print("\nRANDOM FOREST RESULTS")

print("Accuracy:", round(accuracy_score(y_test, rf_pred), 4))
print("Precision:", round(precision_score(y_test, rf_pred), 4))
print("Recall:", round(recall_score(y_test, rf_pred), 4))
print("F1 Score:", round(f1_score(y_test, rf_pred), 4))
print("ROC-AUC:", round(roc_auc_score(y_test, rf_prob), 4))


# Extract feature names after preprocessing
feature_names = preprocessor.get_feature_names_out()

# Get feature importance
importance_df = pd.DataFrame({
    "Feature": feature_names,
    "Importance": rf_model.feature_importances_
})

# Sort by importance
importance_df = importance_df.sort_values(
    by="Importance",
    ascending=False
)

print("\nTOP 15 IMPORTANT FEATURES")
print(importance_df.head(15))

# Plot feature importance
plt.figure(figsize=(10, 7))

top_features = importance_df.head(15)

plt.barh(
    top_features["Feature"],
    top_features["Importance"]
)

plt.gca().invert_yaxis()
plt.title("Top 15 Features - Random Forest")
plt.xlabel("Feature Importance")
plt.ylabel("Features")
plt.tight_layout()
plt.show()


import joblib
import os

# Create models folder path
models_dir = "../models"
os.makedirs(models_dir, exist_ok=True)

# Save Logistic Regression
joblib.dump(
    model,
    os.path.join(models_dir, "logistic_regression.pkl")
)

# Save Random Forest
joblib.dump(
    rf_model,
    os.path.join(models_dir, "random_forest.pkl")
)

# Save preprocessing pipeline
joblib.dump(
    preprocessor,
    os.path.join(models_dir, "preprocessor.pkl")
)

print("\nModels and preprocessing pipeline saved successfully!")


from sklearn.metrics import precision_score, recall_score, f1_score

# Get default probabilities
logistic_probabilities = model.predict_proba(X_test_processed)[:, 1]

# Test different thresholds
thresholds = [0.3, 0.4, 0.5, 0.6]

print("\nLOGISTIC REGRESSION - THRESHOLD COMPARISON")

for threshold in thresholds:

    predictions = (
        logistic_probabilities >= threshold
    ).astype(int)

    precision = precision_score(y_test, predictions)
    recall = recall_score(y_test, predictions)
    f1 = f1_score(y_test, predictions)

    print(f"\nThreshold: {threshold}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall: {recall:.4f}")
    print(f"F1 Score: {f1:.4f}")

    threshold_results = []

for threshold in [0.3, 0.4, 0.5, 0.6]:

    predictions = (
        logistic_probabilities >= threshold
    ).astype(int)

    threshold_results.append({
        "Threshold": threshold,
        "Precision": precision_score(y_test, predictions),
        "Recall": recall_score(y_test, predictions),
        "F1_Score": f1_score(y_test, predictions)
    })

threshold_df = pd.DataFrame(threshold_results)

print("\nTHRESHOLD COMPARISON")
print(threshold_df.round(4).to_string(index=False))

threshold_df.to_csv(
    "../outputs/threshold_comparison.csv",
    index=False
)

# Generate final predictions using threshold 0.5

final_threshold = 0.5

final_probabilities = model.predict_proba(
    X_test_processed
)[:, 1]

final_predictions = (
    final_probabilities >= final_threshold
).astype(int)

# Create prediction results dataframe
prediction_results = pd.DataFrame({
    "Actual_Default": y_test.values,
    "Predicted_Default": final_predictions,
    "Default_Probability": final_probabilities
})

# Save predictions
prediction_results.to_csv(
    "../outputs/loan_default_predictions.csv",
    index=False
)

print("\nFinal predictions exported successfully!")
print(prediction_results.head())

# Compare both trained models

model_comparison = pd.DataFrame({
    "Model": ["Logistic Regression", "Random Forest"],
    "Accuracy": [
        accuracy_score(y_test, y_pred),
        accuracy_score(y_test, rf_pred)
    ],
    "Precision": [
        precision_score(y_test, y_pred),
        precision_score(y_test, rf_pred)
    ],
    "Recall": [
        recall_score(y_test, y_pred),
        recall_score(y_test, rf_pred)
    ],
    "F1_Score": [
        f1_score(y_test, y_pred),
        f1_score(y_test, rf_pred)
    ],
    "ROC_AUC": [
        roc_auc_score(y_test, y_prob),
        roc_auc_score(y_test, rf_prob)
    ]
})

model_comparison.to_csv(
    "../outputs/model_comparison.csv",
    index=False
)

print("\nMODEL COMPARISON REPORT SAVED!")
print(model_comparison.round(4))