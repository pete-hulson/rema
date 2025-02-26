
# Test examples of running REMA using existing ADMB RE model output report files
# (rwout.rep)

# Example R scripts and data files:
# inst/example_scripts
# inst/example_data

library(rema)
library(ggplot2)
# install.packages('cowplot')
library(dplyr)
library(cowplot) # provides helpful plotting utilities

ggplot2::theme_set(cowplot::theme_cowplot(font_size = 10) +
                     cowplot::background_grid() +
                     cowplot::panel_border())

# create directory for analysis
# out_path <- "test_rema"
if(!exists("out_path")) out_path = getwd()
if(!dir.exists(out_path)) dir.create(out_path)

# copy all data files to working directory
rema_path <- find.package('rema')
example_data_files <- list.files(path = file.path(rema_path, "example_data"))
example_data_files
file.copy(from = file.path(path = file.path(rema_path, "example_data"),
                           example_data_files),
          to = file.path(file.path(out_path), example_data_files),
          overwrite = TRUE)

setwd(out_path)

# Ex 1 RE ----

# Univariate version of the random effects model (i.e., single survey, single
# stratum) using an existing ADMB rwout.rep file. Example: Aleutian Islands
# shortraker (aisr.rep) with NMFS bottom trawl survey estimates

# (1) Read in existing rwout.rep files, which is the report file generated from
# the ADMB version of the random effects model
?read_admb_re
admb_re <- read_admb_re(filename = 'aisr_rwout.rep',
                        # optional label for the single biomass survey stratum
                        biomass_strata_names = 'Aleutians Islands',
                        model_name = 'admb_re_aisr')
names(admb_re)

# (2) Prepare REMA model inputs
?prepare_rema_input # note alternative methods for bringing in survey data observations
input <- prepare_rema_input(model_name = 'tmb_rema_aisr',
                            admb_re = admb_re,
                            zeros = list(assumption = 'NA'))
names(input)

# (3) Fit REMA model
?fit_rema
m <- fit_rema(input)

# (4) Check convergence criteria if you so wish
?check_convergence
check_convergence(m)

# (5) Get tidied data.frames from the REMA model output
?tidy_rema
output <- tidy_rema(rema_model = m)
names(output)
output$parameter_estimates # estimated fixed effects parameters
output$biomass_by_strata # data.frame of predicted and observed biomass by stratum
output$total_predicted_biomass # total predicted biomass (same as biomass_by_strata for univariate models)

# (6) Generate model plots
?plot_rema
plots <- plot_rema(tidy_rema = output,
                   # optional y-axis label
                   biomass_ylab = 'Biomass (t)')
plots$biomass_by_strata

# (7) Get one-step-ahead (OSA) residuals
?get_osa_residuals
osa <- get_osa_residuals(m, options = list(method = "cdf"))
cowplot::plot_grid(osa$plots$biomass_resids,
                   osa$plots$biomass_qqplot,
                   osa$plots$biomass_hist,
                   osa$plots$biomass_fitted,
                   ncol = 1)
osa$residuals$biomass %>% filter(is.nan(residual))
osa <- get_osa_residuals(m, options = list(method = "oneStepGeneric"))
osa <- get_osa_residuals(m, options = list(method = "fullGaussian"))
osa <- get_osa_residuals(m, options = list(method = "oneStepGaussianOffMode"))
osa <- get_osa_residuals(m, options = list(method = "oneStepGaussian"))
osa$residuals$biomass

# (8) Compare with ADMB RE model results
compare <- compare_rema_models(rema_models = list(m),
                               admb_re = admb_re,
                               biomass_ylab = 'Biomass (t)')
compare$plots$biomass_by_strata
names(compare$output)

# Ex 2 REM ----

# Multivariate version of the random effects model (REM) with a single survey
# and multiple strata. Example using Bering Sea and Aleutian Islands shortspine
# thornyhead

admb_re <- read_admb_re(filename = 'bsaisst_rwout.rep',
                      biomass_strata_names = c('AI survey', 'EBS slope survey', 'S. Bering Sea (AI survey)'),
                      model_name = 'admb_rem_bsaisst')

input <- prepare_rema_input(model_name = 'tmb_rema_bsaisst',
                            admb_re = admb_re,
                            zeros = list(assumption = 'NA'))

m <- fit_rema(input)
check_convergence(m)

output <- tidy_rema(rema_model = m)
output$parameter_estimates # estimated fixed effects parameters
output$biomass_by_strata # data.frame of predicted and observed biomass by stratum
output$total_predicted_biomass

plots <- plot_rema(tidy_rema = output,
                   # optional y-axis label
                   biomass_ylab = 'Biomass (t)')

# Use ggplot2 functions to modify formatting of plots
plots$biomass_by_strata + facet_wrap(~strata, ncol = 1, scales = 'free_y')
plots$total_predicted_biomass + ggplot2::ggtitle('BSAI Shortspine thornyhead predicted biomass')

compare <- compare_rema_models(rema_models = list(m),
                               admb_re = admb_re,
                               biomass_ylab = 'Biomass (t)')

# Note different confidence intervals between the ADMB version (Marlow method) and the TMB version (Delta method)
compare$plots$biomass_by_strata + facet_wrap(~strata, ncol = 1, scales = 'free_y')
compare$plots$total_predicted_biomass

osa <- get_osa_residuals(m, options = list(method = "cdf"))
cowplot::plot_grid(osa$plots$biomass_resids,
                   osa$plots$biomass_qqplot,
                   osa$plots$biomass_fitted,
                   ncol = 1)
osa$residuals$biomass %>% filter(is.nan(residual))
osa <- get_osa_residuals(m, options = list(method = "oneStepGeneric"))
osa <- get_osa_residuals(m, options = list(method = "fullGaussian"))
osa <- get_osa_residuals(m, options = list(method = "oneStepGaussianOffMode"))
osa$residuals$biomass %>% print(n = Inf)
osa <- get_osa_residuals(m, options = list(method = "oneStepGaussian"))
osa <- get_osa_residuals(m)
osa$residuals$biomass %>% print(n = Inf)

# Ex 3 REMA ----

# Multi-survey and multi-strata version of the random effects model (REMA).
# Example using GOA shortraker rockfish, which uses the same strata definitions
# for the biomass and CPUE survey.
admb_re <- read_admb_re(filename = 'goasr_rwout.rep',
                        biomass_strata_names = c('CGOA', 'EGOA', 'WGOA'),
                        cpue_strata_names = c('CGOA', 'EGOA', 'WGOA'),
                        model_name = 'admb_rema_goasr')

input <- prepare_rema_input(model_name = 'tmb_rema_goasr_cpue_wt=1',
                            multi_survey = 1,
                            admb_re = admb_re,
                            sum_cpue_index = TRUE,
                            wt_cpue = 1,
                            # one process error parameters (log_PE) estimated
                            PE_options = list(pointer_PE_biomass = c(1, 1, 1)),
                            # three scaling parameters (log_q) estimated, indexed as
                            # follows for each biomass survey stratum:
                            q_options = list(pointer_biomass_cpue_strata = c(1, 2, 3)))

input$data$wt_biomass
input$data$wt_cpue

m <- fit_rema(input)
check_convergence(m)

osa <- get_osa_residuals(m, options = list(method = "cdf"))
osa$residuals$biomass %>% filter(is.nan(residual))
osa$residuals$cpue %>% filter(is.nan(residual))
osa <- get_osa_residuals(m, options = list(method = "oneStepGeneric"))
osa <- get_osa_residuals(m, options = list(method = "fullGaussian"))
osa <- get_osa_residuals(m, options = list(method = "oneStepGaussianOffMode"))
osa$residuals$biomass
osa <- get_osa_residuals(m, options = list(method = "oneStepGaussian"))
# "oneStepGaussianOffMode", "fullGaussian", "oneStepGeneric",
# "oneStepGaussian", "cdf"
osa$residuals$biomass %>% print(n = Inf)
osa$plots$biomass_resids
osa$plots$cpue_resids
osa$plots$cpue_qq

output <- tidy_rema(m)
output$parameter_estimates

plots <- plot_rema(output, biomass_ylab = 'Biomass (t)', cpue_ylab = 'Relative Population Weights')
plots$biomass_by_strata + facet_wrap(~strata, ncol = 1, scales = 'free_y')
plots$cpue_by_strata + facet_wrap(~strata, ncol = 1, scales = 'free_y')
cowplot::plot_grid(plots$biomass_by_strata,
                   plots$cpue_by_strata,
                   ncol = 1)

plots$total_predicted_biomass
plots$total_predicted_cpue
plots$biomass_by_cpue_strata

input2 <- prepare_rema_input(model_name = 'tmb_rema_goasr_cpue_wt=0.5',
                            multi_survey = 1,
                            admb_re = admb_re,
                            sum_cpue_index = TRUE,
                            wt_cpue = 0.5,
                            # one process error parameters (log_PE) estimated
                            PE_options = list(pointer_PE_biomass = c(1, 1, 1)),
                            # three scaling parameters (log_q) estimated, indexed as
                            # follows for each biomass survey stratum:
                            q_options = list(pointer_biomass_cpue_strata = c(1, 2, 3)))
m2 <- fit_rema(input2)

compare <- compare_rema_models(rema_models = list(m, m2),
                               admb_re = admb_re,
                               biomass_ylab = 'Biomass (t)',
                               cpue_ylab = 'Relative Population Weights')
compare$plots$biomass_by_strata
compare$plots$total_predicted_biomass
compare$plots$total_predicted_cpue

# Ex 4 REMA ----

# Multi-survey and multi-strata version of the random effects model (REMA).
# Example using GOA shortspine thornyhead, which has different strata
# definitions for the biomass and CPUE surveys.
admb_re <- read_admb_re(filename = 'goasst_rwout.rep',
                      biomass_strata_names = c('CGOA (0-500 m)', 'CGOA (501-700 m)', 'CGOA (701-1000 m)',
                                               'EGOA (0-500 m)', 'EGOA (501-700 m)', 'EGOA (701-1000 m)',
                                               'WGOA (0-500 m)', 'WGOA (501-700 m)', 'WGOA (701-1000 m)'),
                      cpue_strata_names = c('CGOA', 'EGOA', 'WGOA'),
                      model_name = 'admb_rema_goasst')
admb_re$biomass_dat
length(unique(admb_re$biomass_dat$strata))
length(unique(admb_re$cpue_dat$strata))
input <- prepare_rema_input(model_name = 'tmb_rema_goasst',
                            multi_survey = 1,
                            admb_re = admb_re,
                            wt_cpue = 0.5,
                            sum_cpue_index = TRUE,
                            # three process error parameters (log_PE) estimated, indexed
                            # as follows for each biomass survey stratum:
                            PE_options = list(pointer_PE_biomass = c(1, 1, 1, 2, 2, 2, 3, 3, 3)),
                            # three scaling parameters (log_q) estimated, indexed as
                            # follows for each biomass survey stratum:
                            q_options = list(
                              pointer_biomass_cpue_strata = c(1, 1, 1, 2, 2, 2, 3, 3, 3),
                              pointer_q_cpue = c(1, 1, 1)), # equivalent of admb model, but maybe consider c(1, 2, 3) as best practice? i.e. why would scaling pars be shared across strata?
                            zeros = list(assumption = 'NA'))

input$par$logit_tau_biomass <- -2.70805
input$par$logit_tau_cpue <- -2.70805
# input$map$logit_tau_biomass <- factor(NA)
input$map$logit_tau_biomass <- factor(c(1))
input$map$logit_tau_cpue <- factor(c(1))

m <- fit_rema(input)
m$report()
m$sdrep
check_convergence(m)
output <- tidy_rema(m)
output$parameter_estimates
plots <- plot_rema(output, biomass_ylab = 'Biomass (t)',
                   cpue_ylab = 'Relative Population Weight')
plots$biomass_by_strata
plots$cpue_by_strata
plots$biomass_by_cpue_strata
plots$total_predicted_biomass
plots$total_predicted_cpue

cowplot::plot_grid(plots$biomass_by_strata + facet_wrap(~strata, nrow = 1),
                   plots$cpue_by_strata, nrow = 2)
cowplot::plot_grid(plots$biomass_by_cpue_strata, plots$cpue_by_strata, nrow = 2)

osa <- get_osa_residuals(m, options = list(method = "cdf"))
osa$residuals$biomass %>% filter(is.nan(residual))
osa$residuals$cpue %>% filter(is.nan(residual))
osa$plots$biomass_resids
compare <- compare_rema_models(rema_models = list(m),
                               admb_re = admb_re,
                               biomass_ylab = 'Biomass (t)',
                               cpue_ylab = 'Relative Population Weights')
compare$plots$biomass_by_strata
compare$plots$total_predicted_biomass
compare$plots$total_predicted_cpue
