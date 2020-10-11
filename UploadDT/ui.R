library(shiny)
library(DT)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    titlePanel("Cargar Archivos y Dataframe"),
    tabsetPanel(tabPanel("Cargar Archivo",
                         sidebarLayout(
                             sidebarPanel(
                                 h2("Subir Archivo"),
                                 fileInput("upload_file_1",
                                           label="cargar archivo...",
                                           buttonLabel = "Cargar",
                                           accept = c(".csv",".tsv"))
                                 ),
                             mainPanel(
                                 tableOutput("contenido_archivo_1"))
                             )
                         ),
                tabPanel("Cargar Archivo DT",
                         sidebarLayout(
                             sidebarPanel(
                                 h2("Subir Archivo"),
                                 fileInput("upload_file_2",
                                           label="cargar archivo...",
                                           buttonLabel = "Cargar",
                                           accept = c(".csv",".tsv"))
                             ),
                             mainPanel(
                                 DT::dataTableOutput("contenido_archivo_2")
                                 )
                         )
                         ),
                tabPanel("DT Option",
                         h2("Formato Columna"),
                         hr(),
                         fluidRow(column(width=12,DT::dataTableOutput("tabla1")
                                         )
                                  ),
                         h2("Opciones"),
                         hr(),
                         fluidRow(column(width=12,DT::dataTableOutput("tabla2")
                                         )
                                  ),
                         fluidRow(column(width=12,DT::dataTableOutput("tabla3")
                                        )
                                  )
                         ),
                tabPanel("Clicks en tabla",
                         fluidRow(column(width=12,
                                         h2("Click en una fila"),
                                         DT::dataTableOutput("tabla4"),
                                         verbatimTextOutput("tabla4_single_click")
                                         )
                                  ),
                         fluidRow(column(width=12,
                                         h2("Click en mutiples filas"),
                                         DT::dataTableOutput("tabla5"),
                                         verbatimTextOutput("tabla5_multi_click")
                                         )
                                   ),
                         fluidRow(column(width=12,
                                         h2("Click en una columna"),
                                         DT::dataTableOutput("tabla6"),
                                         verbatimTextOutput("tabla6_single_click")
                                         )
                                  ),
                         fluidRow(column(width=12,
                                         h2("Click en mutiples Columnas"),
                                         DT::dataTableOutput("tabla7"),
                                         verbatimTextOutput("tabla7_multi_click")
                                         )
                                  ),
                         fluidRow(column(width=12,
                                         h2("Click en una celda"),
                                         DT::dataTableOutput("tabla8"),
                                         verbatimTextOutput("tabla8_single_click")
                                         )
                                  ),
                         fluidRow(column(width=12,
                                         h2("Click en mutiples Celdas"),
                                         DT::dataTableOutput("tabla9"),
                                         verbatimTextOutput("tabla9_multi_click")
                                         )
                                 )
                         )
                )
))
