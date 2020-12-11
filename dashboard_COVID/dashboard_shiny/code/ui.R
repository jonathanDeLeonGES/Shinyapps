library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(shinyWidgets)
library(plotly)

# USER INTERFACE
shinyUI(
    
    dashboardPage(
        dashboardHeader(title = span(tagList(icon("diagnoses"), "COVID-19 Dashboard")), titleWidth = 350),
        
        dashboardSidebar(
            width = 350,
            
            ## Menu Lateral
            
            sidebarMenu(
                menuItem( span(tagList(icon("map-marker-alt"), "Mapa de Casos")), tabName = "casos"),
                menuItem(span(tagList(icon("bar-chart-o"), "Dashboard general")), tabName = "general")
            ),
            
            dateRangeInput("date_filter", "Rango fechas:",
                           separator = "a"),
            
            pickerInput("country", "Pais:",
                        c(),
                        options = list(
                            `actions-box` = TRUE,
                            `selected-text-format` = "count > 3"),
                        multiple = TRUE),
            
            radioGroupButtons(
                inputId = "option",
                label = "Tipo de caso", 
                choices = c("confirmados"="confirmed", "muertos"="death", "recuperados"="recovered"),
                status = "primary"
            ),
            
            sliderInput("n_casos", "Numero de casos", min = min(c()), max = 0,
                        value = c(0,max = max(c()), step = 10)
            ),
            
            hr(),
            column(4,
                   actionButton("filter", span(tagList(icon("filter"), "filtrar")), class = "btn-primary")
            ),
            column(4,
                   actionButton("reset", span(tagList(icon("refresh"), "Resetear")), class = "btn-warning")
            ),
            
            checkboxInput("legend", "Show legend", TRUE)
            
            
        ),
        
        dashboardBody(
            
            column(width = 12,
                   htmlOutput("case_title"),
            ),
            tabItems(
                tabItem("casos",
                        fluidRow(
                            box(h2("Mapa de casos"), width = 12,
                                leafletOutput("cases_map",height = 600),
                                hr(),
                                column(12,
                                       dataTableOutput("tblCases")
                                       )
                                
                            )
                            
                        )
                ),
                tabItem("general",
                        fluidRow(
                            column(width = 12,
                                   h3("Estadisticas Generales"),
                            ),
                            box(width = 12, status = "info",
                                   infoBoxOutput("total_conf"),
                                   infoBoxOutput("total_death"),
                                   infoBoxOutput("total_rec"),   
                            ),
                            
                            column(width = 12,
                                   h3("Estadisticas por tipo de casos"),
                            ),
                             
                            box(width = 12, status = "info",
                                column(6,
                                       h3("Top 10 paises con menos casos"),
                                       plotlyOutput("country_chart_min")
                                ),
                                column(6,
                                       h3("Top 10 paises con mas casos"),
                                       plotlyOutput("country_chart"),
                                ),
                                
                                column(width = 12,
                                       h3("Incremento de casos acumulados por fecha"),
                                ),
                                column(12,
                                       plotlyOutput("dates_chart", height='100%', width = '100%'),
                                ),
                                column(width = 12,
                                       h3("Incremento de casos por Pais y fecha"),
                                ),
                                column(12,
                                       plotlyOutput("country_map_chart", height = '100%', width = '100%'),
                                       sliderInput("DatesMerge",
                                                   "Dates:",
                                                   min = as.Date("1111-11-11","%Y-%m-%d"),
                                                   max = as.Date("1111-11-11","%Y-%m-%d"),
                                                   value=as.Date("1111-11-11"),
                                                   timeFormat="%Y-%m-%d")
                                ),
                            )
                        )
                )
            )
        )
    )
)

