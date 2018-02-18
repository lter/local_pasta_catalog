library(tidyverse)
library(xml2)
library(httr)
library(shiny)
library(shinyjs)

createLink <- function(val) {
  sprintf('<a href="https://doi.org/%s" target="_blank">DATA</a>', val)
  # sprintf('<a href="https://www.google.com/#q=%s" target="_blank" class="btn btn-primary">Info</a>',val)
}


# ui ----
ui <- fluidPage(
  
  tags$head(
    tags$style(
      HTML("#queryResult table tr th:nth-child(5){ width: 15%; }") # give dates field more width
    )
  ),
  
  titlePanel("our local catalog"),
  
  fluidRow(
    column(12,
           textAreaInput("keywordSearch", "keyword", value = "*"),
           actionButton("runSearch", "search")
    )
  ),
  
  fluidRow(
    column(12,
           hr()
    )
  ),
  
  fluidRow(
    column(12,
           div(dataTableOutput("queryResult"), style="font-size:85%")
           # tableOutput("queryResult")
    )
  )
  
)

# server ----
server <- function(input, output) {
   
  # query PASTA+
  solrQuery <- eventReactive(input$runSearch, {
    
    GET("https://pasta.lternet.edu/package/search/eml", query = list(defType='edismax', q=input$keywordSearch, fq="-scope:ecotrends", fq="-scope:lter-landsat*", fl='*', sort="score,desc", sort="packageid,asc", debug="false", start="0", rows="10"))
    
  })
  
  # PASTA+ query results to tibble
  output$queryResult <- renderDataTable({
    
    parsedContent <- content(solrQuery(), 'parsed') # yields class "xml_document" "xml_node"
    
    xmlContents <- xml_contents(parsedContent)
    
    # authors
    
    rows <- parsedContent %>%
      xml_find_all(".//document/authors") %>%
      map(~ xml_find_all(.x, xpath = "author"))
    
    
    rows_df <- data_frame(row = seq_along(rows),
                          nodeset = rows)
    
    (
      cells_df <- rows_df %>%
        mutate(col_name_raw = nodeset %>% map(~ xml_name(.)),
               cell_text = nodeset %>% map(~ xml_text(.)),
               i = nodeset %>% map(~ seq_along(.))) %>%
        select(row, i, col_name_raw, cell_text) %>%
        unnest()
    )
    
    (
      auth_cast <- cells_df %>%
        group_by(row) %>%
        summarise(auths = paste(cell_text, collapse = "; "))
    )
    
    # keywords
    
    rows <- parsedContent %>%
      xml_find_all(".//document/keywords") %>%
      map(~ xml_find_all(.x, xpath = "keyword"))
    
    rows_df <- data_frame(row = seq_along(rows),
                          nodeset = rows)
    
    (
      cells_df <- rows_df %>%
        mutate(col_name_raw = nodeset %>% map(~ xml_name(.)),
               cell_text = nodeset %>% map(~ xml_text(.)),
               i = nodeset %>% map(~ seq_along(.))) %>%
        select(row, i, col_name_raw, cell_text) %>%
        unnest()
    )
    
    (
      key_cast <- cells_df %>%
        group_by(row) %>%
        summarise(keys = paste(cell_text, collapse = "; "))
    )
    
    # put it all together
    
    queryResultTibble <-
      tibble(
        packageid = xmlContents %>% xml_find_all("packageid") %>% xml_text(),
        title = xmlContents %>% xml_find_all("title") %>% xml_text(),
        pubdate = xmlContents %>% xml_find_all("pubdate") %>% xml_text(),
        dates = paste(xmlContents %>% xml_find_all("begindate") %>% xml_text(), " to ", xmlContents %>% xml_find_all("enddate") %>% xml_text()),
        link = xmlContents %>% xml_find_all("doi") %>% xml_text() %>% createLink()
      ) %>%
      rowid_to_column('row') %>%
      inner_join(auth_cast, by = c('row')) %>%
      inner_join(key_cast, by = c('row')) %>%
      select(PackageID = packageid,
             Title = title,
             Keywords = keys,
             Originators = auths,
             Dates = dates,
             link)
    
    return(queryResultTibble)
    
  }, escape = FALSE, options = list(bFilter = 0, bLengthChange = F))
    

  }

# Run the application 
shinyApp(ui = ui, server = server)

