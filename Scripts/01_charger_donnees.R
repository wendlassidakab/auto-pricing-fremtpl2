# Charger le package
require(CASdatasets)

# Charger fonctions auxiliaires
source("../R/data_import.R")


# importer les données
data("freMTPL2freq")
data("freMTPL2sev")

freq <- freMTPL2freq
sev <- freMTPL2sev


# inspection des schemas
(schema_freq <- describe_schema(freq))
(schema_sev <- describe_schema(sev))


# controle de la jointure
join_diag <- check_join_keys(freq, sev)
str(join_diag)
saveRDS(join_diag, "../ouputs/tables/join_diagnostics.rds")

# jointure
base_raw <- build_modeling_base(freq, sev)
dim(base_raw)


# sauvegarder
saveRDS(base_raw, "../data/base_raw.rds")
data.table::fwrite(schema_freq, "../ouputs/tables/schema_freq.csv")
data.table::fwrite(schema_sev,  "../ouputs/tables/schema_sev.csv")
