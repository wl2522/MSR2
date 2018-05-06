# Predicting the 2018 United States House of Representatives Elections and Voting Patterns with Polling Data

This repository contains all of the relevant model and visualization code used in group MSR2's Microsoft Research capstone project.

## Abstract

Nationwide surveys are widely-adopted for gathering household information, evaluating public policies, and predicting elections. However, no unofficial survey can achieve census-level coverage. With survey data gathered by PredictWise using Pollfish, a mobile survey platform, we use a multilevel regression and poststratification (MRP) model to predict the two-party vote shares for each of the  435 congressional districts and the District of Columbia in the forthcoming 2018 United States House of Representatives Elections. We use these predictions to investigate the changes in voter turnout in specific demographics that would be needed to change the balance of power in the House of Representatives. In addition to widely-used demographic and geographic information, we also incorporate responses to psychometric survey questions using different weighting schemes to evaluate their effects on the model. We identify several question topics that produce moderate improvements in our model’s predictive accuracy and find evidence that adding multiple topics simultaneously produces approximately linear improvements in accuracy.

## Contents

* [baseline](): the Python code for our baseline prediction model and our predicted outcomes for the 2018 Midterm Elections
* [demographics](): supplementary data that was used to either augment our model or impute missing data
* [psychometric](): a collection of models that incorporate various psychometric variables and models without pychometric variables that were used as a baseline comparison
* 