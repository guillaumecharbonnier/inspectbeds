# InspectBeds - R Shiny App to Visualize BED File Statistics and Overlaps
# Author: Generated for guillaumecharbonnier/inspectbeds

library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(GenomicRanges)
library(UpSetR)
library(plotly)

# Helper Functions --------------------------------------------------------

# Parse BED file
parse_bed_file <- function(file_path, file_name) {
  tryCatch({
    # Read BED file (assuming at least 3 columns: chr, start, end)
    bed_data <- read.table(file_path, 
                          header = FALSE, 
                          stringsAsFactors = FALSE,
                          sep = "\t",
                          comment.char = "",
                          quote = "")
    
    # Handle different BED formats (BED3, BED6, BED12+)
    colnames(bed_data)[1:3] <- c("chr", "start", "end")
    if (ncol(bed_data) >= 4) colnames(bed_data)[4] <- "name"
    if (ncol(bed_data) >= 5) colnames(bed_data)[5] <- "score"
    if (ncol(bed_data) >= 6) colnames(bed_data)[6] <- "strand"
    
    bed_data$file_name <- file_name
    bed_data$region_length <- bed_data$end - bed_data$start
    
    return(bed_data)
  }, error = function(e) {
    return(NULL)
  })
}

# Calculate statistics for a single BED file
calculate_bed_stats <- function(bed_data, file_name) {
  data.frame(
    File = file_name,
    Regions = nrow(bed_data),
    Total_Coverage = sum(bed_data$region_length),
    Mean_Length = mean(bed_data$region_length),
    Median_Length = median(bed_data$region_length),
    Min_Length = min(bed_data$region_length),
    Max_Length = max(bed_data$region_length),
    Chromosomes = length(unique(bed_data$chr)),
    stringsAsFactors = FALSE
  )
}

# Calculate overlaps between BED files
calculate_overlaps <- function(bed_list) {
  if (length(bed_list) < 2) {
    return(NULL)
  }
  
  # Convert to GRanges objects
  gr_list <- lapply(names(bed_list), function(name) {
    bed <- bed_list[[name]]
    GRanges(
      seqnames = bed$chr,
      ranges = IRanges(start = bed$start, end = bed$end),
      name = name
    )
  })
  names(gr_list) <- names(bed_list)
  
  # Calculate pairwise overlaps
  overlap_matrix <- matrix(0, nrow = length(gr_list), ncol = length(gr_list))
  rownames(overlap_matrix) <- names(gr_list)
  colnames(overlap_matrix) <- names(gr_list)
  
  for (i in seq_along(gr_list)) {
    for (j in seq_along(gr_list)) {
      if (i == j) {
        overlap_matrix[i, j] <- length(gr_list[[i]])
      } else {
        overlaps <- findOverlaps(gr_list[[i]], gr_list[[j]])
        overlap_matrix[i, j] <- length(unique(queryHits(overlaps)))
      }
    }
  }
  
  return(overlap_matrix)
}

# Create UpSet plot data
create_upset_data <- function(bed_list) {
  if (length(bed_list) < 2) {
    return(NULL)
  }
  
  # Convert to GRanges
  gr_list <- lapply(names(bed_list), function(name) {
    bed <- bed_list[[name]]
    GRanges(
      seqnames = bed$chr,
      ranges = IRanges(start = bed$start, end = bed$end)
    )
  })
  names(gr_list) <- names(bed_list)
  
  # Create a union of all regions
  all_regions <- reduce(do.call(c, unname(gr_list)))
  
  # Check which files each region overlaps with
  upset_matrix <- data.frame(matrix(0, nrow = length(all_regions), ncol = length(gr_list)))
  colnames(upset_matrix) <- names(gr_list)
  
  for (i in seq_along(gr_list)) {
    overlaps <- findOverlaps(all_regions, gr_list[[i]])
    upset_matrix[queryHits(overlaps), i] <- 1
  }
  
  return(upset_matrix)
}

# UI Definition -----------------------------------------------------------

ui <- dashboardPage(
  dashboardHeader(title = "InspectBeds"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Upload Files", tabName = "upload", icon = icon("upload")),
      menuItem("Statistics", tabName = "stats", icon = icon("chart-bar")),
      menuItem("Overlaps", tabName = "overlaps", icon = icon("project-diagram")),
      menuItem("Visualizations", tabName = "viz", icon = icon("chart-line")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Upload tab
      tabItem(tabName = "upload",
        fluidRow(
          box(
            title = "Upload BED Files",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            fileInput("bed_files", 
                     "Choose BED files (supports multiple files)",
                     multiple = TRUE,
                     accept = c(".bed", ".BED", ".txt")),
            helpText("Upload one or more BED files. Files should be tab-delimited with at least 3 columns (chr, start, end)."),
            actionButton("load_example", "Load Example Data", icon = icon("download"))
          )
        ),
        fluidRow(
          box(
            title = "Uploaded Files",
            width = 12,
            status = "info",
            DTOutput("uploaded_files_table")
          )
        )
      ),
      
      # Statistics tab
      tabItem(tabName = "stats",
        fluidRow(
          box(
            title = "Summary Statistics",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("stats_table")
          )
        ),
        fluidRow(
          box(
            title = "Region Length Distribution",
            width = 12,
            status = "info",
            plotlyOutput("length_distribution_plot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Chromosome Distribution",
            width = 12,
            status = "info",
            plotlyOutput("chr_distribution_plot", height = "400px")
          )
        )
      ),
      
      # Overlaps tab
      tabItem(tabName = "overlaps",
        fluidRow(
          box(
            title = "Pairwise Overlap Matrix",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            helpText("Shows the number of regions from each file (rows) that overlap with regions in other files (columns)."),
            DTOutput("overlap_matrix_table")
          )
        ),
        fluidRow(
          box(
            title = "Overlap Heatmap",
            width = 12,
            status = "info",
            plotlyOutput("overlap_heatmap", height = "500px")
          )
        )
      ),
      
      # Visualizations tab
      tabItem(tabName = "viz",
        fluidRow(
          box(
            title = "UpSet Plot - Multi-way Overlaps",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            helpText("Interactive UpSet plot showing combinations of overlapping regions across all files."),
            plotOutput("upset_plot", height = "600px")
          )
        ),
        fluidRow(
          box(
            title = "Venn Diagram (2-3 files only)",
            width = 12,
            status = "info",
            plotOutput("venn_diagram", height = "400px")
          )
        )
      ),
      
      # About tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "About InspectBeds",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            h3("InspectBeds - BED File Visualization Tool"),
            p("This R Shiny application helps you visualize statistics and overlaps between multiple BED files."),
            h4("Features:"),
            tags$ul(
              tags$li("Upload multiple BED files"),
              tags$li("Calculate comprehensive statistics (region counts, coverage, length distributions)"),
              tags$li("Analyze pairwise overlaps between files"),
              tags$li("Visualize multi-way overlaps with UpSet plots"),
              tags$li("Interactive plots and tables")
            ),
            h4("BED File Format:"),
            p("BED files should be tab-delimited with at least 3 columns:"),
            tags$ul(
              tags$li("Column 1: Chromosome"),
              tags$li("Column 2: Start position (0-based)"),
              tags$li("Column 3: End position"),
              tags$li("Additional columns (optional): name, score, strand, etc.")
            ),
            h4("Required R Packages:"),
            tags$ul(
              tags$li("shiny"),
              tags$li("shinydashboard"),
              tags$li("DT"),
              tags$li("ggplot2"),
              tags$li("dplyr"),
              tags$li("GenomicRanges"),
              tags$li("UpSetR"),
              tags$li("plotly")
            )
          )
        )
      )
    )
  )
)

# Server Logic ------------------------------------------------------------

server <- function(input, output, session) {
  
  # Reactive values to store uploaded data
  bed_data_list <- reactiveVal(list())
  
  # Handle file upload
  observeEvent(input$bed_files, {
    req(input$bed_files)
    
    bed_list <- list()
    for (i in seq_len(nrow(input$bed_files))) {
      file_name <- input$bed_files$name[i]
      file_path <- input$bed_files$datapath[i]
      
      bed <- parse_bed_file(file_path, file_name)
      if (!is.null(bed)) {
        bed_list[[file_name]] <- bed
      }
    }
    
    bed_data_list(bed_list)
    
    showNotification(
      paste("Successfully loaded", length(bed_list), "BED file(s)"),
      type = "message"
    )
  })
  
  # Handle example data loading
  observeEvent(input$load_example, {
    # Create example BED data
    example1 <- data.frame(
      chr = c("chr1", "chr1", "chr2", "chr2", "chr3"),
      start = c(1000, 5000, 2000, 8000, 3000),
      end = c(2000, 6000, 3000, 9000, 4000),
      file_name = "example1.bed",
      region_length = c(1000, 1000, 1000, 1000, 1000),
      stringsAsFactors = FALSE
    )
    
    example2 <- data.frame(
      chr = c("chr1", "chr1", "chr2", "chr3", "chr3"),
      start = c(1500, 5500, 2500, 3500, 6000),
      end = c(2500, 6500, 3500, 4500, 7000),
      file_name = "example2.bed",
      region_length = c(1000, 1000, 1000, 1000, 1000),
      stringsAsFactors = FALSE
    )
    
    example3 <- data.frame(
      chr = c("chr1", "chr2", "chr2", "chr3", "chr4"),
      start = c(1200, 2200, 8500, 3200, 1000),
      end = c(1800, 2800, 9500, 3800, 2000),
      file_name = "example3.bed",
      region_length = c(600, 600, 1000, 600, 1000),
      stringsAsFactors = FALSE
    )
    
    bed_data_list(list(
      "example1.bed" = example1,
      "example2.bed" = example2,
      "example3.bed" = example3
    ))
    
    showNotification("Example data loaded successfully!", type = "message")
  })
  
  # Display uploaded files
  output$uploaded_files_table <- renderDT({
    req(bed_data_list())
    
    file_info <- data.frame(
      File = names(bed_data_list()),
      Regions = sapply(bed_data_list(), nrow),
      Columns = sapply(bed_data_list(), ncol),
      stringsAsFactors = FALSE
    )
    
    datatable(file_info, options = list(pageLength = 10), rownames = FALSE)
  })
  
  # Calculate and display statistics
  output$stats_table <- renderDT({
    req(bed_data_list())
    req(length(bed_data_list()) > 0)
    
    stats_list <- lapply(names(bed_data_list()), function(name) {
      calculate_bed_stats(bed_data_list()[[name]], name)
    })
    
    stats_df <- do.call(rbind, stats_list)
    
    datatable(stats_df, 
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE) %>%
      formatRound(columns = c("Total_Coverage", "Mean_Length", "Median_Length"), digits = 2)
  })
  
  # Length distribution plot
  output$length_distribution_plot <- renderPlotly({
    req(bed_data_list())
    req(length(bed_data_list()) > 0)
    
    all_data <- do.call(rbind, bed_data_list())
    
    p <- ggplot(all_data, aes(x = region_length, fill = file_name)) +
      geom_histogram(alpha = 0.6, position = "identity", bins = 50) +
      scale_x_log10() +
      labs(x = "Region Length (log10)", y = "Count", fill = "File") +
      theme_minimal() +
      theme(legend.position = "bottom")
    
    ggplotly(p)
  })
  
  # Chromosome distribution plot
  output$chr_distribution_plot <- renderPlotly({
    req(bed_data_list())
    req(length(bed_data_list()) > 0)
    
    all_data <- do.call(rbind, bed_data_list())
    chr_counts <- all_data %>%
      group_by(file_name, chr) %>%
      summarise(count = n(), .groups = "drop")
    
    p <- ggplot(chr_counts, aes(x = chr, y = count, fill = file_name)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(x = "Chromosome", y = "Number of Regions", fill = "File") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "bottom")
    
    ggplotly(p)
  })
  
  # Overlap matrix
  output$overlap_matrix_table <- renderDT({
    req(bed_data_list())
    req(length(bed_data_list()) >= 2)
    
    overlap_mat <- calculate_overlaps(bed_data_list())
    
    # Convert to data frame for display
    overlap_df <- as.data.frame(overlap_mat)
    overlap_df <- cbind(File = rownames(overlap_mat), overlap_df)
    
    datatable(overlap_df, 
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE)
  })
  
  # Overlap heatmap
  output$overlap_heatmap <- renderPlotly({
    req(bed_data_list())
    req(length(bed_data_list()) >= 2)
    
    overlap_mat <- calculate_overlaps(bed_data_list())
    
    # Calculate percentage overlaps
    overlap_pct <- sweep(overlap_mat, 1, diag(overlap_mat), "/") * 100
    
    plot_ly(z = overlap_pct,
            x = colnames(overlap_pct),
            y = rownames(overlap_pct),
            type = "heatmap",
            colorscale = "Blues",
            text = round(overlap_pct, 1),
            hovertemplate = "From: %{y}<br>To: %{x}<br>Overlap: %{z:.1f}%<extra></extra>") %>%
      layout(xaxis = list(title = "Target File"),
             yaxis = list(title = "Source File"),
             title = "Overlap Percentage Heatmap")
  })
  
  # UpSet plot
  output$upset_plot <- renderPlot({
    req(bed_data_list())
    req(length(bed_data_list()) >= 2)
    
    upset_data <- create_upset_data(bed_data_list())
    
    if (!is.null(upset_data) && nrow(upset_data) > 0) {
      upset(upset_data, 
            nsets = length(bed_data_list()),
            order.by = "freq",
            text.scale = c(1.3, 1.3, 1, 1, 1.5, 1.2))
    }
  })
  
  # Venn diagram placeholder
  output$venn_diagram <- renderPlot({
    req(bed_data_list())
    
    num_files <- length(bed_data_list())
    
    if (num_files < 2 || num_files > 3) {
      plot.new()
      text(0.5, 0.5, "Venn diagrams are only available for 2-3 files.\nPlease use the UpSet plot for more files.",
           cex = 1.2)
    } else {
      # Calculate overlaps for Venn diagram
      overlap_mat <- calculate_overlaps(bed_data_list())
      
      if (num_files == 2) {
        # 2-way Venn
        file1 <- names(bed_data_list())[1]
        file2 <- names(bed_data_list())[2]
        
        only_1 <- overlap_mat[1, 1] - overlap_mat[1, 2]
        only_2 <- overlap_mat[2, 2] - overlap_mat[2, 1]
        both <- overlap_mat[1, 2]
        
        plot.new()
        par(mar = c(2, 2, 3, 2))
        
        # Draw circles
        symbols(c(0.35, 0.65), c(0.5, 0.5), circles = c(0.2, 0.2), 
                inches = FALSE, add = TRUE, fg = c("blue", "red"), lwd = 2)
        
        # Add labels
        text(0.25, 0.5, only_1, cex = 1.5)
        text(0.75, 0.5, only_2, cex = 1.5)
        text(0.5, 0.5, both, cex = 1.5)
        
        text(0.25, 0.8, file1, cex = 1.2, col = "blue")
        text(0.75, 0.8, file2, cex = 1.2, col = "red")
        
        title("2-Way Venn Diagram", cex.main = 1.5)
      } else {
        # 3-way Venn - simplified representation
        plot.new()
        text(0.5, 0.5, "3-way Venn diagram implementation\nPlease refer to the UpSet plot for detailed multi-way overlaps",
             cex = 1.2)
      }
    }
  })
}

# Run the application -----------------------------------------------------

shinyApp(ui = ui, server = server)
