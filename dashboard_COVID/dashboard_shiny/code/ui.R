

library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)

confirmados <- read.csv(file = 'data/confirmed.csv', sep = ",")
confirmados$variable <- format(as.Date(confirmados$variable,format = "%m/%d/%y"),"20%y/%m/%d")
confirmados$variable <- as.Date(confirmados$variable)

muertos <- read.csv(file = 'data/deaths.csv', sep = ",")
muertos$variable <- format(as.Date(muertos$variable,format = "%m/%d/%y"),"20%y/%m/%d")
muertos$variable <- as.Date(muertos$variable)

recuperados <- read.csv(file = 'data/recovered.csv', sep = ",")
recuperados$variable <- format(as.Date(recuperados$variable,format = "%m/%d/%y"),"20%y/%m/%d")
recuperados$variable <- as.Date(recuperados$variable)


# USER INTERFACE
shinyUI(
    
    dashboardPage(
        dashboardHeader(title = "Product Development",titleWidth = 300),
        
        dashboardSidebar(
            width = 300,
            
            
            ## Menu Lateral
            
            sidebarMenu(
                
                menuItem("Dashboard Confirmados", tabName = "confirmados"), 
                menuItem("Dashboard Muertos", tabName = "muertos"),
                menuItem("Filtered data", tabName = "filterdata"),
                menuItem("Filtered Histograms", tabName = "filterhist"),
                menuItem("URL Queries", tabName = "urlqueries")
            ),
            
            selectInput("PaisConfirmados", "Pais de Confirmados",
                        c("NINGUNO","TODOS",unique(confirmados$Country.Region))
            ),
            
            sliderInput("n_confirmados", "Numero de Confirmados", min = min(confirmados$value), max = max(confirmados$value),
                        value = c(0,max = max(confirmados$value)), step = 10
            ),
            
            dateRangeInput("ConfDate-Input", "Seleccione Rangos de Fecha:", start = min(confirmados$variable), end = max(confirmados$variable), max = max(confirmados$variable), min = min(confirmados$variable), separator = 'a'),
            
            
            
            sliderInput("n_muertos", "Numero de Muertos", min = min(muertos$value), max = max(muertos$value),
                        value = c(0,max = max(muertos$value)), step = 10
            ),
            
            selectInput("PaisMuertos", "Pais de Muertos",
                        c("NINGUNO","TODOS",unique(muertos$Country.Region))
            ),
            
            dateRangeInput("muertosDate-Input", "Seleccione Rangos de Fecha:", start = min(muertos$variable), end = max(muertos$variable), max = max(muertos$variable), min = min(muertos$variable), separator = 'a'),
            
            
            checkboxInput("legend", "Show legend", TRUE)
            
            
        ),
        
        dashboardBody(
            
            tabItems(
                
                tabItem("confirmados",
                        fluidRow(
                            leafletOutput("mapa_confirmados",height = 600),
                            dataTableOutput("TablaConfirmados")
                        )
                ),
                
                tabItem("muertos",
                        fluidRow(
                            leafletOutput("mapa_muertos",height = 600),
                            dataTableOutput("TablaMuertos")
                        )
                )
            )
        )
    )
)

