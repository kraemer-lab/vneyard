library( EpiLine )
library( plotly )
library( optparse )

########################################################################################
### Command line arguments
########################################################################################

# Parse the command line arguments
option_list <- list(
  make_option( c("-o", "--output"), type = "character", default = "epiline", help = "Output file stem" ),
  make_option( c("-q", "--quantiles"), type = "character", default = "0.1, 0.5, 0.9", help = "Quantiles to plot" ),
  make_option( c("-p", "--plot-delay"), type = "integer", default = 15, help = "Delay in seconds before taking a screenshot of the plot" ),
  make_option( c("-d", "--date-of-report"), type = "character", default = NULL, help = "Date of the report" ),
  make_option( c("-r", "--reported-file"), type = "character", help = "Filename of reported cases" ),
  make_option( c("-l", "--linelist-file"), type = "character", help = "Filename of line list (report date, symptom date)" ),
  make_option( c("--mcmc-samples"), type = "integer", default = 100, help = "Number of MCMC samples" ),
  make_option( c("--mcmc-chains"), type = "integer", default = 1, help = "Number of MCMC chains" )
)
opt_parser <- OptionParser( option_list = option_list )
opt <- parse_args( opt_parser )

# Transform and validate input arguments
quantiles = as.numeric( strsplit( opt$quantiles, ",")[[1]] )  # "0.1, 0.2" -> [0.1, 0.2]
if ( is.null( opt$"date-of-report" ) ) {
  opt$"date-of-report" <- Sys.Date()
}
report_date <- as.Date( opt$"date-of-report" )

########################################################################################
### Model fitting
########################################################################################

# Fit the model
fit <- symptom_report.fit(
    file_reported = opt$"reported-file",
    file_linelist = opt$"linelist-file",
    report_date = report_date, 
    mcmc_n_samples = opt$"mcmc-samples",
    mcmc_n_chains = opt$"mcmc-chains"
)

########################################################################################
### Plotting
########################################################################################

# Symptoms plot
p <- fit$plot.symptoms()
html_file <- paste0(opt$output, "symptoms.html")
htmlwidgets::saveWidget( p, html_file, selfcontained = TRUE )
webshot::webshot(
    url = html_file,
    file = paste0(opt$output, "symptoms.png"),
    delay = opt$plot_delay
)

# Posterior distribution of daily growth rate r(t)
p <- fit$plot.r()
html_file <- paste0(opt$output, "r.html" )
htmlwidgets::saveWidget( p, html_file, selfcontained = TRUE )
webshot::webshot(
    url = html_file,
    file = paste0(opt$output, "r.png" ),
    delay = opt$plot_delay
)

# Symptom report distribution
p <- fit$plot.symptom_report.dist()
html_file <- paste0(opt$output, "symptom_report_dist.html" )
htmlwidgets::saveWidget( p, html_file, selfcontained = TRUE )
webshot::webshot(
    url = html_file,
    file = paste0(opt$output, "symptom_report_dist.png" ),
    delay = opt$plot_delay
)

# Symptom report quantiles
for (attempt in 1:5) {
    p <- fit$plot.symptom_report.quantiles( quantiles = quantiles )
    htmlwidgets::saveWidget( p, html_file, selfcontained = TRUE )
    html_file <- paste0(opt$output, "symptom_report_quantiles.html" )
    tryCatch({
        webshot::webshot(
            url = html_file,
            file = paste0(opt$output, "symptom_report_quantiles.png" ),
            delay = opt$plot_delay
        )
    }, error = function(e) {
        if (attempt == 5) {
            stop("Failed to generate plot")
        } else {
            message(paste0("Failed to generate plot (attempt ", attempt, "), retrying..."))
        }
    })
}
