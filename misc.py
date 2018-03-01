def preprocess(data):
    """
    Drop irrelevant columns and combine categories to match the suggested demographics.

    Suggested Demographics
    ----------------------
    Party: Democratic, Independent, Republican
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
    
    #Seperate education levels into "bachelors" and "no bachelors"
    
    bachelors = ['university', 'postgraduate']
    no_bachelors = ['high_school', 'other', 'vocational_technical_college', 'middle_school']

    index.loc[index['Education'].isin(bachelors), 'Education'] = 'bachelors'
    index.loc[index['Education'].isin(no_bachelors), 'Education'] = 'no bachelors'
    
    #Combine political affiliations to compensate for respondents who claim to be independent but aren't
    
    republican = ['Strong Republican', 'Weak Republican', 'Lean Republican/Independent']
    democrat = ['Strong Democrat', 'Weak Democrat', 'Lean Democrat/Independent']
    
    index.loc[index['What is your political party affiliation?'].isin(republican), 
              'What is your political party affiliation?'] = 'Republican'
    index.loc[index['What is your political party affiliation?'].isin(democrat),
              'What is your political party affiliation?'] = 'Democrat'
    
    return index

def filter(data, party=None, gender=None, age=None, race=None, education=None):
    """
    Filter a survey dataframe based on demographics, ignoring columns that have been dropped.
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
    
def filter(data, party=None, gender=None, age=None, race=None, education=None):
    """
    Filter a survey dataframe based on demographics.

    Suggested Demographics
    ----------------------
    Party: Democratic, Independent, Republican
    Gender: Male, Female
    Age: 18-24, 25-34, 35-44, 45-54, >54
    Race: White, Black, Hispanic, Other Race
    Education: No Bachelor, Bachelors
    """
    results = data
    
    for index, col in enumerate(index1.columns):
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
    
    if party != None:
        results = results[results.iloc[:, party_col].str.find(party) > -1]
    if gender != None:
        results = results[results.iloc[:, gender_col].str.startswith(gender)]
    if age != None:
        results = results[results.iloc[:, age_col].str.startswith(age)]
    if race != None:
        results = results[results.iloc[:, race_col].str.startswith(race)]
    if education !=None:
        results = results[results.iloc[:, edu_col].str.contains(education)]
        
    return results
    