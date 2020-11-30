#
# Parcial - Parte 2 - Product Development - Desarrollo Dashboard Shiny
# ui.R

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(plotly)
library(DT)

# Define UI for application that draws a histogram
dashboardPage(skin = "black",
    dashboardHeader(title = span(tagList(icon("diagnoses"), "Sales Dashboard"))),
    dashboardSidebar(
        width = 250,
        tags$style(
        ),
        sidebarMenu(
            menuItem(span(tagList(icon("chart-line"), "Dashboard")), tabName = "graphs"),
            menuItem(span(tagList(icon("table"), "Dataset")), tabName = "detail"),
            menuItem(span(tagList(icon("address-card"), "Acerca de")), tabName = "about")
        )
    ),
    dashboardBody(
        tabItems(
            tabItem("graphs",
                    titlePanel("Dashboard"),
                    sidebarLayout(
                        sidebarPanel(
                            tags$style(".well {background-color:beige;}"),
                            dateRangeInput("date_filter", "Rango fechas:",
                                           format = "mm/dd/yy",
                                           separator = " - "),
                            sliderInput("bins",
                                        "Número de bloques Histograma:",
                                        min = 1,
                                        max = 50,
                                        value = 30),
                            pickerInput("country", "Pais:",
                                        c(),
                                        options = list(
                                            `actions-box` = TRUE,
                                            `selected-text-format` = "count > 3"),
                                        multiple = TRUE),
                            
                            pickerInput("product", "Producto:",
                                        c(),
                                        options = list(
                                            `actions-box` = TRUE,
                                            `selected-text-format` = "count > 3"),
                                        multiple = TRUE),
                            
                            pickerInput("status", "Estado Orden:",
                                        c(),
                                        options = list(
                                            `actions-box` = TRUE,
                                            `selected-text-format` = "count > 3"),
                                        multiple = TRUE),
                            
                            pickerInput("customer", "Cliente:",
                                        c(),
                                        options = list(
                                            `actions-box` = TRUE,
                                            `selected-text-format` = "count > 3"),
                                        multiple = TRUE),
                            hr(),
                            column(4,
                                   actionButton("reset", "Resetear")
                            )
                        ),
                        mainPanel(
                            fluidRow(box(h3("Notas de Uso"),
                                        helpText("Utilice los controles de la parte izquierda para filtrar los datos de",
                                                 " las graficas."),
                                        br(),
                                        helpText("Si desea regresar al mismo estado del dashboard, favor copiar el link",
                                                 "proporcionado. El Filtro de \"Cliente\" no se puede pasar como parametro",
                                                 " dada la cantidad de datos diferentes que puede tener")),
                                    h3("Link"),
                                    verbatimTextOutput("link_io")),
                            fluidRow(
                                box(title = "ESTADO DE ORDENES", width = 12,
                                    column(3,
                                           tableOutput('orders_status_tbl')
                                        ),
                                    column(9,
                                           plotOutput("status_chart")
                                        ),
                                    ),
                                box(title = "INGRESOS POR PAIS", width = 12,
                                    column(3,
                                           h5("Top 5 paises con mas ingresos"),
                                           tableOutput("country_tbl")
                                    ),
                                    column(9,
                                           plotlyOutput("country_chart"),
                                           verbatimTextOutput("clickDataOut")
                                    ),
                                    pickerInput("country_city", "Filtrar por pais:",
                                                c(),
                                                options = list(
                                                    `actions-box` = TRUE)),
                                    fluidRow(
                                        column(4,
                                               h5("top 5 ciudades con mas ingresos"),
                                               tableOutput("country_city_tbl")
                                        ),
                                        column(8,
                                               plotlyOutput("city_chart"),
                                        ),
                                        column(4,
                                               h5("Productos mas vendidos e ingresos"),
                                               tableOutput("city_product_tbl"),
                                               
                                        ),
                                        column(8,
                                               plotlyOutput("country_city_chart"),
                                        ),
                                        
                                        column(4,
                                               h5("ingresos por anio"),
                                               tableOutput("city_year_tbl"),
                                        ),
                                        
                                        column(8,
                                               plotlyOutput("country_year_chart"),
                                        )
                                        
                                        ),
                                    )
                                ),
                            fluidRow(
                                box(title = "INFORMACIÓN DE ORDENES", width = 12,
                                    column(12,
                                           plotOutput("distPlot")),
                                    column(7,
                                           plotOutput("SalesBydate")),
                                    column(5,
                                           plotOutput("ordersbyCountry"))
                                           ))
                            
                        )
                    )
            ),
            tabItem("detail",
                    titlePanel("Dataset detallado"),
                    box(h3("Notas de Uso"),
                        helpText("Detalle completo del dataset utilizado para la realización", 
                                 " del dashboard")),
                    DT::dataTableOutput("contenido_dataset")
            ),
            tabItem("about",
                    titlePanel("Acerca de"),
                    fluidRow(
                        box(width = 12,
                            title = "INFORMACION", status = "info", solidHeader = TRUE,
                            collapsible = TRUE,
                            h2("Integrantes del Grupo"),
                            p("Jonathan De León       - Carné:09001843"),
                            p("Marlon Manuel Gonzales - Carné:20007175"),
                            helpText("Desarrollo del Parcial 1 - Parte 2 - Curso: Product Development",
                                     "Maestria en Ciencia de Datos - Universidad Galileo")
                        )
                    )
            )
            
        )
    )
)