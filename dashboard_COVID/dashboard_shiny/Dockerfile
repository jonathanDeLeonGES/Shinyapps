FROM rocker/shiny:latest

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libmysqlclient-dev \
  libxml2

RUN R -e "install.packages(c('RMySQL','dplyr','shinydashboard','leaflet','RColorBrewer','tidyverse','ggplot2','plotly','lubridate','shinyWidgets'))"