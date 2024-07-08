library( EpiLine )
library( optparse )

########################################################################################
### Command line arguments
########################################################################################

# Parse the command line arguments
option_list <- list(
  make_option( c("-o", "--output"), type = "character", default = "epiline", help = "Output filename" ),
  make_option( c("--start-date"), type = "character", default = "2020-04-01", help = "Start date of reporting" ),
  make_option( c("--duration"), type = "integer", default = 50, help = "Number of days for which data is reported" ),
  make_option( c("--pre-symptom"), type = "integer", default = 30, help = "Days before reporting period to simulate" ),
  make_option( c("--post-symptom"), type = "integer", default = 5, help = "Days after reporting period to simulate" ),
  make_option( c("--symptomatic"), type = "integer", default = 2, help = "Initial number of symptomatic individuals" )
)
opt_parser <- OptionParser( option_list = option_list )
opt <- parse_args( opt_parser )

########################################################################################
### Simulation
########################################################################################

set.seed( 1 )

# define the length of the simulation
t_rep          <- opt$duration # number of days for which data is reported
t_symptom_pre  <- opt$"pre-symptom"
t_symptom_post <- opt$"post-symptom"
t_max          <- t_rep + t_symptom_post + t_symptom_pre

# set up the variable r(t) and distribution
symptom_0 <- opt$symptomatic                  # initial number of symptomatic individuals
r         <- 0.1 - 0.13 * ( 1:t_max ) / t_max # r(t) in the simulation
xi        <- -1 + 6 * ( t_max:1 ) / t_max     # xi parameter in the symptom-report dist
lambda    <- 2 + ( t_max:1 ) / t_max          # lambda parameter in the symptom-report dist

simulation <- symptom_report.simulator(
  t_rep          = t_rep,
  t_symptom_pre  = t_symptom_pre,
  t_symptom_post = t_symptom_post,
  symptom_0   = symptom_0,
  r           = r,
  dist_xi     = xi,
  dist_lambda = lambda
)

########################################################################################
### Convert simlulation numerics to dates for export (and reimport)
########################################################################################

# provide a date vector for the simulation
start_date <- as.Date( "2020-04-02" )
date <- seq.Date(
  from = start_date,
  by   = "day",
  length.out = length( simulation$reported )
)

# convert the linelist to dates (see https://github.com/BDI-pathogens/Epiline)
ll_report <- date[ simulation$linelist$report ]

# offset date by days in 'symptom' (negative values relative to start of simulation)
start_date_vector <- start_date + rep( 0, length( simulation$linelist$symptom ) )
ll_symptom <- start_date_vector + simulation$linelist$symptom


########################################################################################
### Save to file
########################################################################################

# reported.csv
data <- data.frame(
    date = date,
    reported = simulation$reported
)
write.csv(
    data,
    file = paste0(opt$output, "reported.csv"),
    row.names = FALSE
)

# linelist.csv
data <- data.frame(
    report = ll_report,
    symptom = ll_symptom
)
write.csv(
    data,
    file = paste0(opt$output, "linelist.csv"),
    row.names = FALSE
)
