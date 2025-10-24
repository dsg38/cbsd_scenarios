full_df_filepath = "../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.csv"

full_df = read.csv(full_df_filepath)

cdp_country_codes = c(
    "UGA",
    "MOZ",
    "ZMB",
    "RWA",
    "MWI",
    "KEN",
    "TZA"
)

cdp_df = full_df[full_df$country_code %in% cdp_country_codes,]

write.csv(cdp_df, "./cc_paper_data_subset/cassava_data_minimal.csv", row.names = FALSE)