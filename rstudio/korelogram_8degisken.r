# ============================================================================
# SIPRI + WORLD BANK: 8 DEĞİŞKENLİ PROFESYONELLEŞTİRİLMİŞ KORELOGRAM
# ----------------------------------------------------------------------------
# Değişkenler (8):
#   SIPRI → Savunma % GSYH · Savunma kişi başı (log) · Bütçeden savunma payı
#   WDI   → Sağlık % GSYH · Eğitim % GSYH · Kişi Başı GSYH (log)
#           Yaşam Beklentisi · Gini Katsayısı
# Yöntem  : Spearman rank korelasyonu + Ward.D2 hiyerarşik kümeleme
# N       : ~41 ülke (NATO + büyük askeri güçler)
# Çıktı   : korelogram_8v_tum.png    → tüm değerler görünür
#           korelogram_8v_secici.png → yalnızca p < 0.05
# ============================================================================

packages <- c("dplyr", "tidyr", "ggplot2", "readxl", "WDI", "ggcorrplot", "scales")
invisible(sapply(packages, function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}))

# ============================================================================
# 1. HEDEF ÜLKELER — SIPRI → ISO3 EŞLEŞMESİ
# ============================================================================
sipri_iso3 <- c(
  "United States of America" = "USA",  "Russia"              = "RUS",
  "Russian Federation"       = "RUS",  "Türkiye"             = "TUR",
  "Greece"                   = "GRC",  "Israel"              = "ISR",
  "Ukraine"                  = "UKR",  "Poland"              = "POL",
  "Germany"                  = "DEU",  "France"              = "FRA",
  "China"                    = "CHN",  "United Kingdom"      = "GBR",
  "Canada"                   = "CAN",  "Australia"           = "AUS",
  "India"                    = "IND",  "Japan"               = "JPN",
  "Brazil"                   = "BRA",  "Korea, South"        = "KOR",
  "Saudi Arabia"             = "SAU",  "Norway"              = "NOR",
  "Sweden"                   = "SWE",  "Denmark"             = "DNK",
  "Finland"                  = "FIN",  "Netherlands"         = "NLD",
  "Belgium"                  = "BEL",  "Spain"               = "ESP",
  "Italy"                    = "ITA",  "Romania"             = "ROU",
  "Czechia"                  = "CZE",  "Hungary"             = "HUN",
  "Bulgaria"                 = "BGR",  "Slovakia"            = "SVK",
  "Croatia"                  = "HRV",  "Estonia"             = "EST",
  "Latvia"                   = "LVA",  "Lithuania"           = "LTU",
  "Slovenia"                 = "SVN",  "Albania"             = "ALB",
  "Portugal"                 = "PRT",  "Switzerland"         = "CHE",
  "Austria"                  = "AUT",  "Singapore"           = "SGP",
  "South Africa"             = "ZAF",  "Qatar"               = "QAT",
  "United Arab Emirates"     = "ARE"
)

iso3_turkce <- c(
  "USA" = "ABD",        "RUS" = "Rusya",      "TUR" = "Türkiye",
  "GRC" = "Yunanistan", "ISR" = "İsrail",     "UKR" = "Ukrayna",
  "POL" = "Polonya",    "DEU" = "Almanya",    "FRA" = "Fransa",
  "CHN" = "Çin",        "GBR" = "İngiltere",  "CAN" = "Kanada",
  "AUS" = "Avustralya", "IND" = "Hindistan",  "JPN" = "Japonya",
  "BRA" = "Brezilya",   "KOR" = "G. Kore",    "SAU" = "S. Arabistan",
  "NOR" = "Norveç",     "SWE" = "İsveç",      "DNK" = "Danimarka",
  "FIN" = "Finlandiya", "NLD" = "Hollanda",   "BEL" = "Belçika",
  "ESP" = "İspanya",    "ITA" = "İtalya",     "ROU" = "Romanya",
  "CZE" = "Çekya",      "HUN" = "Macaristan", "BGR" = "Bulgaristan",
  "SVK" = "Slovakya",   "HRV" = "Hırvatistan","EST" = "Estonya",
  "LVA" = "Letonya",    "LTU" = "Litvanya",   "SVN" = "Slovenya",
  "ALB" = "Arnavutluk", "PRT" = "Portekiz",   "CHE" = "İsviçre",
  "AUT" = "Avusturya",  "SGP" = "Singapur",   "ZAF" = "G. Afrika",
  "QAT" = "Katar",      "ARE" = "BAE"
)

# ============================================================================
# 2. SIPRI VERİSİ — 3 SAYFA (skip değerleri doğrulanmıştır)
# ============================================================================
# Çalıştırma: RStudio'da wd = bu dosyanın bulunduğu rstudio/ klasörü olmalıdır.
dosya_excel <- file.path("..", "data", "SIPRI-Milex-data-1949-2024_2.xlsx")

cat("SIPRI verileri okunuyor...\n")

okuma <- function(sheet, skip_n) {
  read_excel(dosya_excel, sheet = sheet, skip = skip_n,
             na = c(". .", "xxx", "", "-", " ")) %>%
    select(Country, val = `2022`) %>%
    mutate(val = as.numeric(val))
}

sipri_gdp  <- okuma("Share of GDP",           5) %>% rename(Sav_GDP_ham  = val)
sipri_pc   <- okuma("Per capita",              6) %>% rename(Sav_KisiBasi = val)
sipri_gov  <- okuma("Share of Govt. spending", 7) %>% rename(Sav_Butce    = val)

sipri_ham <- Reduce(function(a, b) inner_join(a, b, by = "Country"),
                    list(sipri_gdp, sipri_pc, sipri_gov)) %>%
  filter(Country %in% names(sipri_iso3)) %>%
  mutate(iso3 = sipri_iso3[Country],
         Ulke = iso3_turkce[iso3]) %>%
  group_by(iso3, Ulke) %>%
  summarise(
    Sav_GDP_ham  = max(Sav_GDP_ham,  na.rm = TRUE),
    Sav_KisiBasi = max(Sav_KisiBasi, na.rm = TRUE),
    Sav_Butce    = max(Sav_Butce,    na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(Sav_GDP_ham) & !is.infinite(Sav_GDP_ham) &
         !is.na(Sav_KisiBasi) & !is.infinite(Sav_KisiBasi) &
         !is.na(Sav_Butce)    & !is.infinite(Sav_Butce))

cat("✓ SIPRI (3 sayfa):", nrow(sipri_ham), "ülke\n")

# ============================================================================
# 3. WORLD BANK VERİSİ — 4 GÖSTERGE (2018-2022 penceresi)
# Gini bu ülke setinde anlamsız (dar aralık, p > 0.4) → dahil edilmiyor
# ============================================================================
cat("World Bank verileri çekiliyor...\n")

wdi_raw <- WDI(
  indicator = c(
    saglik  = "SH.XPD.CHEX.GD.ZS",
    egitim  = "SE.XPD.TOTL.GD.ZS",
    gsyh_kb = "NY.GDP.PCAP.CD",
    yasam   = "SP.DYN.LE00.IN"
  ),
  country = unique(sipri_iso3),
  start   = 2018,
  end     = 2022,
  extra   = FALSE
)

# Her ülke-gösterge için en güncel mevcut yılı al
wdi_temiz <- wdi_raw %>%
  arrange(iso3c, desc(year)) %>%
  group_by(iso3c) %>%
  summarise(
    Saglik_GDP  = first(saglik[!is.na(saglik)]),
    Egitim_GDP  = first(egitim[!is.na(egitim)]),
    GSYH_KB_ham = first(gsyh_kb[!is.na(gsyh_kb)]),
    Yasam_Bek   = first(yasam[!is.na(yasam)]),
    .groups = "drop"
  ) %>%
  rename(iso3 = iso3c)

cat("✓ WDI (4 gösterge, eksiksiz):",
    nrow(wdi_temiz[complete.cases(wdi_temiz), ]), "ülke\n")

# ============================================================================
# 4. VERİLERİ BİRLEŞTİR VE LOG DÖNÜŞÜMÜ UYGULA
# ============================================================================
final_veri <- inner_join(sipri_ham, wdi_temiz, by = "iso3") %>%
  filter(complete.cases(.)) %>%
  mutate(
    # Log dönüşümleri: büyük ölçekli değişkenlerde çarpıklığı gider
    Sav_KisiBasi_log = log10(Sav_KisiBasi + 1),
    GSYH_KB_log      = log10(GSYH_KB_ham + 1)
  )

cat("✓ Birleştirilmiş N:", nrow(final_veri), "ülke\n\n")

if (nrow(final_veri) < 15) {
  stop("HATA: N < 15. WDI bağlantısını veya ülke listesini kontrol edin.")
}

# ============================================================================
# 5. KORELASYON MATRİSİ İÇİN SÜTUNLARI SEÇ
# Sıralama: Savunma grubu → Sosyal yatırım → Ekonomik çıktı
# hc.order = FALSE ile bu sıralama grafikte korunur
# ============================================================================
sayisal <- final_veri %>%
  select(
    `Savunma\n% GSYH`       = Sav_GDP_ham,
    `Savunma\nKişi Başı`    = Sav_KisiBasi_log,
    `Savunma\nBütçe Payı`   = Sav_Butce,
    `Sağlık\n% GSYH`        = Saglik_GDP,
    `Eğitim\n% GSYH`        = Egitim_GDP,
    `Kişi Başı\nGSYH (log)` = GSYH_KB_log,
    `Yaşam\nBeklentisi`     = Yasam_Bek
  )

cat("=== 7 DEĞİŞKENLİ VERİ ÖZETİ ===\n")
cat("N:", nrow(sayisal), "ülke |",
    "Değişken:", ncol(sayisal), "| Korelasyon çifti:", ncol(sayisal)*(ncol(sayisal)-1)/2, "\n\n")
print(summary(sayisal))
cat("\n")

# ============================================================================
# 6. SPEARMAN KORELASYON + P-DEĞERLERİ
# ============================================================================
kor_matrisi <- cor(sayisal, method = "spearman", use = "pairwise.complete.obs")
p_matrisi   <- cor_pmat(sayisal, method = "spearman")

cat("=== SPEARMAN KORELASYON MATRİSİ ===\n")
print(round(kor_matrisi, 2))
cat("\n=== P-DEĞERLERİ ===\n")
print(round(p_matrisi, 3))
cat("\n")

# ============================================================================
# 7. GRAFİK TEMA — ŞEFFAF ARKA PLAN
# Plot + panel + lejant zeminleri şeffaf; PNG kaydında bg = "transparent".
# Renk paleti: turuncu (negatif) → beyaz (sıfır) → mavi (pozitif)
# ============================================================================
renk_paleti <- c("#D95F02", "#FFFFFF", "#1F78B4")
ARKA_PLAN   <- NA
PANEL_ARKA  <- NA
YAZI_RENGI  <- "#1A1A1A"

tema_ortak <- function() {
  list(
    guides(
      fill = guide_colorbar(
        title          = "Spearman r",
        title.position = "top",
        title.hjust    = 0.5,
        barwidth       = unit(0.9, "cm"),
        barheight      = unit(6,   "cm"),
        title.theme    = element_text(color = YAZI_RENGI, face = "bold", size = 11),
        label.theme    = element_text(color = YAZI_RENGI, size = 10)
      )
    ),
    theme(
      plot.background   = element_rect(fill = ARKA_PLAN, color = NA),
      panel.background  = element_rect(fill = PANEL_ARKA, color = NA),
      panel.border      = element_rect(color = "grey80", fill = NA, linewidth = 0.6),
      panel.grid.major  = element_line(color = "grey92", linewidth = 0.25),
      panel.grid.minor  = element_blank(),
      axis.text.x       = element_text(color = YAZI_RENGI, size = 10, face = "bold",
                                        angle = 40, hjust = 1, vjust = 1),
      axis.text.y       = element_text(color = YAZI_RENGI, size = 10, face = "bold",
                                        hjust = 1),
      axis.ticks        = element_blank(),
      plot.title        = element_text(color = YAZI_RENGI, face = "bold", size = 17,
                                        margin = margin(b = 4)),
      plot.title.position = "plot",
      plot.subtitle     = element_text(color = scales::alpha(YAZI_RENGI, 0.58),
                                        size = 9, margin = margin(b = 14)),
      plot.caption      = element_text(color = scales::alpha(YAZI_RENGI, 0.40),
                                        size = 7.5, hjust = 0, margin = margin(t = 10)),
      plot.margin       = margin(22, 20, 14, 18),
      legend.position   = "right",
      legend.background = element_rect(fill = NA, color = NA),
      legend.key        = element_rect(fill = NA, color = NA),
      legend.title      = element_text(color = YAZI_RENGI, face = "bold", size = 11),
      legend.text       = element_text(color = YAZI_RENGI, size = 10),
      legend.margin     = margin(8, 8, 8, 8)
    )
  )
}

# ============================================================================
# 8. VERSİYON A — TÜM DEĞERLER
# Tüm hücreler renkli daire + sayı; p > 0.05 olanlar soluk ama görünür
# ============================================================================
grafik_v1 <- ggcorrplot(
  kor_matrisi,
  method      = "circle",
  type        = "lower",
  show.diag   = TRUE,
  lab         = TRUE,
  lab_size    = 3.8,
  lab_col     = "#1A1A1A",
  hc.order    = FALSE,
  colors      = renk_paleti,
  outline.col = "grey70",
  ggtheme     = theme_bw(base_size = 13)
) +
  labs(
    title    = "Savunma Harcamaları ile Sosyoekonomik Göstergeler",
    subtitle = paste0(
      "Spearman Sıra Korelasyonu  ·  N = ", nrow(final_veri),
      " Ülke (NATO + Büyük Askeri Güçler)\n",
      "SIPRI 2022 + World Bank 2018–2022  ·  Tüm değerler gösterildi (p > 0.05 dahil)"
    ),
    caption = "Kaynak: SIPRI Military Expenditure Database & World Bank Open Data"
  ) +
  tema_ortak()

# ============================================================================
# 9. VERSİYON B — YALNIZCA ANLAMLI DEĞERLER (p < 0.05)
# ============================================================================
grafik_v2 <- ggcorrplot(
  kor_matrisi,
  method      = "circle",
  type        = "lower",
  show.diag   = TRUE,
  lab         = TRUE,
  lab_size    = 3.8,
  lab_col     = "#1A1A1A",
  p.mat       = p_matrisi,
  sig.level   = 0.05,
  insig       = "blank",
  hc.order    = FALSE,
  colors      = renk_paleti,
  outline.col = "grey70",
  ggtheme     = theme_bw(base_size = 13)
) +
  labs(
    title    = "Savunma Harcamaları ile Sosyoekonomik Göstergeler",
    subtitle = paste0(
      "Spearman Sıra Korelasyonu  ·  N = ", nrow(final_veri),
      " Ülke (NATO + Büyük Askeri Güçler)\n",
      "SIPRI 2022 + World Bank 2018–2022  ·  Yalnızca p < 0.05 gösterildi"
    ),
    caption = "Kaynak: SIPRI Military Expenditure Database & World Bank Open Data"
  ) +
  tema_ortak()

# ============================================================================
# 10. PNG KAYDET
# ============================================================================
kaydet <- function(g, dosya, w = 1600, h = 1350) {
  png(dosya, width = w, height = h, res = 150, bg = "transparent")
  print(g)
  dev.off()
  cat("✓ Kaydedildi:", dosya, "\n")
}

cikti_klasor <- file.path("..", "assets", "images", "charts")
dir.create(cikti_klasor, recursive = TRUE, showWarnings = FALSE)
kaydet(grafik_v1, file.path(cikti_klasor, "korelogram_8v_tum.png"))
kaydet(grafik_v2, file.path(cikti_klasor, "korelogram_8v_secici.png"))

cat("═══════════════════════════════════════════════════════════════\n")
cat("✓ 7 DEĞİŞKENLİ KORELOGRAM TAMAMLANDI\n")
  cat("  assets/images/charts/korelogram_8v_tum.png     → tüm hücre değerleri\n")
  cat("  assets/images/charts/korelogram_8v_secici.png  → yalnızca p < 0.05\n")
cat("✓ N:", nrow(final_veri), "ülke  |  21 korelasyon çifti\n")
cat("═══════════════════════════════════════════════════════════════\n")
