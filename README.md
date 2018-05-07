# Predicting the 2018 United States House of Representatives Elections and Voting Patterns with Polling Data


This repository contains the relevant model and visualization code for Team MSR2's Columbia University Spring 2018 Data Science Capstone Project with industry partner Microsoft Research.

## Abstract

Nationwide surveys are widely adopted for gathering household information, evaluating public policies, and predicting elections. However, no unofficial survey can achieve census-level coverage. With survey data gathered by PredictWise using Pollfish, a mobile survey platform, we use a multilevel regression and poststratification (MRP) model to predict the two-party vote shares for each of the 435 congressional districts and the District of Columbia in the forthcoming 2018 United States House of Representatives Elections. We use these predictions to investigate the changes in voter turnout in specific demographics that would be needed to change the balance of power in the House of Representatives. In addition to widely-used demographic and geographic information, we incorporate responses to psychometric survey questions using three weighting schemes to evaluate their effects on the model. We identify several question topics that improve in our model’s predictive accuracy and find evidence that adding multiple topics simultaneously produces approximately linear improvements in accuracy.

### [Interactive Map (2018 Midterm Election predictions and alternate election outcomes)](https://bl.ocks.org/carolynamorris/raw/18e6fbf579cb9c539c5c5b15a7b17de5/)

## Contents

* [baseline](https://github.com/wl2522/MSR2/tree/master/baseline): Python code for our baseline prediction model and our predicted outcomes for the 2018 Midterm Elections
* [demographics](https://github.com/wl2522/MSR2/tree/master/demographics): supplementary data that was used to augment our model or impute missing data
* [dynamic](https://github.com/wl2522/MSR2/tree/master/dynamic): an experimental dynamic model of Trump's approval rate
* [plots](https://github.com/wl2522/MSR2/tree/master/plots): exploratory data analysis [code](https://github.com/wl2522/MSR2/blob/master/graphs.R)
* [psychometric](https://github.com/wl2522/MSR2/tree/master/psychometric): a collection of models that incorporate various psychometric variables along with the models without psychometric variables that were used as a baseline comparison
* [authoritarianism](https://github.com/wl2522/MSR2/tree/master/psychometric/authoritarianism): Python code for our prediction model that includes identification with authoritarianism as an additional variable and updated predictions for the 2018 Midterm Elections produced by this model
* [report_map](https://github.com/wl2522/MSR2/tree/master/report_map): the HTML, CSS, and JavaScript (D3.js) code used for the interactive map of our predictions
* [turnout_adjustment](https://github.com/wl2522/MSR2/tree/master/turnout_adjustment): Python code that modifies the poststratification space by adjusting voter turnout for specific demographic groups along with updated predictions produced by those adjustments