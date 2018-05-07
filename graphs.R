library(tidyverse)
library(gridExtra)

#############################################################
## Polling v.s. population -- Demographics and Geographics ##
#############################################################
plot_polling <- readRDS("data/plot_polling.RDS")

# age.poll <- plot_polling %>%
#   group_by(age) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='Age', Cat=as.numeric(age), Label=age) %>%
#   ungroup()
# gender.poll <- plot_polling %>%
#   group_by(gender) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='Gender', Cat=as.numeric(gender), Label=gender) %>%
#   ungroup()
# race.poll <- plot_polling %>%
#   group_by(race) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='Race', Cat=as.numeric(race), Label=race) %>%
#   ungroup()
# mar.poll <- plot_polling %>%
#   group_by(marstat) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='Marital Status', Cat=as.numeric(marstat), Label=marstat) %>%
#   ungroup()
# edu.poll <- plot_polling %>%
#   group_by(edu) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='Education', Cat=as.numeric(edu), Label=edu) %>%
#   ungroup()
# income.poll <- plot_polling %>%
#   group_by(income) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='Income', Cat=as.numeric(income), Label=income) %>%
#   ungroup()
# 
# poll_demographics <- rbind(age.poll[, 2:7], gender.poll[, 2:7], race.poll[, 2:7],
#                            mar.poll[, 2:7], edu.poll[, 2:7], income.poll[, 2:7])
# election_demographics <- read.csv("data/election_demographics.csv")
# plot_demographics <- rbind(poll_demographics, election_demographics)
# plot_demographics <- plot_demographics[plot_demographics$Label != "Refused", ]
# write.csv(plot_demographics, 'data/plot_demographics.csv')

plot_demographics <- read.csv('data/plot_demographics.csv')

ggplot(data=plot_demographics, aes(x=as.factor(paste(Cat, Label, sep='\n')),
                                   y=Prop, group=as.factor(Type), linetype=as.factor(Type))) +
  geom_point(stat="identity",colour='black') +
  geom_line() +
  facet_wrap(~Var, scales="free", nrow=1, ncol=6) +
  theme_bw() +
  scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  ylab('Proportion') +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

ggsave("plots/popu_vs_poll_demo.pdf", width=16, height=8)

# poll_state_dist <- plot_polling %>%
#   group_by(state) %>%
#   summarize(Num=n()) %>%
#   mutate(Prop=Num/sum(Num), Type='Poll', Var='State', Cat=state) %>%
#   ungroup()
# election_2016_results <- read.csv("data/2016election.csv", check.names=FALSE)
# election_2016_results$Abbr <- state.abb[match(election_2016_results$State, state.name)]
# election_2016_results$`Clinton (D)` <- as.numeric(gsub(",", "", election_2016_results$`Clinton (D)`))
# election_2016_results$`Trump (R)` <- as.numeric(gsub(",", "", election_2016_results$`Trump (R)`))
# election_2016_results$Others <- as.numeric(gsub(",", "", election_2016_results$Others))
# election_state_dist <- election_2016_results %>%
#   group_by(State) %>%
#   summarize(Num=as.numeric(gsub(",", "", `Clinton (D)`)) + as.numeric(gsub(",", "", `Trump (R)`))) %>%
#   mutate(Prop=Num/sum(Num), Type='Election', Var='State', Cat=State) %>%
#   ungroup()
# plot_state <- rbind(poll_state_dist[,2:6], election_state_dist[,2:6])
# write_csv(plot_state, 'data/plot_state.csv')

plot_state <- read.csv('data/plot_state.csv')
plot_state$Type <- factor(plot_state$Type, levels = c("Election", "Poll"))
ggplot(data=plot_state, aes(x=as.factor(Cat), y=Prop, group=as.factor(Type), linetype=as.factor(Type))) +
  geom_point(stat="identity", colour='black') +
  geom_line() +
  facet_wrap(~Var) +
  theme_bw() +
  scale_fill_manual(values=c('#1f78b4', '#33a02c', '#e31a1c', '#ff7f00', '#8856a7'), guide=FALSE) +
  scale_y_continuous(breaks=c(0, .01, .02, .03, .04, .05, .06, .07, .08, .09, .10, 1),
                     labels=c('0%', '1%', '2%', '3%', '4%', '5%', '6%', '7%', '8%', '9%', '10%', '100%'),
                     expand=c(0, 0), limits=c(0, .11)) +
  scale_alpha_manual(values=c(1, .3)) +
  ylab('Proportion') +
  labs(alpha='') +
  theme(legend.position="bottom",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        legend.title=element_blank(),
        legend.text=element_text(size=10),
        axis.text.y=element_text(size=10),
        axis.text.x=element_text(size=8, angle=90, hjust=0.95, vjust=0.2),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

ggsave("plots/popu_vs_poll_state.pdf", width=16, height=8)



#############################################################
## Polling v.s. prediction -- Demographics and Geographics ##
#############################################################

# age.pops <- pops %>%
#   group_by(age) %>%
#   summarize(Num=sum(N_)) %>%
#   mutate(Prop=Num/sum(Num), Type='2018 PS Space', Var='Age', Cat=as.numeric(age), Label=age) %>%
#   ungroup()
# gender.pops <- pops %>%
#   group_by(gender) %>%
#   summarize(Num=sum(N_)) %>%
#   mutate(Prop=Num/sum(Num), Type='2018 PS Space', Var='Gender', Cat=as.numeric(gender), Label=gender) %>%
#   ungroup()
# race.pops <- pops %>%
#   group_by(race) %>%
#   summarize(Num=sum(N_)) %>%
#   mutate(Prop=Num/sum(Num), Type='2018 PS Space', Var='Race', Cat=as.numeric(race), Label=race) %>%
#   ungroup()
# mar.pops <- pops %>%
#   mutate(marstat=dplyr::recode_factor(marstat,
#                                      "Married"="Married",
#                                      "Unmarried"="Unmarried",
#                                      .default = NA_character_)) %>%
#   group_by(marstat) %>%
#   summarize(Num=sum(N_)) %>%
#   mutate(Prop=Num/sum(Num), Type='2018 PS Space', Var='Marital Status', Cat=as.numeric(marstat),
#          Label=marstat) %>%
#   ungroup()
# edu.pops <- pops %>%
#   group_by(edu) %>%
#   summarize(Num=sum(N_)) %>%
#   mutate(Prop=Num/sum(Num), Type='2018 PS Space', Var='Education', Cat=as.numeric(edu),
#          Label=dplyr::recode_factor(edu,
#                                     "No college"="No Bachelors",
#                                     "College"="Bachelors",
#                                     .default = NA_character_)) %>%
#   ungroup()
# 
# pred_demographics <- rbind(age.pops[, 2:7], gender.pops[, 2:7], race.pops[, 2:7],
#                            mar.pops[, 2:7], edu.pops[, 2:7])
# plot_3_demographics <- read.csv("data/plot_3_demographics.csv")
# plot_3_demographics <- rbind(plot_3_demographics, pred_demographics)
# plot_3_demographics <- plot_3_demographics[plot_3_demographics$Label != "Refused", ]
# write.csv(plot_3_demographics, 'data/plot_demographics_new.csv')

plot_3_demographics <- read.csv('data/plot_demographics_new.csv')

ggplot(data=plot_3_demographics, aes(x=as.factor(paste(Cat, Label, sep='\n')),
                                     y=Prop, group=as.factor(Type), linetype=as.factor(Type))) +
  geom_point(stat="identity",colour='black') +
  geom_line() +
  facet_wrap(~Var, scales="free", nrow=1, ncol=6) +
  theme_bw() +
  scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  ylab('Proportion') +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

ggsave("plots/popu_vs_poll_demo_2.pdf", width=16, height=8)

pred_state <- pops %>%
  group_by(state) %>%
  summarize(Num=sum(N_)) %>%
  mutate(Prop=Num/sum(Num), Type='2018 PS Space', Var='State') %>%
  ungroup()
pred_state$Cat <- state.name[match(pred_state$state, state.abb)]
pred_state[8, "Cat"] <- "District of Columbia"
plot_state <- read.csv('data/plot_state_2.csv')
plot_state_new <- rbind(plot_state, pred_state[,2:6])
plot_state_new$Type <- factor(plot_state_new$Type, levels = c("2016 Election", "Poll", "2018 PS Space"))
ggplot(data=plot_state_new, aes(x=as.factor(Cat), y=Prop, group=as.factor(Type), linetype=as.factor(Type))) +
  geom_point(stat="identity", colour='black') +
  geom_line() +
  facet_wrap(~Var) +
  theme_bw() +
  scale_fill_manual(values=c('#1f78b4', '#33a02c', '#e31a1c', '#ff7f00', '#8856a7'), guide=FALSE) +
  scale_y_continuous(breaks=c(0, .01, .02, .03, .04, .05, .06, .07, .08, .09, .10, 1),
                     labels=c('0%', '1%', '2%', '3%', '4%', '5%', '6%', '7%', '8%', '9%', '10%', '100%'),
                     expand=c(0, 0), limits=c(0, .11)) +
  scale_alpha_manual(values=c(1, .3)) +
  ylab('Proportion') +
  labs(alpha='') +
  theme(legend.position="bottom",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        legend.title=element_blank(),
        legend.text=element_text(size=10),
        axis.text.y=element_text(size=10),
        axis.text.x=element_text(size=8, angle=90, hjust=0.95, vjust=0.2),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

ggsave("plots/popu_vs_poll_state_2.pdf", width=16, height=8)


##################################
## Polling: Who would you vote? ##
##################################

plot_vote_age <- data.frame(unclass(table(voting_df$vote, voting_df$age)))
colnames(plot_vote_age) <- c("18 - 24", "25 - 34", "35 - 44", "45 - 54", "> 54")
plot_vote_gender <- data.frame(unclass(table(voting_df$vote, voting_df$gender)))
colnames(plot_vote_gender) <- c("Male", "Female")
plot_vote_race <- data.frame(unclass(table(voting_df$vote, voting_df$race)))
colnames(plot_vote_race) <- c("White", "Black", "Hispanic", "Other")
plot_vote_edu <- data.frame(unclass(table(voting_df$vote, voting_df$edu)))
colnames(plot_vote_edu) <- c("Bachelors", "No Bachelors")

plot_vote_age <- plot_vote_age / rowSums(plot_vote_age)
plot_vote_gender <- plot_vote_gender / rowSums(plot_vote_gender)
plot_vote_race <- plot_vote_race / rowSums(plot_vote_race)
plot_vote_edu <- plot_vote_edu / rowSums(plot_vote_edu)


multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  numPlots = length(plots)
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  if (numPlots==1) {
    print(plots[[1]])
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

plot_vote_age <- rownames_to_column(plot_vote_age, "Vote")
plot_vote_gender <- rownames_to_column(plot_vote_gender, "Vote")
plot_vote_race <- rownames_to_column(plot_vote_race, "Vote")
plot_vote_edu <- rownames_to_column(plot_vote_edu, "Vote")

plot_vote_age <- plot_vote_age %>% tidyr::gather(Cat, Value, 2:6)
plot_vote_gender <- plot_vote_gender %>% tidyr::gather(Cat, Value, 2:3)
plot_vote_race <- plot_vote_race %>% tidyr::gather(Cat, Value, 2:5)
plot_vote_edu <- plot_vote_edu %>% tidyr::gather(Cat, Value, 2:3)

plot_vote_age$Type <- "Age"
plot_vote_gender$Type <- "Gender"
plot_vote_race$Type <- "Race"
plot_vote_edu$Type <- "Education"

plot_vote_age <- plot_vote_age %>% mutate(Cat=dplyr::recode_factor(Cat,
                                                  "18 - 24"="18 - 24",
                                                  "25 - 34"="25 - 34",
                                                  "35 - 44"="35 - 44",
                                                  "45 - 54"="45 - 54",
                                                  "> 54"="> 54",
                                                  .default = NA_character_))

plot_vote <- rbind(plot_vote_age, plot_vote_gender, plot_vote_race, plot_vote_edu)

#### strategy 1
# Who will you vote for in the House of Representatives in 2018?
g1 <- ggplot(plot_vote_age, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  ggtitle("Age") +
  theme_bw() +
    #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
    scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                       labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
    scale_alpha_manual(values=c(1, .3)) +
    labs(alpha='') +
    theme(legend.position="blank",
          axis.title.y=element_blank(),
          axis.title.x=element_blank(),
          axis.text.x=element_text(size=10, angle=20, hjust=1),
          strip.text=element_text(size=10),
          strip.background = element_rect(fill='grey92'),
          panel.grid = element_line(colour="grey", size=0.2))
  

g2 <- ggplot(plot_vote_gender, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  ggtitle("Gender") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))


g3 <- ggplot(plot_vote_race, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  ggtitle("Race") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

g4 <- ggplot(plot_vote_edu, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  ggtitle("Education") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

multiplot(g1, g2, g3, g4, cols=4)

#### strategy 2


ggplot(plot_vote_age, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  xlab("Group") +
  ylab("Percentage") +
  ggtitle("Percentage of Gender Groups") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))


ggplot(plot_vote_gender, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  xlab("Group") +
  ylab("Percentage") +
  ggtitle("Percentage of Gender Groups") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))


ggplot(plot_vote_race, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  xlab("Group") +
  ylab("Percentage") +
  ggtitle("Percentage of Gender Groups") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))


ggplot(plot_vote_edu, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  xlab("Group") +
  ylab("Percentage") +
  ggtitle("Percentage of Gender Groups") +
  theme_bw() +
  #scale_fill_manual(values=c('#1f78b4','#33a02c', '#e31a1c', '#ff7f00', '#8856a7'),guide=FALSE) +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="blank",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))


#### strategy 3

ggplot(plot_vote, aes(x=Cat,y=Value)) +
  geom_point(aes(fill=Vote),stat="identity") +
  geom_line(aes(group=Vote, linetype=Vote, color=Vote),stat="identity") +
  facet_wrap(~Type, scales="free", nrow=1, ncol=6) +
  theme_bw() +
  scale_y_continuous(breaks=c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1),
                     labels=c('0%','10%', '20%','30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%')) +
  scale_alpha_manual(values=c(1, .3)) +
  labs(alpha='') +
  theme(legend.position="bottom",
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_text(size=10, angle=20, hjust=1),
        strip.text=element_text(size=10),
        strip.background = element_rect(fill='grey92'),
        panel.grid = element_line(colour="grey", size=0.2))

ggsave("plots/plot_vote.pdf", width=16, height=8)
