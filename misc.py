import pandas as pd

def preprocess(data):
    """
    Drop irrelevant columns and combine categories to match the suggested demographics.

    Suggested Demographics
    ----------------------
    Party: Democrat, Independent, Republican
    Gender: Male, Female
    Age: 18-24, 25-34, 35-44, 45-54, >54
    Race: White, Black, Hispanic, Other Race
    Education: No Bachelor, Bachelors
    """
    
    index = data.copy()
    index.drop(['Country'], axis=1, inplace=True)
    
    #Remove rows where the respondent is in the 14-17 age range
    
    index = index[index.loc[:, 'Age'] != '14 - 17']
    
    #Combine the hispanic and latino categories
    
    index['Race'] = index['Race'].str.replace('latino', 'hispanic')
    
    #Combine other races into the "other" category
        
    races = ['white', 'black', 'hispanic', 'other']
    index.loc[~index['Race'].isin(races), 'Race'] = 'other'
    
    #Seperate education levels into "College" and "No college"
    
    bachelors = ['university', 'postgraduate']
    no_bachelors = ['high_school', 'other', 'vocational_technical_college', 'middle_school']

    index.loc[index['Education'].isin(bachelors), 'Education'] = 'College'
    index.loc[index['Education'].isin(no_bachelors), 'Education'] = 'No college'
    
    #Combine political affiliations to compensate for respondents who claim to be independent but aren't
    
    republican = ['Strong Republican', 'Weak Republican', 'Lean Republican/Independent']
    democrat = ['Strong Democrat', 'Weak Democrat', 'Lean Democrat/Independent']
    
    index.loc[index['What is your political party affiliation?'].isin(republican), 
              'What is your political party affiliation?'] = 'Republican'
    index.loc[index['What is your political party affiliation?'].isin(democrat),
              'What is your political party affiliation?'] = 'Democrat'
    
    #Impute "Unknown" for missing US Census Division values
    
    index.loc[index['US Census Division'].isnull(), 'US Census Division'] = 'Unknown'
    
    #Combine respondents who won't vote for a major party in 2018 with those who won't vote at all
    
    index.loc[index['Who will you vote for in the House of Representatives in 2018?'] == 'Will vote other/not sure',
              'Who will you vote for in the House of Representatives in 2018?'] = "Won't Vote Major Party"
    index.loc[index['Who will you vote for in the House of Representatives in 2018?'] == "Won't Vote",
              'Who will you vote for in the House of Representatives in 2018?'] = "Won't Vote Major Party"
    
    #Impute missing congressional districts for respondents living in states with only one district
    
    at_large = ['Alaska', 'Delaware', 'Montana', 'North Dakota', 'South Dakota', 'Vermont', 'Wyoming', 'District of Columbia']
    index.loc[index['Area'].isin(at_large) & pd.isnull(index['Postal Code']), 'US Congressional District'] = 1
    
    #Concatenate the Area and US Congressional District columns to get the full district name
    
    index['US Congressional District'] = index['US Congressional District'].astype(str)
    index['US Congressional District'] = index.apply(lambda row: row['Area'] + '-' + row['US Congressional District'].replace('.0', '')
                                                     if pd.notnull(row['US Congressional District']) else 'Unknown', axis=1)
    
    #Remove '-nan' from rows with missing congressional districts
    
    index['US Congressional District'] = index['US Congressional District'].str.replace('-nan', '')
    
    return index


def filter_df(data, party=None, gender=None, age=None, race=None, education=None):
    """
    Filter a survey dataframe based on demographics, ignoring columns that have been dropped.

    Suggested Demographics
    ----------------------
    Party: Democrat, Independent, Republican
    Gender: Male, Female
    Age: 18-24, 25-34, 35-44, 45-54, >54
    Race: White, Black, Hispanic, Other Race
    Education: No Bachelor, Bachelors
    """
    results = data
    
    for index, col in enumerate(data.columns):
        if col == 'What is your political party affiliation?':
            party_col = index
        elif col == 'Gender':
            gender_col = index
        elif col == 'Age':
            age_col = index
        elif col == 'Race':
            race_col = index
        elif col == 'Education':
            edu_col = index
    
    if party != None and 'What is your political party affiliation?' in data.columns:
        results = results[results.iloc[:, party_col].str.find(party) > -1]
        
    if gender != None and 'Gender' in data.columns:
        results = results[results.iloc[:, gender_col].str.startswith(gender)]
        
    if age != None and 'Age' in data.columns:
        results = results[results.iloc[:, age_col].str.startswith(age)]
        
    if race != None and 'Race' in data.columns:
        results = results[results.iloc[:, race_col].str.startswith(race)]
        
    if education !=None and 'Education' in data.columns:
        results = results[results.iloc[:, edu_col].str.contains(education)]
        
    return results
