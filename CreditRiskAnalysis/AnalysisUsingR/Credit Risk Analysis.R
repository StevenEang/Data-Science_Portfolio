# Credit Risk Analysis project

rm(list=ls())

library(dplyr)
library(ggplot2)
library(DBI)
library(RMySQL)
library(odbc)

# Connecting to the SQL Database
con <- dbConnect(odbc::odbc(), 
                 Driver = "SQL Server", 
                 Server = "PECUNIA", 
                 Database = "CreditRiskAnalysis", 
                 Trusted_Connection = "True")

# Import data
loans_data <- dbReadTable(con, "Credit Risk")

# Viewing the structure of the data
str(loans_data)

# Summary statistics
summary(loans_data)

print(loans_data$int_rate)

# Handling missing values, duplicates, etc.
loans_data <- loans_data %>%
  filter(!is.na(annual_inc)) %>%
  distinct(id, .keep_all = TRUE)

# Replacing missing values in the 'dti' column with the median
median_dti <- median(loans_data$dti, na.rm = TRUE)
loans_data$dti <- ifelse(is.na(loans_data$dti), median_dti, loans_data$dti)

# Detecting outliers and handling them
boxplot_stats <- boxplot.stats(loans_data$annual_inc)$out
loans_data <- loans_data %>% filter(!annual_inc %in% boxplot_stats)

loans_data <- loans_data %>%
  mutate(debt_to_income_ratio = dti,
         loan_to_income_ratio = loan_amnt / annual_inc)

# Risk Stratification (categorizing loans based on criteria)
loans_data <- loans_data %>%
  mutate(risk_category = case_when(
    dti <= 10 ~ "Low",
    dti > 10 & dti <= 20 ~ "Medium",
    TRUE ~ "High"
  ))

# Statistical Analysis
# Correlation Analysis
cor(loans_data$loan_amnt, loans_data$annual_inc)

# Regression Analysis
model <- glm(default_ind ~ loan_amnt + annual_inc + int_rate, data = loans_data, family = "binomial")
summary(model)

# Simple linear regression of loan amount on annual income
lm_model <- lm(loan_amnt ~ annual_inc, data = loans_data)
summary(lm_model)

# Logistic Regression Diagnostics
# Plotting residuals
plot(residuals(model, type = "deviance"))

# Hosmer-Lemeshow Test
library(ResourceSelection)
hoslem.test(loans_data$default_ind, fitted(model))

# Decision Trees or Random Forests
library(randomForest)
rf_model <- randomForest(default_ind ~ loan_amnt + annual_inc + int_rate + dti, data=loans_data, ntree=100)
print(rf_model)

# Cross-validations for logistic regression and random forest models
library(caret)
control <- trainControl(method="cv", number=10)
glm_cv <- train(default_ind ~ loan_amnt + annual_inc + int_rate, data=loans_data, method="glm", trControl=control, family="binomial")
print(glm_cv)

importance(rf_model)
varImpPlot(rf_model)

# Data Visualization
# Loan Amount vs. Annual Income 
ggplot(loans_data, aes(x = loan_amnt, y = annual_inc)) +
  geom_point(aes(color = default_ind)) +
  labs(title = "Loan Amount vs. Annual Income", x = "Loan Amount", y = "Annual Income")

# Faceted Plots for Loan Amount vs Annual Income by Risk Category
ggplot(loans_data, aes(x = loan_amnt, y = annual_inc)) +
  geom_point(aes(color = default_ind)) +
  facet_wrap(~risk_category) +
  labs(title = "Loan Amount vs. Annual Income by Risk Category",
       x = "Loan Amount", y = "Annual Income")

# Distribution of Loans by Risk Category and Default Status
ggplot(loans_data, aes(x = risk_category, fill = default_ind)) +
  geom_bar(position = "fill") +
  labs(title = "Distribution of Loans by Risk Category and Default Status",
       x = "Risk Category", y = "Proportion")

# Predictor Impact
partialPlot(rf_model, loans_data, "annual_inc")

# Convert a ggplot to an interactive plot
library(plotly)
ggplotly(
  ggplot(loans_data, aes(x = loan_amnt, y = annual_inc, color = default_ind)) +
    geom_point()
)

# Pairwise Relationships
library(GGally)
ggpairs(loans_data[, c("loan_amnt", "annual_inc", "dti", "default_ind")])

# Create your base ggplot object
p <- ggplot(loans_data, aes(x = loan_amnt, y = annual_inc)) +
  geom_point(aes(color = default_ind))

# Add the marginal histogram using ggMarginal from the ggExtra package
p <- ggExtra::ggMarginal(p, type = "histogram", margins = "both", fill = "blue")

print(p)

# Risk-Based Pricing Model
# Define interest rate tiers
loans_data$int_rate_tier <- cut(loans_data$int_rate,
                                breaks = c(0, 5, 10, 15, 20, 25, Inf),
                                labels = c("<5%", "5-10%", "10-15%", "15-20%", "20-25%", ">25%"),
                                right = FALSE)

# Calculate default rates by interest rate tier
default_rate_by_tier <- default_rate_by_tier %>%
  mutate(
    Multiplier = case_when(
      int_rate_tier == "5-10%" ~ 0.9,
      int_rate_tier == "10-15%" ~ 1.0,
      int_rate_tier == "15-20%" ~ 1.2,
      int_rate_tier == "20-25%" ~ 1.3,
      TRUE ~ 999  # Catch-all for debugging
    ),
    AdjustedRate = AvgIntRate * Multiplier
  )

print(default_rate_by_tier)

# Correlation matrix (loan amount, annual income, interest rate, dti)
library(corrplot)
numerical_data <- loans_data %>% select(loan_amnt, annual_inc, int_rate, dti) 
corr_matrix <- cor(na.omit(numerical_data))
corrplot(corr_matrix, method = "color")

# ROC Curve for Logistic Regression
install.packages("pROC")
library(pROC)
roc_curve <- roc(loans_data$default_ind, fitted(model))
plot(roc_curve)
auc(roc_curve)

# Cost-Benefit Analysis
###
# Sample costs and benefits
CFP <- 10000  # Cost of False Positive
CFN <- 2000   # Cost of False Negative
BTP <- 0      # Benefit of True Positive (cost avoided)
BTN <- 1000   # Benefit of True Negative (interest profit)

# Predicting defaults using your model (replace 'credit_model' with your actual model)
# This assumes that your model expects the same input variables as your current dataset
predicted_probabilities <- predict(model, loans_data, type = "response")
loans_data$predicted_default <- ifelse(predicted_probabilities > 0.5, 1, 0)  # Convert probabilities to binary predictions

# Now you can create the confusion matrix
conf_matrix <- table(Predicted = loans_data$predicted_default, Actual = loans_data$default_ind)

# Calculate total costs and benefits
total_cost <- (conf_matrix["1", "0"] * CFP) + (conf_matrix["0", "1"] * CFN)
total_benefit <- (conf_matrix["0", "0"] * BTN) + (conf_matrix["1", "1"] * BTP)

# Net benefit
net_benefit <- total_benefit - total_cost

print(net_benefit)
###
# Define costs and benefits
cost_false_positive <- 1000
cost_false_negative <- 5000

# Set up cross-validation
control <- trainControl(method="cv", number=10)

# Train the model
rf_cv <- train(default_ind ~ loan_amnt + annual_inc + int_rate + dti, 
               data = loans_data, 
               method = "rf", 
               trControl = control)


# Calculate costs based on confusion matrix
conf_matrix <- confusionMatrix(data = predict(rf_cv, loans_data, type = "raw"), reference = loans_data$default_ind)
cost <- conf_matrix$table[1,2] * cost_false_positive + conf_matrix$table[2,1] * cost_false_negative

print(conf_matrix)

# Close the connection
dbDisconnect(con)
