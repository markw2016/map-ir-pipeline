#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_raw
#' @return
#' @author njtierney
#' @export
prepare_geno_data <- function(moyes_geno_raw, moyes_geno_countries) {
  # add the country information
  countries <- moyes_geno_countries %>%
    select(
      country = country_name
    )

  moyes_geno_raw %>%
    bind_cols(
      countries,
    ) %>%
    # make this id after the data have been combined
    select(
      country,
      start_month,
      start_year,
      end_month,
      end_year,
      latitude,
      longitude,
      # species - filter down to "gambaie complex" in complex_subgroup
      no_mosquitoes_tested,
      # percent mortality? - instead we are using: l1014l_percent
      # this is not actually the percent dead mosquitoes, it is the number of
      # dead mosquitoes with the gene marker,
      # since percent_mortality is l1014l_percent, which is a gene marker
      # of those dead mosquitoes.
      percent_mortality = l1014l_percent,
      complex_subgroup
      # no information on insecticide
    ) %>%
    # just keep Gambiae
    filter(
      complex_subgroup == "Gambiae Complex"
    ) %>%
    select(
      -complex_subgroup
    ) %>%
    mutate(
      no_mosquitoes_dead = no_mosquitoes_tested * (percent_mortality / 100),
      insecticide = "none"
    ) %>%
    relocate(
      country,
      start_month,
      start_year,
      end_month,
      end_year,
      latitude,
      longitude,
      no_mosquitoes_tested,
      no_mosquitoes_dead,
      percent_mortality,
      insecticide
    ) %>%
    mutate(
      # this introduces NA values for "NR" values, which are "not recorded" and
      # the same as missing values
      start_year = as.integer(start_year)
    ) %>%
    mutate(
      across(
        c(
          latitude,
          longitude
        ),
        as.numeric
      )
    )
}
