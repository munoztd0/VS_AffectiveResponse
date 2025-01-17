#                                                                                                  #
#                                                                                                  #          #                                                                                                  #
#                                                                                                  #
#     Differential contributions of ventral striatum subregions in the motivational                #
#           and hedonic components of the affective processing of the reward                       #
#                                                                                                  #
#                                                                                                  #
#                   Eva R Pool                                                                     #
#                   David Munoz Tord                                                               #
#                   Sylvain Delplanque                                                             #
#                   Yoann Stussi                                                                   #
#                   Donato Cereghetti                                                              #
#                   Patrik Vuilleumier                                                             #
#                   David Sander                                                                   #
#                                                                                                  #
# Created by D.M.T. on NOVEMBER 2018                                                               #
# modified by E.R.P on  NOVEMBER 2021                                                              #
# modified by D.M.T. on October 2021                                                               #
# modified by E.R.P  on NOVEMBER  2021                                                             # 

if(!require(ddpcr)) {
  install.packages("ddpcr")
  library(ddpcr)
}  # to do quiet source


# Set path
analysis_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Set working directory
if (analysis_path != getwd()) #important for when we source 
  setwd(analysis_path)


quiet(source(file.path(analysis_path, "Rcode_REWOD_fMRI.R")), all=T) # run script quietly

# theme for plot
averaged_theme <- theme_bw(base_size = 24, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 28, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 28),
        axis.title.y = element_text(size =  28),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

# -------------------------------------- DIRECT COMPARISON CONCERN: NEW PLOT --------------------------------

# PANNEL A --------------------------------------------------------------

# prepare data
HED.ROI.TASK.PIT$y = HED.ROI.TASK.PIT$VS_VM; HED.ROI.TASK.PIT$x = HED.ROI.TASK.PIT$deltaCS_R; HED.ROI.TASK.PIT$ROI_type = "VS ventromedial"
PIT.ROI.TASK.PIT.means$y = PIT.ROI.TASK.PIT.means$effort; PIT.ROI.TASK.PIT.means$x = PIT.ROI.TASK.PIT.means$beta; PIT.ROI.TASK.PIT.means$ROI_type = "VS dorsolateral"

DF1 <- HED.ROI.TASK.PIT %>% select(x, y, ID, ROI_type); DF2 <- PIT.ROI.TASK.PIT.means %>% select(x, y, ID, ROI_type); DF <- rbind(DF1, DF2)

m.inter <- lm(x ~ y*ROI_type, data = DF); 

# Compare slopes
m.lst <- lstrends(m.inter, "ROI_type", var="y"); pairs(m.lst) #same as doing Anova(m.inter, type = "III")


colfunc <- colorRampPalette(c(pal[3], "blue")); blues = colfunc(10)
colfunc <- colorRampPalette(c(pal[2], "purple")); reds = colfunc(10)

pp <- ggplot(DF, aes(y = y, x = x, color = ROI_type, fill = ROI_type)) +
  geom_point() +
  geom_smooth(method='lm', alpha = 0.2, fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=c(reds[4],blues[3]), name = NULL, guide = NULL) +
  scale_color_manual(values=c(reds[4],blues[3]), name = NULL) +
  theme_bw()+ guides(color=guide_legend(override.aes=list(fill=NA)))


ppp <- pp + averaged_theme_regression + theme(legend.position=c(0.8, 0.15), legend.text = element_text(size =  18)); ppp

pppp <- ggMarginal(ppp, type = "density", alpha = .1, color = NA,   margins = 'y', groupFill = T) 

# print figure
pdf(file.path(figures_path,'Figure_interVS_PIT.pdf'))
print(pppp)
dev.off()


# PANNEL B --------------------------------------------------------------

#prepare data
PIT.ROI.HED.TASK.means$y = PIT.ROI.HED.TASK.means$betas; PIT.ROI.HED.TASK.means$ROI_type= "VS dorsolateral"
HED.ROI.HED.TASK$y = HED.ROI.HED.TASK$VS;  HED.ROI.HED.TASK$ROI_type = "VS ventromedial"
DF1 <- PIT.ROI.HED.TASK.means %>% select(y, ID, ROI_type); DF2 <- HED.ROI.HED.TASK %>% select(y, ID, ROI_type); DF <- rbind(DF1, DF2)

t.test(DF$y ~ DF$ROI_type,paired = TRUE, var.equal = FALSE)

sum1 = summaryBy(y ~ ROI_type, data = DF,
                 FUN = function(x) { c(m = mean(x, na.rm = T),
                                       s = se(x, na.rm = T)) } )

sum1$ROI <- ifelse(sum1$ROI_type == "VS dorsolateral", -0.25, 0.25)
DF$ROI <- ifelse(DF$ROI_type == "VS dorsolateral", -0.25, 0.25)
set.seed(666)
DF <- DF %>% mutate(ROI_typejit = jitter(as.numeric(ROI), 0.3),
                                  grouping = interaction(ID, ROI))


pp <- ggplot(DF, aes(x = ROI, y = y, 
                     color = ROI_type, fill = ROI_type)) +
  geom_line(aes(x = ROI_typejit, group = ID, y = y), alpha = .5, size = 0.5, color = 'gray' ) +
  
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, width = 0.5) +
  geom_point(aes(x = ROI_typejit), alpha = .3) +
  geom_crossbar(data = sum1, aes(y =  y.m, ymin= y.m-y.s, ymax= y.m+y.s), 
                width = 0.2 , alpha = 0.1) +
  ylab('Beta estimates (a.u.)') +
  xlab('VS subregion') +   
  scale_fill_manual(values=c(reds[4],blues[3]), name = NULL, guide = NULL) +
  scale_color_manual(values=c(reds[4],blues[3]), name = NULL) +
  scale_x_continuous(labels=c("dorsolateral", "ventromedial"),breaks = c(-.25,.25), limits = c(-.5,.5)) +
  theme_bw()+ guides(color=guide_legend(override.aes=list(fill=NA)))

 
ppp <- pp + averaged_theme; ppp

#print figure
pdf(file.path(figures_path,'Figure_interVS_HED.pdf'))
print(ppp)
dev.off()




# ----------------------------------- MOVEMENT CONCERN: REMOVE LEFT DORSOL LATERAL FROM ANALYSIS --------

# remove VS DL left to adress possible residual motor confunds
PIT.ROI.HED.TASK %>% select(-one_of('VS_DL_left'))
PIT.ROI.HED.TASK.long <- gather(PIT.ROI.HED.TASK, ROI , beta, VS_DL_right, factor_key=TRUE)

PIT.ROI.TASK.PIT %>% select(-one_of('VS_DL_left'))
PIT.ROI.TASK.PIT.long <- gather(PIT.ROI.TASK.PIT, ROI , beta, VS_DL_right, factor_key=TRUE)
PIT.ROI.TASK.PIT.long$ROI_type = 'PIT_ROI'

# ----------------------------------------------PIT TASK -----------------------------------------------

# select only the variable of interest
CM.PIT.ROI.PIT = select(PIT.ROI.TASK.PIT.long, 'ID','deltaCS_R','ROI_type','beta')


PIT.ROI.COMPARE <- join (CM.HED.ROI.PIT, CM.PIT.ROI.PIT, type = 'full')

PIT.ROI.COMPARE.means <- aggregate(PIT.ROI.COMPARE$beta, 
                                   by = list(PIT.ROI.COMPARE$ID,PIT.ROI.COMPARE$ROI_type, PIT.ROI.COMPARE$deltaCS_R), FUN='mean') # extract means
colnames(PIT.ROI.COMPARE.means) <- c('ID','ROI_type','deltaCS_R','beta')

PIT.ROI.COMPARE.means$ROI_type = factor(PIT.ROI.COMPARE.means$ROI_type)

# test
directPITroi.stat     <- aov_car(beta ~ deltaCS_R*ROI_type  + Error (ID/ROI_type ), data = PIT.ROI.COMPARE,
                                 observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(6.85), df = c(1), df_error = c(22)) # effect sizes (90%CI)


intROIPIT.BF <- generalTestBF(beta ~ ROI_type*deltaCS_R + ID, data = PIT.ROI.COMPARE.means, 
                              whichRandom = "ID", iterations = 50000)
intROIPIT.BF[9]/intROIPIT.BF[8] 


# ----------------------------------------------HED TASK -----------------------------------------------
# select only the variable of interest
CM.PIT.ROI.PIT = select(PIT.ROI.HED.TASK.long, 'ID','deltaCS_R','beta')
CM.PIT.ROI.PIT$ROI_type = 'PIT_ROI'

HED.ROI.COMPARE <- join (CM.HED.ROI.PIT, CM.PIT.ROI.PIT, type = 'full')

HED.ROI.COMPARE.means <- aggregate(HED.ROI.COMPARE$beta, 
                                   by = list(HED.ROI.COMPARE$ID,HED.ROI.COMPARE$ROI_type), FUN='mean') # extract means
colnames(HED.ROI.COMPARE.means) <- c('ID','ROI_type','beta')

HED.ROI.COMPARE.means$ROI_type = factor(HED.ROI.COMPARE.means$ROI_type)

# test
directHEDroi.stat     <- aov_car(beta ~ ROI_type  + Error (ID/ROI_type), data = HED.ROI.COMPARE, 
                                 factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(4.50), df = c(1), df_error = c(23)) # effect sizes (90%CI)


intROIHED.BF <- anovaBF(beta ~ ROI_type + ID, data = HED.ROI.COMPARE.means, 
                        whichRandom = "ID", iterations = 50000)
intROIHED.BF




