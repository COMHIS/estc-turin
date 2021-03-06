

get_api2_query <- function(term = "religion",
                           api_url = "https://vm0175.kaj.pouta.csc.fi/ecco-search2/jsearch?query=",
                           api_return_fields = "&field=ESTCID",
                           level = "paragraph") {
  api2_params <- "&limit=2147483647"
  api2_level <- paste0("&level=", level)
  api2_query <- paste0(api_url, term, api_return_fields, api2_params, api2_level)
  api2_query <- fix_query_chars(api2_query)
  return(api2_query)
}


get_api2_query_set <- function(base_term, comparable_terms, query_level) {
  if (base_term == "") {
    base_set <- list(term = "", query = NA)
    base_q <- ""
  } else {
    base_set <- list(term = base_term, query = get_api2_query(term = base_term, level = query_level))
    base_q <- paste0("+", base_term)
  }
  
  comparable_query_sets <-  vector("list", length(comparable_terms))
  i <- 1
  for (comparable_term in comparable_terms) {
    query_term <- paste0(base_q, " +(", comparable_term, ")")
    comparable_set <-
      list(term = comparable_term, query = get_api2_query(term = query_term, level = query_level))
    comparable_query_sets[[i]] <- comparable_set
    i <- i + 1
  }
  api2_query_set <- list(base_query_set = base_set,
                         comparable_query_sets = comparable_query_sets)
  return(api2_query_set)
}


format_api2_jsearch_query_results <- function(jsearch_query_results, format_freq = TRUE) {
  if (format_freq) {
    jsearch_query_results$freq <- as.numeric(jsearch_query_results$freq)
  }
  jsearch_query_results$id <- gsub("\\,$", "", as.character(jsearch_query_results$id))
  # Takes first character of id, removes zeroes from start of numeric part,
  # adds first char back again.
  jsearch_query_results$id <- apply(cbind(substr(jsearch_query_results$id, 1, 1),
                                          gsub("^[A-Z]0*", "", jsearch_query_results$id)),
                                    1, function(x) {paste(x, collapse = "")})
  formatted_ids <- jsearch_query_results
  return(formatted_ids)
}


get_api2_jsearch_query_results_df <- function(query_url, column_names = NA) {
  # returns df with optional column names
  results <- jsonlite::fromJSON(query_url, flatten = TRUE)$results
  results_df <- data.frame(results)
  if (!all(is.na(column_names))) {
    names(results_df) <- column_names
  }
  return(results_df)
}

get_api2_query_counts <- function(query_results_df) {
  names(query_results_df) <- c("estcid", "count")
  query_results_df$count <- as.numeric(query_results_df$count)
  results_df_summary <- plyr::count(query_results_df, vars = c("estcid"))
  names(results_df_summary) <- c("id", "freq")
  results_df_summary <- format_api2_jsearch_query_results(results_df_summary)
  return(results_df_summary)
}


api2_query_verify_sanity <- function(api2_search_terms) {
  if (nchar(api2_search_terms) > 6) {
    return(TRUE)
  }
  return(FALSE)
}


format_api2_ids <- function(df_with_ids, id_field = "id") {
  if (id_field != "id") {
    df_with_ids$id <- df_with_ids[, id_field]
  }
  df_with_ids
  
  df_with_ids$id <- gsub("\\,$", "", as.character(df_with_ids$id))
  # Takes first character of id, removes zeroes from start of numeric part,
  # adds first char back again.
  df_with_ids$id <- apply(cbind(substr(df_with_ids$id, 1, 1),
                                          gsub("^[A-Z]0*", "", df_with_ids$id)),
                                    1, function(x) {paste(x, collapse = "")})
  formatted_ids <- df_with_ids
  return(formatted_ids)
}


# get_api2_collocations <- function(term, 
#                                   params = "&sumScaling=DF&minSumFreq=100&limit=50&localScaling=FLAT") {
#   api_call_start <- "https://vm0175.kaj.pouta.csc.fi/ecco-search2/collocations"
#   term_part <- paste0("?term=", term)
#   params <- params
#     # https://vm0175.kaj.pouta.csc.fi/ecco-search2/collocations?term=consciousness&sumScaling=DF&minSumFreq=100&limit=50&pretty&localScaling=FLAT
# }


