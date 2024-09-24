#extra code

# # # Set up color palette
# # pal <- colorNumeric(palette = "YlOrRd", domain = stategeojson@data$total_lbs)
# # 
# # leaflet(stategeojson) %>%
# #   addProviderTiles(providers$CartoDB.Positron) %>%
# #   addPolygons(
# #     fillColor = ~pal(total_lbs),
# #     color = "#BDBDC3",
# #     weight = 1,
# #     fillOpacity = 0.7,
# #     label = ~paste0(name, ": ", total_lbs, " lbs"),
# #     highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)
# #   ) %>%
# #   addLegend(pal = pal, values = ~total_lbs, opacity = 0.7, title = "Total Fentanyl Seizures (lbs)", position = "bottomright")
# 
# observeEvent(input$update, {
#   # Convert the sidebar inputs into date objects
#   start_date <- as.Date(paste0(input$start_year, "-", match(input$start_month, month.abb), "-01"))
#   end_date <- as.Date(paste0(input$end_year, "-", match(input$end_month, month.abb), "-01"))
# 
#   # Filter the data based on the selected date range
#   filtered_data <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date)
#   
#   # Summarize the data by state based on the filtered data
#   fent_by_state_filtered <- filtered_data %>%
#     group_by(state) %>%
#     summarise(total_lbs = sum(sum_qty_lbs, na.rm = TRUE))
#   
#   # Merge filtered fentanyl data with geojson data
#   stategeojson@data <- left_join(stategeojson@data, fent_by_state_filtered, by = c("name" = "state"))
#   
#   # Set up color palette
#   pal <- colorNumeric(palette = "YlOrRd", domain = stategeojson@data$total_lbs)
#   
#   # Re-render the leaflet map
#   leafletProxy("seizure_map") %>%
#     clearShapes() %>%
#     addPolygons(
#       fillColor = ~pal(total_lbs),
#       color = "#BDBDC3",
#       weight = 1,
#       fillOpacity = 0.7,
#       label = ~paste0(name, ": ", total_lbs, " lbs"),
#       highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)
#     ) %>%
#     addLegend(pal = pal, values = ~total_lbs, opacity = 0.7, title = "Total Fentanyl Seizures (lbs)", position = "bottomright")
# })

# leafletOutput("seizure_map", width = "100%", height = "600px")
# 
# # Render leaflet map reactively
# observeEvent(input$update, {
#   
#   # Create start and end dates from the inputs
#   start_date <- as.Date(paste0(input$start_year, "-", match(input$start_month, month.abb), "-01"))
#   end_date <- as.Date(paste0(input$end_year, "-", match(input$end_month, month.abb), "-01"))
# 
#   # Filter the data based on the selected date range
#   filtered_data <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date)
#   
#   # Summarize the data by state based on the filtered data
#   fent_by_state_filtered <- filtered_data %>%
#     group_by(state) %>%
#     summarise(total_lbs = sum(sum_qty_lbs, na.rm = TRUE))
#   
#   # Merge filtered fentanyl data with geojson data
#   stategeojson@data <- left_join(stategeojson@data, fent_by_state_filtered, by = c("name" = "state"))
#   
#    # Replace NA values with 0 for states with no data
#   stategeojson@data$total_spending[is.na(stategeojson@data$total_spending)] <- 0
#   
#   # Set up color palette
#   pal <- colorNumeric(palette = "YlOrRd", domain = stategeojson@data$total_lbs)
#   
#   # Create the leaflet map
#   leaflet(stategeojson) %>%
#     addProviderTiles(providers$CartoDB.Positron) %>%
#     addPolygons(
#       fillColor = ~pal(total_lbs),
#       color = "#BDBDC3",
#       weight = 1,
#       fillOpacity = 0.7,
#       label = ~paste0(name, ": ", total_lbs, " lbs"),
#       highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)
#     ) %>%
#     addLegend(pal = pal, values = ~total_lbs, opacity = 0.7, title = "Total Fentanyl Seizures (lbs)", position = "bottomright")
# })
# 
# output$seizure_map <- renderLeaflet({
#   leaflet(stategeojson) %>%
#     addProviderTiles("CartoDB.Positron") %>%
#     setView(lng = -96, lat = 37.8, zoom = 3.5) # Adjusted zoom level
# })


# # Initialize the leaflet map (this renders the map at the start)
# leafletOutput("seizure_map", width = "100%", height = "600px")
# 
# # Render leaflet map reactively
# observeEvent(input$update, {
#   
#   # Create start and end dates from the inputs
#   start_date <- as.Date(paste0(input$start_year, "-", match(input$start_month, month.abb), "-01"))
#   end_date <- as.Date(paste0(input$end_year, "-", match(input$end_month, month.abb), "-01"))
#   # 
#   # start_date <- as.Date("2022/01/01")
#   # end_date <- as.Date("2022/12/01")
# 
#   # Filter the data based on the selected date range
#   filtered_data <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date)
#   
#   # Summarize the data by state based on the filtered data
#   fent_by_state_filtered <- filtered_data %>%
#     group_by(state) %>%
#     summarise(total_lbs = sum(sum_qty_lbs, na.rm = TRUE))
#   
#   # Merge filtered fentanyl data with geojson data
#   stategeojson@data <- left_join(stategeojson@data, fent_by_state_filtered, by = c("name" = "state"))
#   
#   # Replace NA values with 0 for states with no data
#   stategeojson@data$total_lbs[is.na(stategeojson@data$total_lbs)] <- 0
#   
#   # Set up color palette
#   pal <- colorNumeric(palette = "YlOrRd", domain = stategeojson@data$total_lbs)
#   
#   # Create the leaflet map
#   leaflet(stategeojson) %>%
#     addProviderTiles(providers$CartoDB.Positron) %>%
#     addPolygons(
#       fillColor = ~pal(total_lbs),
#       color = "#BDBDC3",
#       weight = 1,
#       fillOpacity = 0.7,
#       label = ~paste0(name, ": ", total_lbs, " lbs"),
#       highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)
#     ) %>%
#     addLegend(pal = pal, values = ~total_lbs, opacity = 0.7, title = "Total Fentanyl Seizures (lbs)", position = "bottomright")
# })
# 
# output$seizure_map <- renderLeaflet({
#   leaflet(stategeojson) %>%
#     addProviderTiles("CartoDB.Positron") %>%
#     setView(lng = -96, lat = 37.8, zoom = 3.5) # Adjusted zoom level
# })


# # Render leaflet map reactively
# output$seizure_map <- renderLeaflet({
# 
#   # Initialize with an empty map
#   leaflet() %>%
#     addProviderTiles(providers$CartoDB.Positron) %>%
#     setView(lng = -96, lat = 37.8, zoom = 3.5) # Adjusted zoom level






# chosen_state <- reactiveVal(NULL)
# 
# observeEvent(input$seizure_map_shape_click, {
#   clicked_state <- input$seizure_map_shape_click$id
#   chosen_state(clicked_state)
# })
# 
# output$a <- renderPlotly({
#   req(chosen_state())
#   req(input$update)
#   
#   state_name <- chosen_state()
#   
#   # state_name <- "California"
# 
#   
#   start_date <- as.Date(paste(input$start_year, match(input$start_month, month.abb), "1", sep = "-"))
#   end_date <- as.Date(paste(input$end_year, match(input$end_month, month.abb), "1", sep = "-"))
#   
#   # min_date <- as.Date("2022/01/01")
#   # max_date <- as.Date("2024/12/01")
#   
#   # Filter the data based on the selected date range and state
#   filtered_data1 <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date & state == state_name) %>%
#     group_by(area_of_responsibility, date) %>%
#     summarise(total_seizure = sum(sum_qty_lbs, na.rm = TRUE)) %>%
#     ungroup()
#   
#   
#   gg1 <- ggplot(filtered_data1, aes(x = date, y = round(total_seizure, 0), color = area_of_responsibility, 
#                                     group = area_of_responsibility, text = paste("Date: ", date, "<br>Total Fentanyl Seizure (lbs): ", total_seizure))) +
#     geom_line() +
#     geom_point() +
#     labs(title = paste("Fentanyl Seizure by Office in", state_name),
#          x = "Date",
#          y = "Total Seizure",
#          color = "Office") +
#     theme_minimal()
#   
#   ggplotly(gg1, tooltip = "text")
#   
# })
# 
# # Output the plotly chart
# plotlyOutput("a", width = "80%", height = "310px")



# ```{r}
# 
# chosen_state <- reactiveVal(NULL)
# 
# observeEvent(input$seizure_map_shape_click, {
#   clicked_state <- input$seizure_map_shape_click$id
#   chosen_state(clicked_state)
# })
# 
# output$a <- renderPlotly({
#   req(chosen_state)
#   req(input$update)
#   
#   state_name <- chosen_state()
#   
#   state <- tolower(gsub(" ", "_", state_name))
#   
#   start_date <- as.Date(paste(input$start_year, match(input$start_month, months), "1", sep = "-"))
#   end_date <- as.Date(paste(input$end_year, match(input$end_month, months), "1", sep = "-"))
#   
#   casefold(fent_w_states$area_of_responsibility)
#   
#   # Filter the data based on the selected date range
#   filtered_data1 <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date) %>%
#     group_by(area_of_responsibility) %>%
#     summarise(total_seizure = sum(!!sym(state), na.rm = TRUE)) %>%
#     ungroup()
#   
#   gg1 <- ggplot(filtered_data1, aes(x = date, y = round(total_seizure, 0), color = area_of_responsibility, 
#                                     group = area_of_responsibility, text = paste("Date: ", date, "<br>Total Fentanyl Seizure (lbs): "))) +
#     geom_line() +
#     geom_point() +
#     labs(title = paste("Fentanyl Seizure by Office in", state_name),
#          x = "Date",
#          y = "Total Seizure",
#          color = "Office") +
#     theme_minimal()
#   
#   ggplotly(gg1, tooltip = "text")
#   
# })
# 
# 
# plotlyOutput(a, width = "80%", height = "310px")
# 
# ``

# })




#   # Use leafletProxy to update the existing map
#   leafletProxy("seizure_map", data = stategeojson) %>%
#     clearShapes() %>%  # Clear any previous polygons
#     clearControls() %>%
#     addPolygons(
#       fillColor = ~pal(total_lbs),
#       color = "#BDBDC3",
#       weight = 1,
#       fillOpacity = 0.7,
#       label = ~paste0(name, ": ", total_lbs, " lbs"),
#       highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)
#     ) %>%
#     addLegend(pal = pal, values = ~total_lbs, opacity = 0.7, title = "Total Fentanyl Seizures (lbs)", position = "bottomright")
# })




#   gg2 <- ggplot(filtered_data2, aes(x = area_of_responsibility, y = round(total_seizure, 0), color = area_of_responsibility, 
#                                   group = area_of_responsibility, text = paste("Date: ", date, "<br>Total Fentanyl Seizure (lbs): ", total_seizure))) +
#     geom_col() +
#     scale_fill_distiller(palette = "YlOrRd", direction = 1) +
#     coord_flip() +
#   labs(title = paste("Fentanyl Seizure by Office in", str_to_title(state_name)),
#        x = "Authority",
#        y = "Total Seizure",
#        color = "Office") +
#   theme_minimal()
# 
# ggplotly(gg2, tooltip = "text")





# selected_state <- reactiveVal(NULL)
# 
# observeEvent(input$seizure_map_shape_click, {
#   clicked_state <- input$spending_map_shape_click$id
#   selected_state(clicked_state)
# })
# 
# output$b <- renderPlotly({
#   req(selected_state())
#   req(input$update)
# 
#   state_name <- selected_state()
#   
#   # state_name <- "arizona"
#   # start_date <- as.Date("2023/01/01")
#   # end_date <- as.Date("2023/12/01")
#   
#   start_date <- as.Date(paste(input$start_year, match(input$start_month, month.abb), "1", sep = "-"))
#   end_date <- as.Date(paste(input$end_year, match(input$end_month, month.abb), "1", sep = "-"))
#   
#   state_name <- tolower(state_name)
#   
#   fent_w_states <- fent_w_states %>%
#     mutate(state = tolower(state))
#   
#   # Filter the data based on the selected date range and state
#   filtered_data2 <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date & state == state_name) %>%
#     group_by(area_of_responsibility) %>%
#     summarise(total_seizure = sum(sum_qty_lbs, na.rm = TRUE)) %>%
#     ungroup()
#   
#   filtered_data2$tooltip_text <- paste("Authority: ", filtered_data2$area_of_responsibility, 
#                                      "<br>Total Fentanyl Seizure (lbs): ", 
#                                      round(filtered_data2$total_seizure, 0))
#   
#   gg2 <- ggplot(filtered_data2, aes(x = reorder(area_of_responsibility, total_seizure), 
#                                   y = round(total_seizure, 0), 
#                                   fill = area_of_responsibility, 
#                                   group = area_of_responsibility, 
#                                   text = tooltip_text)) +
#     geom_col() +
#     coord_flip() +
#     labs(title = paste("Fentanyl Seizure by Office in", str_to_title(state_name)),
#          x = "Authority",
#          y = "Total Seizure",
#          color = "Office") +
#     theme_minimal()
#   
#   ggplotly(gg2, tooltip = "text")
# })
# 
# # Output the plotly chart
# plotlyOutput("b", width = "80%", height = "310px")


# # Create the map using leafletProxy
# leafletProxy("seizure_map", data = stategeojson) %>%
#   clearShapes() %>%
#   clearControls() %>%
#   addProviderTiles(providers$CartoDB.Positron) %>%
#   addPolygons(
#     fillColor = ~pal(total_lbs),  # Color is still based on log-transformed values
#     color = "#BDBDC3",
#     weight = 1,
#     fillOpacity = 0.7,
#     label = ~paste0(name, ": ", total_lbs, " lbs"),
#     layerId = ~name,
#     highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)) %>%
#   addLegend(pal = pal, values = ~total_lbs, bins = bins, opacity = 0.7,
#             title = "Total Fentanyl Seizures (lbs)", position = "bottomright")

# leafletProxy("seizure_map", data = stategeojson) %>%
# clearShapes() %>%
# clearControls() %>%
# addProviderTiles(providers$CartoDB.Positron) %>%
# addPolygons(
#   fillColor = ~pal(total_lbs),  # Color based on the log-transformed values
#   color = "#BDBDC3",
#   weight = 1,
#   fillOpacity = 0.7,
#   # Use round() to round total_lbs to the nearest whole number
#   label = ~paste0(name, ": ", round(total_lbs), " lbs"),
#   layerId = ~name,
#   highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)) %>%
# addLegend(pal = pal, values = ~total_lbs, bins = bins, opacity = 0.7,
#           title = "Total Fentanyl Seizures (lbs)", position = "bottomright")



# observeEvent(input$update, {
#   
#   start_date <- as.Date(paste(input$start_year, match(input$start_month, months), "1", sep = "-"))
#   end_date <- as.Date(paste(input$end_year, match(input$end_month, months), "1", sep = "-"))
#   
#   # Filter the data based on the selected date range
#   filtered_data <- fent_w_states %>%
#     filter(date >= start_date & date <= end_date)
#   
#   # Summarize the data by state based on the filtered data
#   fent_by_state_filtered <- filtered_data %>%
#     group_by(state) %>%
#     summarise(total_lbs = sum(sum_qty_lbs, na.rm = TRUE))
#   
#   # Clean state names in GeoJSON data and filtered data for consistency
#   stategeojson@data$name <- tolower(trimws(stategeojson@data$name))
#   fent_by_state_filtered$state <- tolower(trimws(fent_by_state_filtered$state))
#   
#   # Remove any existing total_lbs column in stategeojson@data to avoid conflicts during the join
#   stategeojson@data$total_lbs <- NULL
#   
#   # Merge filtered fentanyl data with geojson data
#   stategeojson@data <- left_join(stategeojson@data, fent_by_state_filtered, by = c("name" = "state"))
# 
#   # Replace NA values in total_lbs with 0 for states with no data
#   stategeojson@data$total_lbs[is.na(stategeojson@data$total_lbs)] <- 0
#   
#   # Set up color palette
#   pal <- colorNumeric(palette = "YlOrRd", domain = stategeojson@data$total_lbs)
# 
# leafletProxy("seizure_map", data = stategeojson) %>%
#     clearShapes() %>%  # Clear any previous polygons
#     clearControls() %>%
#   addProviderTiles(providers$CartoDB.Positron) %>%
#   addPolygons(
#     fillColor = ~pal(total_lbs),
#     color = "#BDBDC3",
#     weight = 1,
#     fillOpacity = 0.7,
#     label = ~paste0(name, ": ", total_lbs, " lbs"),
#     layerId = ~name,  # Set the state name as the layerId for each polygon
#     highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.7, bringToFront = TRUE)) %>%
#   addLegend(pal = pal, values = ~total_lbs, opacity = 0.7, title = "Total Fentanyl Seizures (lbs)", position = "bottomright")
# 
# })
# 
# 
# output$seizure_map <- renderLeaflet({
#   leaflet(stategeojson) %>%
#     addProviderTiles("CartoDB.Positron") %>%
#     setView(lng = -96, lat = 37.8, zoom = 3.5) # Adjusted zoom level



# The third tab contains 
# 
# I downloaded all of the political advertisements mentioning the word "fentanyl" from the Meta Ads Libary which contains ads run on Meta platforms (Facebook, Instagram, etc.). Then I created a topic model  
# 
# # })