# Inspecter / documenter les types de variables d'une table
# retourne data.frame (variable, classe, n_distinct, n_na, exemple)
describe_schema <- function(dt) {
  dt <- data.table::as.data.table(dt)
  data.frame(
    variable   = names(dt),
    classe     = vapply(dt, function(x) class(x)[1], character(1)),
    n_distinct = vapply(dt, function(x) length(unique(x)), integer(1)),
    n_na       = vapply(dt, function(x) sum(is.na(x)), integer(1)),
    exemple    = vapply(dt, function(x) as.character(x[which(!is.na(x))[1]]), character(1)),
    row.names  = NULL
  )
}


# Vérifier la clé de jointure IDpol entre freq et sev
# retourne liste de diagnostics
check_join_keys <- function(freq, sev) {
  stopifnot("IDpol" %in% names(freq), "IDpol" %in% names(sev))
  list(
    freq_n            = nrow(freq),
    sev_n             = nrow(sev),
    freq_dup_idpol    = sum(duplicated(freq$IDpol)),         # doit être 0
    sev_idpol_unique  = length(unique(sev$IDpol)),
    sev_orphans       = sum(!unique(sev$IDpol) %in% freq$IDpol), # sinistres sans police
    freq_with_claim   = sum(freq$IDpol %in% sev$IDpol)
  )
}

# Agréger la sévérité au niveau police et joindre à la table fréquence
#
# Details
#   - somme des montants -> ClaimAmount_tot
#   - comptage des lignes sev -> ClaimNb_sev
#   - jointure LEFT sur freq (on garde toutes les polices, y compris sans sinistre)
# retourne data.table base police-niveau
build_modeling_base <- function(freq, sev) {
  freq <- data.table::as.data.table(freq)
  sev  <- data.table::as.data.table(sev)

  sev_agg <- sev[, .(
    ClaimAmount_tot = sum(ClaimAmount, na.rm = TRUE),
    ClaimNb_sev     = .N
  ), by = IDpol]

  base <- merge(freq, sev_agg, by = "IDpol", all.x = TRUE)

  # Polices sans sinistre : montant 0, nb sev 0
  base[is.na(ClaimAmount_tot), ClaimAmount_tot := 0]
  base[is.na(ClaimNb_sev),     ClaimNb_sev := 0L]

  base[]
}
