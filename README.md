# InspectBeds

An R Shiny application to visualize statistics and overlaps between a set of BED files.

## Features

- **📁 Multiple File Upload**: Upload and analyze multiple BED files simultaneously
- **📊 Comprehensive Statistics**: View detailed statistics including:
  - Number of regions per file
  - Total genomic coverage
  - Region length distributions (mean, median, min, max)
  - Chromosome distribution
- **🔄 Overlap Analysis**: 
  - Pairwise overlap matrices
  - Interactive heatmaps showing overlap percentages
  - Multi-way overlap visualization with UpSet plots
- **📈 Interactive Visualizations**:
  - Region length distribution histograms
  - Chromosome-wise region counts
  - Overlap heatmaps
  - UpSet plots for complex multi-way overlaps
- **💾 Example Data**: Built-in example datasets for quick testing

## Installation

### Prerequisites

- R (version >= 3.6.0)
- RStudio (recommended for easy usage)

### Install Dependencies

1. Clone this repository:
```bash
git clone https://github.com/guillaumecharbonnier/inspectbeds.git
cd inspectbeds
```

2. Install required R packages:
```bash
Rscript install_dependencies.R
```

Or manually install the packages in R:
```R
# Install BiocManager if not already installed
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install CRAN packages
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", 
                   "dplyr", "UpSetR", "plotly"))

# Install Bioconductor packages
BiocManager::install(c("GenomicRanges", "IRanges"))
```

## Usage

### Running the App

#### Option 1: Using Docker (Recommended)

The easiest way to run InspectBeds is using Docker:

```bash
# Build and run with docker-compose
docker-compose up -d

# Or build and run manually
docker build -t inspectbeds .
docker run -p 3838:3838 inspectbeds
```

Access the app at http://localhost:3838/inspectbeds/

#### Option 2: From Command Line
```bash
Rscript -e "shiny::runApp('app.R')"
```

#### Option 3: From RStudio
1. Open `app.R` in RStudio
2. Click the "Run App" button in the top right of the editor

#### Option 4: From R Console
```R
shiny::runApp('app.R')
```

The app will open in your default web browser (typically at http://127.0.0.1:XXXX).

### Using the Application

1. **Upload Files Tab**:
   - Click "Choose BED files" to upload one or more BED files
   - Or click "Load Example Data" to try the app with sample data
   - View the list of uploaded files

2. **Statistics Tab**:
   - View comprehensive statistics for each uploaded file
   - Explore region length distributions across files
   - Analyze chromosome-wise region counts

3. **Overlaps Tab**:
   - View pairwise overlap matrix showing how many regions overlap between files
   - Explore the interactive overlap heatmap

4. **Visualizations Tab**:
   - Examine UpSet plots for multi-way overlap analysis
   - View combinations of overlapping regions across all files

5. **About Tab**:
   - Learn more about the application and BED file format

## BED File Format

BED files should be tab-delimited text files with at least 3 columns:

| Column | Name   | Description                     |
|--------|--------|---------------------------------|
| 1      | chrom  | Chromosome name                 |
| 2      | start  | Start position (0-based)        |
| 3      | end    | End position (exclusive)        |
| 4      | name   | Region name (optional)          |
| 5      | score  | Score value (optional)          |
| 6      | strand | Strand (+/-) (optional)         |

Example:
```
chr1    1000    2000    region1    100    +
chr1    5000    6000    region2    200    +
chr2    2000    3000    region3    180    -
```

## Example Data

Three example BED files are provided in the `example_data/` directory:
- `sample1.bed` - 8 genomic regions
- `sample2.bed` - 8 genomic regions  
- `sample3.bed` - 8 genomic regions

These files contain overlapping regions across different chromosomes for demonstration purposes.

## Dependencies

### R Packages

**CRAN:**
- shiny (>= 1.7.0)
- shinydashboard (>= 0.7.2)
- DT (>= 0.20)
- ggplot2 (>= 3.3.0)
- dplyr (>= 1.0.0)
- UpSetR (>= 1.4.0)
- plotly (>= 4.10.0)

**Bioconductor:**
- GenomicRanges (>= 1.44.0)
- IRanges (>= 2.26.0)

## Troubleshooting

### Common Issues

**Issue**: "Package not found" error
- **Solution**: Run `Rscript install_dependencies.R` to install all required packages

**Issue**: BiocManager installation fails
- **Solution**: Update R to the latest version and try again

**Issue**: App doesn't load in browser
- **Solution**: Check the R console for the correct port number and manually navigate to http://127.0.0.1:PORT

**Issue**: "Cannot parse BED file" error
- **Solution**: Ensure your BED file is tab-delimited with at least 3 columns (chr, start, end)

## Documentation

- **[README.md](README.md)** - Main documentation (you are here)
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide for new users
- **[UI_GUIDE.md](UI_GUIDE.md)** - Detailed user interface guide
- **[TESTING.md](TESTING.md)** - Testing procedures and validation
- **[DESCRIPTION](DESCRIPTION)** - R package metadata

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License

## Author

Guillaume Charbonnier

## Acknowledgments

- Built with [Shiny](https://shiny.rstudio.com/)
- Genomic ranges analysis powered by [GenomicRanges](https://bioconductor.org/packages/GenomicRanges/)
- UpSet plots created with [UpSetR](https://github.com/hms-dbmi/UpSetR)
