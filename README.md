# REMA
A generalized **R**andom **E**ffects model for fitting survey biomass estimates with the options of including **M**ultiple survey strata and an **A**dditional survey index

The random effects (RE) model was deveped by the NPFMC Groundfish Plan Team's Survey Averaging working group and has been used at the Alaska Fisheries Science Center (AFSC) since [2013](https://github.com/afsc-assessments/SurveyAverageRandomEffects/blob/013c9a937fa0133f594c7d66248677685ae77010/code/re.tpl) to estimate biomass in data-limited groundfish and crab stock assessments, and to apportion estimates of Acceptable Biological Catch by area. The RE model uses a Kalman filter approach, where the biomass is estimated as a series of random effects and the underlying state dynamics are modeled as a random walk ([Oct 2013 Joint GPT minutes](https://meetings.npfmc.org/CommentReview/DownloadFile?p=11009549-068b-40cf-903d-67f90686db60.pdf&fileName=C4%20c1%20Joint%20Plan%20Team%20Minutes.pdf)). There are several versions of the original single-strata (univariate) RE and the single-survey, multiple-strata (multivariate; REM) models currently in use at the AFSC. Though the versions share the same underlying state-space dynamics, [Monnahan et al. (2021)](https://meetings.npfmc.org/CommentReview/DownloadFile?p=86098951-a0ed-4021-a4e1-95abe5a357fe.pdf&fileName=Tiers%204%20and%205%20assessment%20considerations.pdf) found inconsistencies in the treatment of zero biomass observations and use of a prior or penalty on the process error parameter. Additionally, [Hulson et al. (2021)](https://repository.library.noaa.gov/view/noaa/28174) developed a third version of the model (REMA) that includes a second relative survey index (e.g., the NMFS longline survey) and estimates additional scaling parameters. All versions of the RE, REM, and REMA models described previously are currently used in AFSC stock assessments. The purpose of the `rema` R library is to develop a unified random effects model that is flexible enough to accommodate the multitude of use cases at the AFSC. As presented here, the REMA model is generalized to include the RE and REM. The variable names have been updated from their original versions to increase interpretability and transparency, and the model has been rewritten in Template Model Builder (TMB; [Kristensen et al. 2016](https://www.jstatsoft.org/article/view/v070i05)).

This library is under development. How-to instructions are on the way.
