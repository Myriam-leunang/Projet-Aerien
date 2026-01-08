# =====================================================
# PROJETR – SHINY WEB APP (MySQL)
# Mission 3 : WebApp + reporting (flights + weather)
# =====================================================

library(shiny)
library(DBI)
library(RMySQL)
library(ggplot2)
library(dplyr)

# -----------------------------
# Connexion MySQL (XAMPP)
# -----------------------------
con <- dbConnect(
  RMySQL::MySQL(),
  dbname = "ProjetR",
  host = "127.0.0.1",
  user = "root",
  password = "",
  port = 3306
)

# -----------------------------
# UI
# -----------------------------
ui <- fluidPage(
  titlePanel("✈️ ProjetR – Dashboard Trafic Aérien (NYC 2013)"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Filtres (sur flights)"),
      
      selectInput(
        "origin",
        "Aéroport de départ (origin)",
        choices = c("Tous", "EWR", "JFK", "LGA"),
        selected = "Tous"
      ),
      
      sliderInput(
        "month",
        "Mois",
        min = 1, max = 12,
        value = c(1, 12),
        step = 1
      ),
      
      checkboxInput("only_delayed", "Afficher uniquement les vols en retard (dep_delay > 0)", FALSE),
      
      tags$hr(),
      helpText("Astuce : si un onglet ne s'affiche pas, vérifie que flights est bien importée.")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("📊 Top compagnies (vols)",
                 plotOutput("plot_top_carriers", height = 320)
        ),
        tabPanel("🌍 Top destinations",
                 plotOutput("plot_top_dest", height = 320)
        ),
        tabPanel("⏱️ Retards",
                 plotOutput("plot_delay", height = 320)
        ),
        tabPanel("🌦️ Météo vs retard (EWR/JFK/LGA)",
                 plotOutput("plot_weather_delay", height = 320),
                 helpText("Corrélation simple : retard moyen vs vent moyen par aéroport (sur période filtrée).")
        ),
        tabPanel("📋 Tableau (résumé)",
                 tableOutput("table_summary")
        )
      )
    )
  )
)

# -----------------------------
# Server
# -----------------------------
server <- function(input, output) {
  
  # ---- Construire WHERE dynamique ----
  flights_where <- reactive({
    wh <- c(
      sprintf("month BETWEEN %d AND %d", input$month[1], input$month[2])
    )
    
    if (input$origin != "Tous") {
      wh <- c(wh, sprintf("origin = '%s'", input$origin))
    }
    
    if (isTRUE(input$only_delayed)) {
      wh <- c(wh, "dep_delay > 0")
    }
    
    paste(wh, collapse = " AND ")
  })
  
  # ---- 1) Top carriers ----
  output$plot_top_carriers <- renderPlot({
    df <- dbGetQuery(con, paste0("
      SELECT f.carrier, COALESCE(a.name, f.carrier) AS carrier_name, COUNT(*) AS nb_vols
      FROM flights f
      LEFT JOIN airlines a ON a.carrier = f.carrier
      WHERE ", flights_where(), "
      GROUP BY f.carrier, carrier_name
      ORDER BY nb_vols DESC
      LIMIT 10
    "))
    
    ggplot(df, aes(x = reorder(carrier_name, nb_vols), y = nb_vols)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(title = "Top 10 compagnies par nombre de vols",
           x = "Compagnie", y = "Nombre de vols")
  })
  
  # ---- 2) Top destinations ----
  output$plot_top_dest <- renderPlot({
    df <- dbGetQuery(con, paste0("
      SELECT f.dest, COALESCE(ap.name, f.dest) AS dest_name, COUNT(*) AS nb_vols
      FROM flights f
      LEFT JOIN airports ap ON ap.faa = f.dest
      WHERE ", flights_where(), "
      GROUP BY f.dest, dest_name
      ORDER BY nb_vols DESC
      LIMIT 10
    "))
    
    ggplot(df, aes(x = reorder(dest, nb_vols), y = nb_vols)) +
      geom_col(fill = "darkgreen") +
      coord_flip() +
      labs(title = "Top 10 destinations (nombre de vols)",
           x = "Destination", y = "Nombre de vols")
  })
  
  # ---- 3) Retards : retard moyen par compagnie (top 10) ----
  output$plot_delay <- renderPlot({
    df <- dbGetQuery(con, paste0("
      SELECT f.carrier, COALESCE(a.name, f.carrier) AS carrier_name,
             AVG(f.dep_delay) AS dep_delay_moyen
      FROM flights f
      LEFT JOIN airlines a ON a.carrier = f.carrier
      WHERE ", flights_where(), " AND f.dep_delay IS NOT NULL
      GROUP BY f.carrier, carrier_name
      ORDER BY dep_delay_moyen DESC
      LIMIT 10
    "))
    
    ggplot(df, aes(x = reorder(carrier_name, dep_delay_moyen), y = dep_delay_moyen)) +
      geom_col(fill = "orange") +
      coord_flip() +
      labs(title = "Top 10 compagnies par retard moyen au départ",
           x = "Compagnie", y = "Retard moyen (minutes)")
  })
  
  # ---- 4) Météo vs retards : vent moyen & retard moyen par aéroport ----
  output$plot_weather_delay <- renderPlot({
    # Retard moyen par origin (filtré)
    df_delay <- dbGetQuery(con, paste0("
      SELECT origin, AVG(dep_delay) AS dep_delay_moyen
      FROM flights
      WHERE ", flights_where(), " AND dep_delay IS NOT NULL
      GROUP BY origin
    "))
    
    # Vent moyen par origin (mêmes mois filtrés)
    df_wind <- dbGetQuery(con, paste0("
      SELECT origin, AVG(wind_speed) AS wind_speed_moyen
      FROM weather
      WHERE month BETWEEN ", input$month[1], " AND ", input$month[2], "
      GROUP BY origin
    "))
    
    df <- df_delay %>%
      inner_join(df_wind, by = "origin")
    
    ggplot(df, aes(x = wind_speed_moyen, y = dep_delay_moyen)) +
      geom_point(size = 3) +
      geom_text(aes(label = origin), vjust = -0.8) +
      labs(title = "Vent moyen vs retard moyen (par aéroport)",
           x = "Vent moyen", y = "Retard moyen au départ (minutes)")
  })
  
  # ---- 5) Tableau résumé ----
  output$table_summary <- renderTable({
    dbGetQuery(con, paste0("
      SELECT
        COUNT(*) AS total_vols,
        ROUND(AVG(dep_delay), 2) AS dep_delay_moyen,
        ROUND(AVG(arr_delay), 2) AS arr_delay_moyen,
        COUNT(DISTINCT carrier) AS nb_compagnies,
        COUNT(DISTINCT dest) AS nb_destinations
      FROM flights
      WHERE ", flights_where(), "
    "))
  })
}

shinyApp(ui = ui, server = server)
