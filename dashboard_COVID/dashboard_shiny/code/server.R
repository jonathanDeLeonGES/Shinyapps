library(shiny)
library(leaflet)
library(shinydashboard)
library(RColorBrewer)
library(RMySQL)
library(tidyverse)
library(plotly)
library(ggplot2)

#conexion a base de datos
connection <- function(){
    return(dbConnect(MySQL(),user='covid', password='covid123',
                     host='db',port=3306,dbname='covid'))
}


##filtrar data por rango de fechas
filterByDate = function(df,from="", to=""){
    filter_data = df %>% 
        filter(fecha >= from, fecha<= to)
    return(filter_data)
}

##filter por columna
filterByCols = function(df,col,items){
    filter_data = df %>% 
        filter(!!as.name(col) %in% items)
    return(filter_data)
}

##filter por casos
filterBetween = function(df,start,end){
    filter_data = df %>% 
        filter(valor >= start & valor <= end)
    return(filter_data)
}

server <- function(input, output, session) {
    
    #-------------------------------------------------
    #Carga del Dataset que se usara para el Dashboard
    #-------------------------------------------------
    load_dataset<- function(){
        conn <- connection()
        #obtener data inicial
        confirmed <- dbGetQuery(conn, "select province, country, lat, longitud as lon, fecha, valor from time_series_covid19_confirmed_global")
        deaths <- dbGetQuery(conn, "select province, country, lat, longitud as lon, fecha, valor from time_series_covid19_deaths_global")
        recovered <- dbGetQuery(conn, "select province, country, lat, longitud as lon, fecha, valor from time_series_covid19_recovered_global")
        
        #cerrar conexion
        dbDisconnect(conn)
        
        return(list("confirmed"=confirmed,"deaths"=deaths,"recovered"=recovered))
    }
    
    all_data<-load_dataset()
    confirmed <- all_data$confirmed
    deaths <- all_data$deaths
    recovered <- all_data$recovered
    
    #obtener dataset por opcion selecionada
    getDataSetByOption <- function(){
        if(input$option == "confirmed"){
            return(confirmed)
        }else if(input$option == "death"){
            return(deaths)
        }else{
            return(recovered)
        }
    }
    
    #render datatable
    renderDefaultTable <- function(df){
        output$tblCases <- renderDataTable({
            df
        })
    }
    
    #render title
    renderTitle <- function(){
        if(input$option == "confirmed"){
            output$case_title <- renderText({HTML("<h2>Casos confirmados</h2>")})
        }else if(input$option == "death"){
            output$case_title <- renderText({HTML("<h2>Casos de muertes</h2>")})
        }else{
            output$case_title <- renderText({HTML("<h2>Casos recuperados</h2>")})
        }
    }
    
    
    #renderrizar mapa segun opcion
    renderMap <- function(df){
        output$cases_map <- renderLeaflet({
            leaflet(df) %>% addTiles() %>% setView(lng = 12.56738, lat = 41.87194, zoom = 04) 
        })
        
        pal_confirmados <- colorFactor(
            palette = 'Spectral',
            domain = df$valor
        )
        
        leafletProxy("cases_map", data = df) %>%
            clearShapes() %>%
            addCircles(radius = ~log(valor)*8000, weight = 1, color = "#777777",
                       fillColor = ~pal_confirmados(valor), fillOpacity = 0.1, popup = ~paste(valor)
            ) %>%
            clearControls() %>%
            addLegend(position = "bottomright",
                      pal = colorNumeric('Spectral', df$valor), values = ~df$valor
            )
        
        
    }
    
    ##tablas y graficas
    renderGraphs <- function(df){
        #paises
        country_data = df %>%
            group_by(country) %>%
            summarise(total = max(valor)) %>%
            ungroup() %>%
            mutate(label_text = str_glue("Pais: {country}
                                       Casos: {total}"))
        
        output$tbl_country <- renderTable(head(country_data[1:2],5))
        country_data <- country_data[order(country_data$total,decreasing = TRUE),]
        
        top_10 = head(country_data,10)
        las_10 = tail(country_data,10)
        
        output$country_chart_min = renderPlotly({
            fig <- plot_ly() 
            fig <- fig %>%
                add_trace(
                    type = 'bar',
                    x = las_10$country,
                    y = las_10$total,
                    text = top_10$total,
                    hovertemplate = paste('<b>Casos</b>: %{y}',
                                          '<br><b>Pais</b>: %{x}<br>'),
                    showlegend = FALSE
                )
            
            fig
        })
        
        output$country_chart = renderPlotly({
            fig <- plot_ly() 
            fig <- fig %>%
                add_trace(
                    type = 'bar',
                    x = top_10$country,
                    y = top_10$total,
                    text = top_10$total,
                    hovertemplate = paste('<b>Casos</b>: %{y}',
                                          '<br><b>Pais</b>: %{x}<br>'),
                    showlegend = FALSE
                )
            
            fig
        })
        
        
        #dates
        dates_data = df %>% 
            group_by(fecha) %>% 
            summarise(total = sum(valor)) %>%
            ungroup() %>%
            mutate(label_text = str_glue("Fecha: {fecha}
                                       Casos acumulados: {total}"))
        
        output$dates_chart = renderPlotly({
            fig <- plot_ly() 
            fig <- fig %>%
                add_trace(
                    type = 'scatter',
                    mode = 'lines+markers',
                    x = dates_data$fecha,
                    y = dates_data$total,
                    text = dates_data$total,
                    hovertemplate = paste('<b>Casos acumulados</b>: %{y}',
                                          '<br><b>fecha</b>: %{x}<br>'),
                    showlegend = FALSE
                )
            
            fig
        })
        
        
        
        
    }

    
    #setear valores por default
    setDefaultValues = function(df){
        #bins<-30
        init_date = min(df$fecha)
        end_date = max(df$fecha)
        countries = unique(df$country)
        
        updateDateRangeInput(session, "date_filter",
                             start = init_date,
                             end = end_date,
                             min = init_date,
                             max = end_date
        )
        
        #updateSliderInput(session, "bins",value =bins )
        
        updatePickerInput(session, "country",
                          choices = countries,
                          selected = countries)

        min = min(df$valor)
        max = max(df$valor)

        updateSliderInput(session,'n_casos',
                          min = min, 
                          max = max,
                          value = c(min,max)
        )
        
        renderDefaultTable(df)
        
        #render init map
        if(nrow(df)>0){
            output$cases_map <- renderLeaflet({
                leaflet(df) %>% addTiles() %>% setView(lng = 12.56738, lat = 41.87194, zoom = 04)
            })

            pal_confirmados <- colorFactor(
                palette = 'Spectral',
                domain = df$valor
            )
            
            leafletProxy("cases_map", data = confirmed) %>%
                clearShapes() %>%
                addCircles(radius = ~log(valor)*8000, weight = 1, color = "#777777",
                           fillColor = ~pal_confirmados(valor), fillOpacity = 0.1, popup = ~paste(valor)
                ) %>%
                clearControls() %>%
                addLegend(position = "bottomright",
                          pal = colorNumeric('Spectral', confirmed$valor), values = ~confirmed$valor
                )

            output$case_title <- renderText({HTML("<h2>Casos confirmados</h2>")})

            updateSliderInput(session,'DatesMerge',
                              min = as.Date(init_date,"%Y-%m-%d"),
                              max = as.Date(end_date,"%Y-%m-%d"),
                              value=as.Date(init_date),
                              timeFormat="%Y-%m-%d")
        }
        
    }
    
    generalCounts <- function(){
        
        total_conf =  confirmed %>% 
                    group_by(fecha) %>% 
                    summarise(total = sum(valor))
        
        
        total_d =  deaths %>% 
            group_by(fecha) %>% 
            summarise(total = sum(valor))
        
        total_r =  recovered %>% 
            group_by(fecha) %>% 
            summarise(total = sum(valor))
        
        
        #contar total confirmados
        output$total_conf <- renderInfoBox({
            infoBox(
                "Total de confirmados", max(total_conf$total),icon = icon("check"),
                color = "blue"
            )
        })
        
        #contar total de muetos
        output$total_death <- renderInfoBox({
            infoBox(
                "Total de muertes", max(total_d$total),icon = icon("thumbs-down"),
                color = "red"
            )
            
        })
        
        #contar total de recuperados
        output$total_rec <- renderInfoBox({
            infoBox(
                "Total de recuperados", max(total_r$total),icon = icon("thumbs-up"),
                color = "green"
            )
        })
    }
    
    #inicializar informacion valores default
    setDefaultValues(confirmed)
    generalCounts()
    renderGraphs(confirmed)
    
    #Evento Reactive - Que aplicara los filtros en el Dataset
    changefilters<-reactive({
        
        df = getDataSetByOption()
        
        from = input$date_filter[1]
        to = input$date_filter[2]
        filter_values = filterByDate(df,from,to)
        
        #filter por pais
        countries = input$country
        
        filter_values = filterByCols(filter_values,"country",countries)
        
        #filtrar por total de casos
        start = input$n_casos[1]
        end = input$n_casos[2]
        
        filter_values = filterBetween(filter_values,start,end)
        
        return(filter_values)
    })
    
    
    #setear tablas por filtros
    setDataByFilters <- function(){
        df = changefilters()
        renderDefaultTable(df)
        renderMap(df)
    }
    
    #actualizar slider segun opcion
    observeEvent(input$option,{
        df = getDataSetByOption()
        
        min = min(df$valor)
        max = max(df$valor)
        
        updateSliderInput(session,'n_casos',
                          min = min, 
                          max = max,
                          value = c(min,max)
        )
        
    })
    
    ##resetar informacion
    observeEvent(input$reset,{
        setDefaultValues(confirmed)
    })
    
    ##resetar informacion
    observeEvent(input$filter,{
        df = changefilters()
        renderDefaultTable(df)
        renderMap(df)
        renderGraphs(df)
        renderTitle()
    })
    
    
    
    #renderizar mapa acumulado por fchas
    
    observeEvent(input$DatesMerge,{
        if(input$DatesMerge != "1111-11-11"){
            df = changefilters()
            min = min(df$fecha)
            max = input$DatesMerge
            
            df = filterByDate(df,min,max)
            
            country_data = df %>%
                group_by(country) %>%
                summarise(total = max(valor)) %>%
                ungroup() %>%
                mutate(label_text = str_glue("Pais: {country}
                                       Casos: {total}"))

            
            country_data$country[country_data$country == "US"] <- "USA"
            
            
            output$country_map_chart  = renderPlotly({
                country_data %>%
                    
                    plot_geo(locationmode = "country names") %>%
                    
                    add_trace(z = ~total,
                              locations = ~country,
                              color = ~total,
                              text = ~label_text,
                              marker = list(line = list(
                                  color = toRGB("black"), width = 0.8)),
                              colors = "YlGnBu",
                              hoverinfo = "text") %>%
                    
                    colorbar(title = 'Casos',
                             tickprefix = '',
                             x = 1, y = 0.8) %>% 
                    
                    return(layout(
                        showlegend = FALSE,
                        geo = list(
                            scope = "world",
                            bgcolor = toRGB("white", alpha = 0),
                            countrycolor = toRGB("gray"),
                            showcountries = TRUE,
                            showframe = FALSE,
                            showcoastlines = FALSE,
                            coastlinecolor = toRGB("#ECEFF1"),
                            projection = list(type = 'Equirectangular'))))
            })
            
        }
            
        
    })
    
}
