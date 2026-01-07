# InspectBeds Quick Start Guide

## 🚀 Quick Start (5 minutes)

### 1. Install Dependencies

```bash
# From the terminal
Rscript install_dependencies.R
```

This will install all required R packages (~5 minutes on first run).

### 2. Run the App

```bash
# From the terminal
Rscript -e "shiny::runApp('app.R')"
```

Or open `app.R` in RStudio and click "Run App".

### 3. Try It Out

1. Click **"Load Example Data"** button to load sample BED files
2. Navigate to the **Statistics** tab to see file summaries
3. Check the **Overlaps** tab to see how files overlap
4. Explore the **Visualizations** tab for UpSet plots

### 4. Upload Your Own Data

1. Go to the **Upload Files** tab
2. Click **"Choose BED files"** and select your BED files
3. Explore the various tabs to analyze your data

## 📋 BED File Requirements

Your BED files must be:
- Tab-delimited text files
- At least 3 columns: chromosome, start, end
- 0-based start coordinates

Example format:
```
chr1    1000    2000
chr1    5000    6000
chr2    2000    3000
```

## 🎯 Key Features to Try

1. **Upload multiple files** - Compare 2-10 BED files at once
2. **Statistics** - See region counts, coverage, and length distributions
3. **Overlap Analysis** - View pairwise overlaps in matrix and heatmap format
4. **UpSet Plot** - Visualize complex multi-way overlaps
5. **Interactive plots** - Hover, zoom, and explore all visualizations

## 🔧 Troubleshooting

**App won't start?**
- Make sure all dependencies are installed: `Rscript install_dependencies.R`

**Can't load files?**
- Check that files are tab-delimited with at least 3 columns
- Ensure no header row in BED files

**Need help?**
- Check the **About** tab in the app
- See full documentation in `README.md`

## 📚 Learn More

- Full documentation: `README.md`
- Example data: `example_data/` folder
- BED format specs: https://genome.ucsc.edu/FAQ/FAQformat.html#format1
