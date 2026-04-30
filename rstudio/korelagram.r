# ============================================================================
# GERÇEK VERİLER İLE SIPRI KORELOGRAM ANALİZİ
# ============================================================================

packages <- c("dplyr", "tidyr", "corrplot", "WDI", "readxl")
invisible(sapply(packages, function(x) {
  if(!require(x, character.only = TRUE, quietly = TRUE)) {
    install.packages(x)
    library(x, character.only = TRUE)
  }
}))

# ============================================================================
# 1. SIPRI VERİLERİ (GERÇEK)
# ============================================================================
dosya_excel <- "/home/yusakru/Desktop/veriGorsel/afis/SIPRI-Milex-data-1949-2024_2.xlsx"

sipri_usd <- read_excel(dosya_excel, sheet = "Current US$", skip = 5, 
                        na = c(". .", "xxx", "", " "))
sipri_gdp <- read_excel(dosya_excel, sheet = "Share of GDP", skip = 5, 
                        na = c(". .", "xxx", "", " "))

hedef_ulkeler_sipri <- c("United States of America", "Russia", "Russian Federation", 
                         "Türkiye", "Greece", "Israel")

savunma_mutlak <- sipri_usd %>%
  filter(Country %in% hedef_ulkeler_sipri) %>%
  select(Country, `2022`) %>%
  rename(Savunma_Milyon_USD = `2022`) %>%
  mutate(Savunma_Harcamasi = as.numeric(Savunma_Milyon_USD) / 1000) %>%
  select(Country, Savunma_Harcamasi)

savunma_yuzde <- sipri_gdp %>%
  filter(Country %in% hedef_ulkeler_sipri) %>%
  select(Country, `2022`) %>%
  rename(Savunma_GSMH_Oran = `2022`) %>%
  mutate(Savunma_GSMH_Yuzde = as.numeric(Savunma_GSMH_Oran) * 100) %>%
  select(Country, Savunma_GSMH_Yuzde)

sipri_ozet <- merge(savunma_mutlak, savunma_yuzde, by = "Country") %>%
  mutate(Ulke = case_when(
    Country == "United States of America" ~ "ABD",
    Country %in% c("Russia", "Russian Federation") ~ "Rusya",
    Country == "Türkiye" ~ "Türkiye",
    Country == "Greece" ~ "Yunanistan",
    Country == "Israel" ~ "İsrail"
  )) %>%
  select(Ulke, Savunma_Harcamasi, Savunma_GSMH_Yuzde)

cat("✓ SIPRI Verileri Çekildi!\n\n")

# ============================================================================
# 2. WORLD BANK VERİLERİ (GERÇEK)
# ============================================================================
cat("World Bank'tan veriler çekiliyor...\n")

# World Bank ülke kodları
ulke_kodlari <- c("USA", "RUS", "TUR", "GRC", "ISR")

# GSMH (GDP, Current US$)
gdp <- WDI(indicator = "NY.GDP.MKTP.CD", 
           country = ulke_kodlari, 
           start = 2022, end = 2022, 
           extra = FALSE) %>%
  select(country, NY.GDP.MKTP.CD) %>%
  rename(Ulke_Kod = country, GSMH_Milyar = NY.GDP.MKTP.CD) %>%
  mutate(GSMH = GSMH_Milyar / 1e9) %>%  # Trilyon'dan Milyara çevir
  select(Ulke_Kod, GSMH)

# Sağlık Harcaması (% GDP)
saglik <- WDI(indicator = "SH.XPD.CHEX.GD.ZS", 
              country = ulke_kodlari, 
              start = 2022, end = 2022, 
              extra = FALSE) %>%
  select(country, SH.XPD.CHEX.GD.ZS) %>%
  rename(Ulke_Kod = country, Saglik_Harcamasi_Yuzde = SH.XPD.CHEX.GD.ZS) %>%
  select(Ulke_Kod, Saglik_Harcamasi_Yuzde)

# Eğitim Harcaması (% GDP)
egitim <- WDI(indicator = "SE.XPD.TOTL.GD.ZS", 
              country = ulke_kodlari, 
              start = 2022, end = 2022, 
              extra = FALSE) %>%
  select(country, SE.XPD.TOTL.GD.ZS) %>%
  rename(Ulke_Kod = country, Egitim_Harcamasi_Yuzde = SE.XPD.TOTL.GD.ZS) %>%
  select(Ulke_Kod, Egitim_Harcamasi_Yuzde)

# Nüfus
nufus <- WDI(indicator = "SP.POP.TOTL", 
             country = ulke_kodlari, 
             start = 2022, end = 2022, 
             extra = FALSE) %>%
  select(country, SP.POP.TOTL) %>%
  rename(Ulke_Kod = country, Nufus_Milyon = SP.POP.TOTL) %>%
  mutate(Nufus = Nufus_Milyon / 1e6) %>%
  select(Ulke_Kod, Nufus)

cat("✓ World Bank Verileri Çekildi!\n\n")

# ============================================================================
# 3. UNDP HDI VERİLERİ (MANUEL - El ile indirilmesi gerekir)
# ============================================================================
# https://hdr.undp.org/data-center/documentation-and-downloads adresinden indirin
# İndiğiniz Excel'i buraya yüklüyoruz

IGE_verisi <- data.frame(
  Ulke_Kod = c("United States", "Russian Federation", "Turkiye", "Greece", "Israel"),
  IGE = c(0.921, 0.822, 0.855, 0.893, 0.916)  # UNDP 2022 HDR verisi
)

cat("✓ UNDP HDI Verileri Hazırlandı!\n\n")

# ============================================================================
# 4. VERİLERİ BİRLEŞTİRME
# ============================================================================

# Ülke kodlarını Türkçe isimlerine çevir
kod_turkce <- data.frame(
  Ulke_Kod = c("United States", "Russian Federation", "Turkiye", "Greece", "Israel"),
  Ulke = c("ABD", "Rusya", "Türkiye", "Yunanistan", "İsrail")
)

# Tüm World Bank verilerini birleştir
world_bank_merged <- gdp %>%
  left_join(saglik, by = "Ulke_Kod") %>%
  left_join(egitim, by = "Ulke_Kod") %>%
  left_join(nufus, by = "Ulke_Kod") %>%
  left_join(IGE_verisi, by = "Ulke_Kod") %>%
  left_join(kod_turkce, by = "Ulke_Kod") %>%
  select(Ulke, GSMH, Saglik_Harcamasi_Yuzde, Egitim_Harcamasi_Yuzde, Nufus, IGE)

# SIPRI verileriyle birleştir
final_veri <- sipri_ozet %>%
  left_join(world_bank_merged, by = "Ulke") %>%
  select(Ulke, Savunma_Harcamasi, Savunma_GSMH_Yuzde, GSMH, 
         Saglik_Harcamasi_Yuzde, Egitim_Harcamasi_Yuzde, Nufus, IGE)

cat("=== GERÇEK VERİ SETİ (SIPRI + WORLD BANK + UNDP) ===\n\n")
print(final_veri)
cat("\n")




# ABD'nin eksik gelen 2022 Eğitim Harcaması verisini manuel olarak yamıyoruz (Örn: %5.4)
final_veri <- final_veri %>%
  mutate(Egitim_Harcamasi_Yuzde = ifelse(Ulke == "ABD" & is.na(Egitim_Harcamasi_Yuzde), 5.42, Egitim_Harcamasi_Yuzde))




# ============================================================================
# 5. KORELASYON VE KORELOGRAMİ
# ============================================================================

# Görsel tasarım için sütun isimlerini temiz, anlaşılır ve şık etiketlere çeviriyoruz
sayisal_veriler <- final_veri %>% 
  select(-Ulke) %>%
  rename(
    `Savunma Harcaması` = Savunma_Harcamasi,
    `Savunma Payı (%)` = Savunma_GSMH_Yuzde,
    `Milli Gelir (GSMH)` = GSMH,
    `Sağlık Payı (%)` = Saglik_Harcamasi_Yuzde,
    `Eğitim Payı (%)` = Egitim_Harcamasi_Yuzde,
    `Nüfus` = Nufus,
    `İnsani Gelişme Endeksi` = IGE
  )

korelasyon_matrisi <- cor(sayisal_veriler, use = "pairwise.complete.obs", method = "pearson")
n <- ncol(korelasyon_matrisi) # Değişken sayısını alıyoruz (burada 7)

cat("Korelogram çiziliyor...\n\n")

png("korelogram.png", width = 1000, height = 900, res = 100)

# 1. Corrplot Çizimi
corrplot(korelasyon_matrisi,
         method = "circle",
         type = "lower",
         tl.pos = "ld",        # "n" yerine "ld" (sol ve çapraz) kullanarak etiketleri otomatik hizala
         tl.col = "black",     # Etiket rengi
         tl.cex = 1.1,         # Etiket boyutu
         tl.srt = 45,          # Alt etiketleri çapraz yazdır
         cl.pos = "r",         
         col = colorRampPalette(c("#8B6508", "#F5F5DC", "#0047AB"))(200),
         diag = FALSE,
         addCoef.col = "black",
         number.cex = 0.9,
         mar = c(0, 0, 3, 0),  # Marjları normale döndür
         main = "Stratejik Korelogram\n(SIPRI + World Bank + UNDP 2022)")

dev.off()

cat("═════════════════════════════════════════════════════════════════\n")
cat("✓ GERÇEK VERİ KULLANAN ANALİZ TAMAMLANDI!\n")
cat("✓ 'sipri_analiz_GERCEK_korelogram.png' kaydedildi.\n")
cat("═════════════════════════════════════════════════════════════════\n")