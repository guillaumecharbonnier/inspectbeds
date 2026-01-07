# InspectBeds User Interface Guide

## Application Layout

InspectBeds uses a dashboard layout with a sidebar navigation and multiple tabs.

### Main Components

#### 1. Header
- Application title: "InspectBeds"
- Located at the top of the page

#### 2. Sidebar Menu
Navigation tabs:
- 📁 **Upload Files** - Import BED files
- 📊 **Statistics** - View file statistics and distributions
- 🔄 **Overlaps** - Analyze pairwise overlaps
- 📈 **Visualizations** - Multi-way overlap plots
- ℹ️ **About** - Application information

## Tab Details

### Upload Files Tab

**Purpose**: Import BED files for analysis

**Elements**:
- **File Input Widget**: Click to browse and select BED files (supports multiple selection)
- **Help Text**: Explains BED file requirements
- **"Load Example Data" Button**: Loads pre-configured example files
- **Uploaded Files Table**: Shows list of loaded files with:
  - File name
  - Number of regions
  - Number of columns

**User Actions**:
1. Click "Choose BED files" button
2. Navigate to and select one or more .bed files
3. Or click "Load Example Data" for quick testing

### Statistics Tab

**Purpose**: Display comprehensive statistics for each BED file

**Elements**:

1. **Summary Statistics Table**:
   - File name
   - Number of regions
   - Total genomic coverage (bp)
   - Mean region length
   - Median region length
   - Min region length
   - Max region length
   - Number of chromosomes

2. **Region Length Distribution Plot**:
   - Histogram showing distribution of region sizes
   - Log scale on x-axis
   - Color-coded by file
   - Interactive: hover for details, zoom, pan

3. **Chromosome Distribution Plot**:
   - Bar chart showing number of regions per chromosome
   - Grouped by file
   - Interactive: hover for values

**Interpretation**:
- Compare region counts across files
- Identify files with similar/different coverage patterns
- Spot outliers in region lengths

### Overlaps Tab

**Purpose**: Analyze how files overlap with each other

**Elements**:

1. **Pairwise Overlap Matrix Table**:
   - Rows: Source files
   - Columns: Target files
   - Values: Number of regions from source that overlap with target
   - Diagonal: Total regions in each file

2. **Overlap Heatmap**:
   - Color intensity shows overlap percentage
   - Darker blue = higher overlap
   - Interactive: hover to see exact percentages
   - Axes labeled with file names

**Interpretation**:
- Matrix[i,j] = how many regions from file i overlap with file j
- Diagonal shows total regions per file
- Use to identify highly similar files
- Asymmetric overlaps indicate size differences

**Example**:
```
       File1  File2  File3
File1   100    45     30
File2    50   120     25
File3    35    28    150
```
- File1 has 100 total regions
- 45 regions from File1 overlap with File2
- 50 regions from File2 overlap with File1
  (asymmetry shows File2 might be larger)

### Visualizations Tab

**Purpose**: Visualize complex multi-way overlaps

**Elements**:

1. **UpSet Plot**:
   - Left side: Set sizes (bar chart showing total regions per file)
   - Bottom: Set combinations (dots and connecting lines)
   - Main: Intersection sizes (bars showing count of regions in each combination)
   - Ordered by frequency (largest intersections first)

2. **Venn Diagram** (2-3 files only):
   - Shows overlapping regions for 2-3 files
   - Numbers indicate region counts
   - Not available for 4+ files (use UpSet instead)

**Interpretation**:

**UpSet Plot**:
- Each vertical bar represents a unique combination of files
- Connected dots show which files are in that combination
- Single dot = regions unique to that file
- Multiple connected dots = regions shared by those files
- Bar height = number of regions in that specific combination

**Example Reading**:
```
If you see:
- A single dot under "File1" with bar height 50: 50 regions unique to File1
- Connected dots under "File1" and "File2" with bar height 20: 20 regions in both files
- Connected dots under all three files with bar height 10: 10 regions common to all
```

### About Tab

**Purpose**: Application information and help

**Elements**:
- Application description
- Feature list
- BED format specification
- Required R packages
- Usage instructions

## Interactive Features

### Data Tables
- **Sorting**: Click column headers to sort
- **Searching**: Use search box to filter rows
- **Pagination**: Navigate through pages if many rows
- **Column visibility**: Some tables allow hiding columns

### Plotly Charts
- **Hover**: Move mouse over plot elements for details
- **Zoom**: Click and drag to zoom in
- **Pan**: Hold shift and drag to pan
- **Reset**: Double-click to reset view
- **Download**: Use camera icon to save as PNG

### Notifications
- Success messages appear after successful actions (e.g., "Successfully loaded 3 BED files")
- Error messages appear if something goes wrong
- Appear in top-right corner and auto-dismiss

## Workflow Recommendations

### Basic Workflow
1. **Upload** → Load 2-5 BED files
2. **Statistics** → Review file characteristics
3. **Overlaps** → Check pairwise overlaps
4. **Visualizations** → Explore multi-way patterns

### Comparison Workflow
1. Upload multiple related files (e.g., replicates or conditions)
2. Check if region counts are similar (Statistics)
3. Examine overlap percentages (Overlaps heatmap)
4. Identify unique vs shared regions (UpSet plot)

### Quality Check Workflow
1. Upload experimental and control files
2. Verify expected region counts (Statistics table)
3. Check distribution patterns (Length/Chr plots)
4. Identify unexpected overlaps or gaps (UpSet plot)

## Tips for Best Results

1. **File Naming**: Use descriptive names - they appear in all plots
2. **File Count**: 
   - 2-3 files: Can use Venn diagrams
   - 4-10 files: UpSet plots work well
   - 10+ files: Consider grouping similar files
3. **Region Count**: Works with 10s to 100,000s of regions
4. **BED Format**: Stick to standard BED format for best compatibility
5. **Browser**: Use modern browser (Chrome, Firefox, Safari, Edge)

## Common Questions

**Q: Why do I see different numbers in the overlap matrix rows vs columns?**
A: Overlaps are directional. Matrix[i,j] counts regions from file i that overlap file j, which may differ from regions in file j that overlap file i if files have different region sizes or counts.

**Q: What if my files don't overlap?**
A: The app will still work. You'll see mostly zeros in the overlap matrix and individual bars in the UpSet plot showing regions unique to each file.

**Q: Can I download the results?**
A: Currently, you can save plots as PNG images using the download button on interactive plots. For data export, consider copying from tables.

**Q: How are overlaps calculated?**
A: Two regions overlap if they share any genomic coordinates on the same chromosome. A single base pair of overlap counts.

**Q: What if I have many chromosomes?**
A: The chromosome distribution plot will show all chromosomes. You may need to zoom or scroll horizontally in the plot.

## Troubleshooting

**Issue**: "Cannot parse BED file"
- **Solution**: Check file is tab-delimited with at least 3 columns

**Issue**: Plots not showing
- **Solution**: Ensure at least 2 files are loaded

**Issue**: UpSet plot empty
- **Solution**: Check that files have overlapping regions

**Issue**: App is slow
- **Solution**: Large files (100k+ regions) may take time to process

**Issue**: Table text is too small
- **Solution**: Use browser zoom (Ctrl/Cmd +)
