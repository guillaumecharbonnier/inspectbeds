FROM rocker/shiny:4.3.3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shinydashboard', 'DT', 'ggplot2', 'dplyr', 'UpSetR', 'plotly'), repos='https://cloud.r-project.org/')"
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install(c('GenomicRanges', 'IRanges'))"

# Copy the app
COPY app.R /srv/shiny-server/inspectbeds/
COPY example_data /srv/shiny-server/inspectbeds/example_data/

# Expose port
EXPOSE 3838

# Run the app
CMD ["/usr/bin/shiny-server"]
