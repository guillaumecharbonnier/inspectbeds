# Testing Guide for InspectBeds

## Overview
This document provides instructions for testing the InspectBeds Shiny application.

## Prerequisites Testing

Before running the app, verify your R installation:

```R
# Check R version (should be >= 3.6.0)
R.version.string

# Check if required packages can be installed
install.packages("shiny")
library(shiny)
```

## Installation Testing

### Test 1: Dependency Installation

```bash
# Run the installation script
Rscript install_dependencies.R
```

**Expected Outcome**: All packages should install without errors.

**Common Issues**:
- Network connectivity required for package downloads
- BiocManager installation needs internet access
- May need sudo/admin rights depending on R installation location

### Test 2: Manual Package Check

```R
# In R console, verify packages load
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(GenomicRanges)
library(IRanges)
library(UpSetR)
library(plotly)
```

**Expected Outcome**: No errors when loading libraries.

## Application Testing

### Test 3: Launch Application

```bash
# Method 1: Command line
Rscript -e "shiny::runApp('app.R')"

# Method 2: In R console
shiny::runApp('app.R')
```

**Expected Outcome**: 
- App opens in browser at http://127.0.0.1:XXXX
- UI loads without errors
- All tabs are accessible

### Test 4: Example Data Loading

1. Launch the app
2. Click "Load Example Data" button
3. Navigate to each tab

**Expected Outcome**:
- Three example files load successfully
- "Uploaded Files" table shows 3 entries
- Statistics tab displays data for all files
- Overlaps tab shows matrix and heatmap
- Visualizations tab shows UpSet plot

### Test 5: File Upload

1. Navigate to "Upload Files" tab
2. Click "Choose BED files"
3. Select one or more BED files from `example_data/` directory
4. Verify files are listed in the table

**Expected Outcome**:
- Files upload successfully
- Table displays correct file information
- Success notification appears

### Test 6: Statistics Calculation

1. Load example data or upload files
2. Navigate to "Statistics" tab
3. Review the statistics table
4. Check the plots

**Expected Outcome**:
- Statistics table shows:
  - File names
  - Region counts
  - Total coverage
  - Mean, median, min, max lengths
  - Chromosome counts
- Length distribution plot displays correctly
- Chromosome distribution plot shows data

### Test 7: Overlap Analysis

1. Load at least 2 files
2. Navigate to "Overlaps" tab
3. Review overlap matrix
4. Check heatmap

**Expected Outcome**:
- Overlap matrix displays pairwise overlaps
- Diagonal shows total regions per file
- Heatmap visualizes overlap percentages
- Interactive hover shows detailed information

### Test 8: UpSet Plot

1. Load at least 2 files (ideally 3+)
2. Navigate to "Visualizations" tab
3. View UpSet plot

**Expected Outcome**:
- UpSet plot displays intersection sizes
- Set sizes shown on left
- Intersection combinations shown at bottom
- Bars show frequency of each combination

### Test 9: Different BED Formats

Test with BED files of different formats:
- BED3 (chr, start, end only)
- BED6 (with name, score, strand)
- BED12+ (full format)

**Expected Outcome**:
- All formats parse correctly
- Statistics calculated accurately
- No errors in console

### Test 10: Edge Cases

Test the following scenarios:

**Empty file**:
- Upload an empty BED file

**Single region file**:
- Upload a file with only 1 region

**Large file**:
- Upload a file with 10,000+ regions

**No overlaps**:
- Upload files with completely non-overlapping regions

**Expected Outcome**:
- App handles gracefully without crashes
- Appropriate messages shown for edge cases
- Visualizations adapt to data

## Validation Checks

### Code Quality

```bash
# Check for syntax errors
Rscript -e "source('app.R', echo=TRUE)"
```

### File Validation

Verify the example BED files:
```bash
# Check file format
head -n 5 example_data/sample1.bed
head -n 5 example_data/sample2.bed
head -n 5 example_data/sample3.bed

# Count lines
wc -l example_data/*.bed
```

**Expected Output**:
- Each file has 8 lines
- Tab-delimited with 6 columns
- Format: chr, start, end, name, score, strand

## Performance Testing

### Test 11: Multiple Files

Upload 5-10 BED files simultaneously.

**Expected Outcome**:
- App remains responsive
- All files process successfully
- Visualizations render within reasonable time

### Test 12: Large Regions

Create a test file with 100,000 regions:
```R
# Generate large test file
chr <- paste0("chr", sample(1:22, 100000, replace=TRUE))
start <- sample(1:1000000, 100000)
end <- start + sample(100:1000, 100000, replace=TRUE)
write.table(data.frame(chr, start, end), 
            "large_test.bed", 
            sep="\t", 
            row.names=FALSE, 
            col.names=FALSE, 
            quote=FALSE)
```

**Expected Outcome**:
- File loads within 10 seconds
- Statistics calculate correctly
- Plots render (may take longer for UpSet)

## Browser Compatibility

Test in multiple browsers:
- Chrome/Chromium
- Firefox
- Safari
- Edge

**Expected Outcome**:
- Consistent behavior across browsers
- Interactive elements work properly
- Plots render correctly

## Error Handling

### Test 13: Invalid Files

Try uploading:
- CSV file (not BED)
- File with incorrect format
- Binary file

**Expected Outcome**:
- App doesn't crash
- Error messages displayed
- Can continue using app

## Reporting Issues

If you find bugs or issues:

1. Note the R version: `R.version.string`
2. Note package versions: `sessionInfo()`
3. Describe steps to reproduce
4. Include error messages
5. Note browser and OS

## Success Criteria

The application passes testing if:
- ✓ All packages install successfully
- ✓ App launches without errors
- ✓ Example data loads and displays
- ✓ User files can be uploaded
- ✓ All statistics calculate correctly
- ✓ All visualizations render properly
- ✓ Interactive elements function
- ✓ App handles edge cases gracefully
- ✓ No crashes during normal operation

## Automated Testing (Optional)

For developers, consider adding:
```R
# Unit tests with testthat
library(testthat)

test_that("BED file parsing works", {
  bed <- parse_bed_file("example_data/sample1.bed", "test")
  expect_equal(nrow(bed), 8)
  expect_equal(ncol(bed), 8)
})

test_that("Statistics calculation works", {
  bed <- parse_bed_file("example_data/sample1.bed", "test")
  stats <- calculate_bed_stats(bed, "test")
  expect_equal(stats$Regions, 8)
})
```
