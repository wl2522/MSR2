library(tidyverse)
library(rstan)
library(rstanarm)

rm(list = ls())

voting <- read.csv('data/RawData/Voting2018.csv')
extra_1 <- read.csv('data/RawData/Extra1.csv')
extra_2 <- read.csv('data/RawData/Extra2.csv')
house_history <- read.csv('ref/tobi/HouseHistory_Clean18.csv')
load('ref/tobi/projection_space_subnational_18-02.RData')

voting_df <- rbind(voting, extra_1[, c(1:14, 16:28, 44)], extra_2[, c(1:27, 43)])

## Preprocessing
# add month variable
voting_df$month <- substring(as.character(voting_df$Time.Finished), 6, 7)
table(voting_df$month)

# check whether unique
cat(length(unique(extra_1$ID)), length(unique(extra_2$ID)),
    length(unique(voting$ID)), nrow(voting_df),
    length(unique(voting$ID))) # 22665 != 35999

# check duplicated records
foo <- table(voting_df$ID)
foo[foo > 5]
voting_df[voting_df$ID == -2013478144, ]
voting_df[voting_df$ID == 2146598187, ] # duplicated records
voting_df[voting_df$ID == -2037742515, ] # opinion shift

# deal with duplicated records: same month save only late response
voting_df$Time.Finished <- as.POSIXct(as.character(voting_df$Time.Finished), format = "%Y-%m-%d %H:%M:%S")

voting_df <- voting_df %>% dplyr::group_by(ID, month) %>%
  dplyr::mutate(max_time = max(Time.Finished)) %>%
  dplyr::ungroup() %>%
  dplyr::filter(Time.Finished == max_time)

# check results
voting_df[voting_df$ID == -2013478144, "Time.Finished"]
voting_df[voting_df$ID == 2146598187, "Time.Finished"] # duplicated records
voting_df[voting_df$ID == -2037742515, "Time.Finished"] # opinion shift

# check empty
table(is.na(voting_df$Education))
table(is.na(voting_df$Marital.Status))
table(is.na(voting_df$Gender))
table(is.na(voting_df$Race))
table(is.na(voting_df$Age))
table(is.na(voting_df$Area))
table(voting_df$Who.will.you.vote.for.in.the.House.of.Representatives.in.2018.,
      voting_df$How.do.you.feel.about.the.job.Donald.Trump.is.doing.as.president.)
table(voting_df$Who.will.you.vote.for.in.the.House.of.Representatives.in.2018.,
      voting_df$How.do.you.feel.about.the.job.Donald.Trump.is.doing.as.president.,
      voting_df$What.is.your.political.party.affiliation.)

# check for california
foo <- table(voting_df[voting_df$Area=="California", "City"])
foo[foo > 0]

table(voting_df[voting_df$City=="San Diego", "Who.will.you.vote.for.in.the.House.of.Representatives.in.2018."])

# Now performing usual preprocessing
# voting_df <- voting_df %>% filter(
#   Area != "Unknown",
#   Age != "14 - 17",
#   Education != "",
#   Race != "prefer_not_to_say" & Race != ""
# ) %>% mutate(
#   gender = as.character(dplyr::recode(Gender,
#                                       "male"="male",
#                                       "female"="female")),
#   age = as.character(dplyr::recode(Age,
#                                    "18 - 24"="18 - 24",
#                                    "25 - 34"="25 - 34",
#                                    "35 - 44"="35 - 44",
#                                    "45 - 54"="45 - 54",
#                                    "> 54"="> 54")),
#   race = as.character(dplyr::recode(Race,
#                                     "arab"="other",
#                                     "asian"="other",
#                                     "multiracial"="other",
#                                     "other"="other",
#                                     "latino"="hispanic",
#                                     "hispanic"="hispanic",
#                                     "black"="black",
#                                     "white"="white")),
#   edu = as.character(dplyr::recode(Education,
#                                    "university"="bachelors",
#                                    "postgraduate"="bachelors",
#                                    "high_school"="no bachelors",
#                                    "middle_school"="no bachelors",
#                                    "vocational_technical_college"="no bachelors")),
#   marstat = as.character(dplyr::recode(Marital.Status,
#                                        "living_with_partner"="married",
#                                        "married"="married",
#                                        "divorced"="unmarried",
#                                        "separated"="unmarried",
#                                        "widowed"="unmarried",
#                                        "single"="unmarried")),
#   state = as.character(Area),
#   zip = as.character(Postal.Code),
#   party = as.character(dplyr::recode(What.is.your.political.party.affiliation.,
#                                      "Lean Democrat/Independent"="democratic",
#                                      "Weak Democrat"="democratic",
#                                      "Strong Democrat"="democratic",
#                                      "Lean Republican/Independent"="republican",
#                                      "Weak Republican"="republican",
#                                      "Strong Republican"="republican")),
#   opinion = as.character(dplyr::recode(How.do.you.feel.about.the.job.Donald.Trump.is.doing.as.president.,
#                                        "Approve Strongly"="approve",
#                                        "Approve Weakly"="approve",
#                                        "Disapprove Strongly"="disapprove",
#                                        "Disapprove Weakly"="disapprove",
#                                        "Neither Approve nor Disapprove"="indifferent")),
#   vote = as.character(dplyr::recode(Who.will.you.vote.for.in.the.House.of.Representatives.in.2018.,
#                                     "Will vote Democratic"="democratic",
#                                     "Will vote Republican"="republican",
#                                     "Will vote other/not sure"="other/not sure",
#                                     "Won't vote"="won't vote",
#                                     "Won't Vote"="won't vote"))
# ) %>% select(
#   gender, age, race, edu, marstat, state, zip, party, opinion, vote
# )


plot_polling <- voting_df %>% filter(
  Area != "Unknown",
  Age != "14 - 17",
  Education != "",
  Race != "prefer_not_to_say" & Race != "",
  Marital.Status != "" & Marital.Status != "prefer_not_to_say",
  !is.na(Postal.Code),
  Income != ""
) %>% mutate(
  gender = dplyr::recode_factor(factor(Gender),
                                "male"="Male",
                                "female"="Female",
                                .default = NA_character_),
  age = dplyr::recode_factor(factor(Age),
                             "18 - 24"="18 - 24",
                             "25 - 34"="25 - 34",
                             "35 - 44"="35 - 44",
                             "45 - 54"="45 - 54",
                             "> 54"="> 54",
                             .default = NA_character_),
  race = dplyr::recode_factor(factor(Race),
                              "white"="White",
                              "black"="Black",
                              "hispanic"="Hispanic",
                              "latino"="Hispanic",
                              "arab"="Other",
                              "asian"="Other",
                              "multiracial"="Other",
                              "other"="Other",
                              .default = NA_character_),
  edu = dplyr::recode_factor(factor(Education),
                             "middle_school"="Lower than Middle School",
                             "high_school"="High School",
                             "vocational_technical_college"="Some College",
                             "university"="Bachelors",
                             "postgraduate"="Postgraduate",
                             .default = NA_character_),
  marstat = dplyr::recode_factor(factor(Marital.Status),
                                 "married"="Married",
                                 "living_with_partner"="Married",
                                 "divorced"="Unmarried",
                                 "separated"="Unmarried",
                                 "widowed"="Unmarried",
                                 "single"="Unmarried",
                                 .default = NA_character_),
  income = dplyr::recode_factor(factor(Income),
                                "lower_i"="<50k",
                                "lower_ii"="<50k",
                                "middle_i"="50k-100k",
                                "middle_ii"="50k-100k",
                                "high_i"=">100k",
                                "high_ii"=">100k",
                                "high_iii"=">100k",
                                "prefer_not_to_say"="Refused",
                                .default = NA_character_),
  state = as.character(Area)
) %>% select(
  gender, age, race, edu, marstat, income, state
)
saveRDS(plot_polling, file='data/plot_polling.RDS')

voting_mrp <- voting_df %>% filter(
  Area != "Unknown",
  Age != "14 - 17",
  Education != "",
  Race != "prefer_not_to_say" & Race != "",
  Marital.Status != "" & Marital.Status != "prefer_not_to_say",
  !is.na(Postal.Code)
) %>% mutate(
  gender = dplyr::recode_factor(factor(Gender),
                                "male"="male",
                                "female"="female",
                                .default = NA_character_),
  female = as.numeric(gender) - 1.5,
  age = dplyr::recode_factor(factor(Age),
                             "18 - 24"="18 - 24",
                             "25 - 34"="25 - 34",
                             "35 - 44"="35 - 44",
                             "45 - 54"="45 - 54",
                             "> 54"="> 54",
                             .default = NA_character_),
  race = dplyr::recode_factor(factor(Race),
                              "white"="white",
                              "black"="black",
                              "hispanic"="hispanic",
                              "latino"="hispanic",
                              "arab"="other",
                              "asian"="other",
                              "multiracial"="other",
                              "other"="other",
                              .default = NA_character_),
  edu = dplyr::recode_factor(factor(Education),
                             "university"="bachelors",
                             "postgraduate"="bachelors",
                             "high_school"="no bachelors",
                             "middle_school"="no bachelors",
                             "vocational_technical_college"="no bachelors",
                             .default = NA_character_),
  marstat = dplyr::recode_factor(factor(Marital.Status),
                                 "married"="married",
                                 "living_with_partner"="married",
                                 "divorced"="unmarried",
                                 "separated"="unmarried",
                                 "widowed"="unmarried",
                                 "single"="unmarried",
                                 .default = NA_character_),
  state = as.character(Area),
  zip = as.character(Postal.Code),
  # party = as.character(dplyr::recode_factor(What.is.your.political.party.affiliation.,
  #                                    "Lean Democrat/Independent"="democratic",
  #                                    "Weak Democrat"="democratic",
  #                                    "Strong Democrat"="democratic",
  #                                    "Lean Republican/Independent"="republican",
  #                                    "Weak Republican"="republican",
  #                                    "Strong Republican"="republican",
  #                                    "Independent"="independent")),
  opinion = as.character(dplyr::recode_factor(How.do.you.feel.about.the.job.Donald.Trump.is.doing.as.president.,
                                       "Approve Strongly"="approve",
                                       "Approve Weakly"="approve",
                                       "Disapprove Strongly"="disapprove",
                                       "Disapprove Weakly"="disapprove",
                                       "Neither Approve nor Disapprove"="indifferent")),
  vote = as.character(dplyr::recode_factor(Who.will.you.vote.for.in.the.House.of.Representatives.in.2018.,
                                    "Will vote Democratic"="democratic",
                                    "Will vote Republican"="republican",
                                    "Will vote other/not sure"="other/not sure",
                                    "Won't vote"="won't vote",
                                    "Won't Vote"="won't vote")),
  month = as.numeric(dplyr::recode_factor(month,
                                          "10"="1",
                                          "11"="2",
                                          "01"="3",
                                          "02"="4",
                                          "03"="5")) / 2. - 1.5,
  month_2 = month ^ 2
) %>% select(
  month, month_2, gender, female, age, race, edu, marstat, state, opinion
)

voting_mrp <- voting_mrp %>% dplyr::group_by(month, month_2, gender, female, age, race, edu, marstat, state) %>%
  dplyr::summarise(n(), sum(opinion=="approve"), sum(opinion=="disapprove"))
colnames(voting_mrp)[10] <- "N"
colnames(voting_mrp)[11] <- "Approve"
colnames(voting_mrp)[12] <- "Disapprove"

saveRDS(voting_mrp, file='data/voting_mrp.RDS')


district <- read.csv("data/zccd_hud.csv")
district$zip <- as.character(district$zip)
voting_df <- na.omit(voting_df)
voting_df <- voting_df %>% left_join(district, by="zip")

voting_two_party <- voting_df[voting_df$vote %in% c("democratic", "republican"), ]

# poststratification space
pops$congressional_district <- as.numeric(pops$congressional_district)
pops[pops$state == "DC", "congressional_district"] <- 1
colnames(pops) <- c("age", "urbanicity", "gender", "state", "race", "edu", "marstat", "district",
                    "party", "vote", "authoritarianism", "N_")
pops_group <- pops %>% mutate(
  gender = dplyr::recode_factor(gender,
                                "Male"="male",
                                "Female"="female",
                                .default = NA_character_),
  age = dplyr::recode_factor(age,
                             "18 - 24"="18 - 24",
                             "25 - 34"="25 - 34",
                             "35 - 44"="35 - 44",
                             "45 - 54"="45 - 54",
                             "> 54"="> 54",
                             .default = NA_character_),
  race = dplyr::recode_factor(race,
                              "White"="white",
                              "Black"="black",
                              "Hispanic"="hispanic",
                              "Other"="other",
                              .default = NA_character_),
  edu = dplyr::recode_factor(edu,
                             "College"="bachelors",
                             "No college"="no bachelors",
                             .default = NA_character_),
  marstat = dplyr::recode_factor(marstat,
                                 "Married"="married",
                                 "Unmarried"="unmarried",
                                 .default = NA_character_),
  state = as.character(state),
  party = as.character(dplyr::recode_factor(party,
                                            "Dem"="democratic",
                                            "Rep"="republican",
                                            "Ind"="independent")),
  vote = as.character(dplyr::recode_factor(vote,
                                           "Democratic candidate"="democratic",
                                           "Republican candidate"="republican",
                                           "Other candidate/not sure"="other/not sure"))
) %>% 
  group_by(age, gender, state, race, marstat, edu, party, vote, district) %>%
  summarize(N = sum(N_))
