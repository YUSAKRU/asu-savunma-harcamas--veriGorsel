# Korelogram Sunum Rehberi
## "Savunma Harcamaları ile Sosyoekonomik Göstergeler"

> Bu belge, grafiği sunarken karşılaşabileceğin soruları ve hazır cevapları içermektedir.
> Teknik detaylar, metodolojik gerekçeler ve olası itirazlara karşı argümanlar bir arada sunulmaktadır.

---

## 1. Grafiği Tek Cümleyle Anlat

> **"40 ülkede savunma harcama alışkanlıklarının sağlık, eğitim ve yaşam kalitesi göstergeleriyle
> istatistiksel olarak anlamlı bir ilişki taşıyıp taşımadığını Spearman korelasyon yöntemiyle test ettik."**

---

## 2. Veri Kaynakları

| Kaynak | Ne Sağlıyor | Yıl |
|--------|-------------|-----|
| **SIPRI Military Expenditure Database** | 3 savunma göstergesi | 2022 |
| **World Bank Open Data (WDI)** | 4 sosyoekonomik gösterge | 2018–2022 (en güncel) |

### Neden 2018–2022 penceresi kullanıldı?
Dünya Bankası verileri her ülke için her yıl eksiksiz değil. Tek bir yıl alınsaydı N (ülke sayısı)
dramatik biçimde düşerdi. Bu nedenle 2018–2022 arasında her ülke için **en güncel mevcut yıl** seçildi.
Sonuç: N = **40 ülke** ile istatistiksel olarak anlamlı bir örneklem elde edildi.

---

## 3. Değişkenler — Neden Bu 7?

### 3.1 Savunma Grubu (SIPRI — 3 Değişken)

| Değişken | Tanım | Neden Dahil Edildi |
|----------|-------|--------------------|
| **Savunma % GSYH** | Askeri harcamanın milli gelire oranı | En yaygın uluslararası karşılaştırma metriği; NATO'nun %2 hedefi bu göstergeye dayanıyor |
| **Savunma Kişi Başı** | Kişi başına düşen savunma harcaması (USD, log) | Mutlak harcama kapasitesini yansıtır; % GSYH ile birlikte kullanılınca farklı bir boyut katar |
| **Savunma Bütçe Payı** | Savunmanın devlet harcamaları içindeki yüzdesi | Hükümet önceliklendirmesini ölçer; GSYH değil, bütçe kararlarını yansıtır |

### 3.2 Sosyal Yatırım Grubu (WDI — 2 Değişken)

| Değişken | WDI Kodu | Tanım |
|----------|----------|-------|
| **Sağlık % GSYH** | `SH.XPD.CHEX.GD.ZS` | Toplam sağlık harcaması / GSYH |
| **Eğitim % GSYH** | `SE.XPD.TOTL.GD.ZS` | Kamu eğitim harcaması / GSYH |

### 3.3 Ekonomik Göstergeler (WDI — 2 Değişken)

| Değişken | WDI Kodu | Tanım |
|----------|----------|-------|
| **Kişi Başı GSYH (log)** | `NY.GDP.PCAP.CD` | Kişi başına milli gelir; ülkelerin ekonomik gelişmişlik düzeyi |
| **Yaşam Beklentisi** | `SP.DYN.LE00.IN` | Doğumda beklenen yaşam süresi; sosyal gelişmişliğin özet göstergesi |

---

## 4. "Neden % GSYH Kullandınız?" — En Kritik Soru

### Kısa Cevap
> Tüm ülkeleri aynı ölçekte karşılaştırabilmek için. Ham para değerleri (USD) ülke büyüklüğünü
> ölçer, politika önceliklerini değil.

### Uzun Cevap
Eğer ham değer (örneğin sağlık harcaması milyar USD) kullansaydık:
- ABD, Almanya, İngiltere gibi ülkeler **her göstergede** en üstte yer alırdı
- Çünkü bunlar zaten büyük ekonomiler — her şeye çok para harcıyorlar
- Bu durumda tüm korelasyonlar "zengin ülkeler her şeye çok harcıyor" mesajını verirdi — **bunu zaten biliyoruz**

% GSYH kullandığımızda ise şunu soruyoruz:
> *"Bu ülke, ekonomisinin ne kadarını sağlığa ayırıyor?"*

Bu soru; Yunanistan ile Japonya'yı, Arnavutluk ile Kanada'yı **adil biçimde** karşılaştırabilmemizi sağlıyor.

### Somut Örnek

| Ülke | Sağlık (USD milyar) | Sağlık (% GSYH) |
|------|---------------------|-----------------|
| ABD | ~4.500 | ~17% |
| Yunanistan | ~12 | ~8% |
| Finlandiya | ~18 | ~9% |

Ham değere baksan ABD her zaman birinci; % GSYH'ye baksan Yunanistan ile Finlandiya'nın
neredeyse aynı önceliği taşıdığını görürsün.

---

## 5. "Kişi Başı Savunma Neden Log Dönüşümü Aldı?"

### Sorun
Kişi başı savunma harcaması bazı ülkelerde 50 USD, bazılarında 2.000 USD.
Bu çarpık dağılım (sağa uzayan kuyruk) Pearson korelasyonunu bozardı.

### Çözüm
`log10(değer + 1)` dönüşümü uygulandı. Bu dönüşüm:
- Sayıların **sıralamasını** (rank'ını) korur
- Aşırı değerlerin (outlier) etkisini azaltır
- Zaten **Spearman** kullandığımız için bu dönüşüm yalnızca görsel temsil içindir; istatistiksel sonucu değiştirmez

---

## 6. "Neden Spearman? Pearson Değil Mi?"

### Pearson'ın Varsayımları
- Değişkenler **normal dağılımlı** olmalı
- İlişki **doğrusal** olmalı

### Ülke Verisinin Gerçeği
- Savunma harcamaları, kişi başı gelir gibi değişkenler genellikle **sağa çarpık**
- Rusya veya İsrail gibi özel konumdaki ülkeler **aykırı değer** oluşturuyor
- Değişkenler arasındaki ilişki doğrusal değil, **monoton** (birlikte artıp azalıyor) olabilir

### Spearman'ın Avantajı
Spearman rank korelasyonu, gerçek değerleri değil **sıralamayı** kullanır.
- Normal dağılım varsayımı yok
- Aykırı değerlere karşı dayanıklı
- Monoton ilişkileri yakalar

> **Sonuç:** 40 ülkelik, karma ekonomili bir örneklemde Spearman metodolojik olarak
> Pearson'dan **daha güvenilir** bir seçim.

---

## 7. Grafiği Nasıl Okursun?

### Daireler
- **Büyük daire** → güçlü korelasyon (r, -1'e veya +1'e yakın)
- **Küçük daire** → zayıf korelasyon (r, 0'a yakın)

### Renkler
- **Mavi** → pozitif korelasyon (birlikte artıyor)
- **Turuncu/Kırmızı** → negatif korelasyon (biri artarken diğeri azalıyor)
- **Beyaz/Soluk** → korelasyon yok (r ≈ 0)

### Sayılar
Her dairenin içindeki sayı, Spearman **r** katsayısını gösterir:
- `r = 1.00` → mükemmel pozitif ilişki
- `r = 0.00` → ilişki yok
- `r = -1.00` → mükemmel negatif ilişki

### Köşegen
Her değişkenin kendisiyle korelasyonu = **1.00** (mavi dolu daire).
Bu matematiksel bir zorunluluk, yorumlanmaz.

### Boş Hücreler (Seçici Versiyon)
`p > 0.05` olan çiftlerde daire **çizilmedi**. Bu, o ilişkinin istatistiksel olarak
anlamsız olduğu anlamına gelir — tesadüf eseri ortaya çıkmış olabilir.

---

## 8. Örneklem — Neden Bu Ülkeler?

**40 ülke = NATO üyeleri + büyük askeri güçler (Çin, Rusya, Hindistan, İsrail vb.)**

### Neden bu seçim?
- Savunma harcaması verisinin **en güvenilir ve eksiksiz** olduğu ülke kümesi
- Uluslararası güvenlik literatüründe standart karşılaştırma grubu
- Geniş coğrafi ve ekonomik çeşitlilik: Arnavutluk'tan ABD'ye, Bulgaristan'dan Japonya'ya

### Neden tüm dünya değil?
- Pek çok ülkenin sağlık/eğitim verisi WDI'da eksik
- Düşük gelirli ülkelerde SIPRI verisi güvenilirliği düşük
- Örneklemi genişletmek N'i artırır ama **homojen olmayan** bir kümeye yol açar

---

## 9. Temel Bulgular

> ⚠️ Aşağıdaki yorum taslakları, grafiği görsel olarak değerlendirerek yazılmıştır.
> Sunum öncesi kendi grafiğindeki **gerçek r değerlerini** bu yorumlarla karşılaştır.

### Güçlü Pozitif İlişkiler (Beklenen)
- **Savunma Kişi Başı ↔ Kişi Başı GSYH:** Zengin ülkeler savunmaya da mutlak olarak daha fazla harcıyor.
  Bu beklenen bir ilişki; sürpriz değil.
- **Sağlık % GSYH ↔ Yaşam Beklentisi:** Sağlığa daha fazla pay ayıran ülkelerde yaşam süresi daha uzun.

### Zayıf / Anlamsız İlişkiler (Asıl Bulgular)
- **Savunma % GSYH ↔ Sağlık % GSYH:** Savunmaya GSYİH'den fazla pay ayıran ülkeler, sağlığa
  orantılı olarak **daha az** harcamıyor. Yani "silah mı, ilaç mı" ikilemi bu veri setinde belirgin değil.
- **Savunma % GSYH ↔ Eğitim % GSYH:** Benzer şekilde, savunma önceliği ile eğitim önceliği
  arasında net bir takas ilişkisi görülmüyor.

> **Önemli yorum nüansı:** Bu, savunma harcamasının sosyal harcamaları *etkilemediği* anlamına
> gelmiyor. Korelasyon nedensellik değildir. Başka değişkenler (jeopolitik konum, ittifak üyeliği,
> tarihsel faktörler) her iki harcama türünü aynı anda şekillendiriyor olabilir.

---

## 10. Sıkça Sorulabilecek Sorular

### S: "Kişi başı GSYH ve kişi başı savunma harcaması zaten birbirini tahmin etmiyor mu?"

**C:** Evet, bu iki değişken arasında yüksek korelasyon beklenir ve bu bir sınırlılıktır.
Kişi başı savunma harcaması, hem "bu ülke ne kadar savunmaya önem veriyor" sorusunu hem de
"bu ülke ne kadar zengin" sorusunu aynı anda cevaplıyor. Bu nedenle **Savunma % GSYH** değişkeni
bize daha temiz bir politika sorusu soruyor. İki değişkeni birlikte tutmamızın gerekçesi, farklı
boyutları (mutlak kapasite vs. nispi öncelik) temsil etmeleriydi.

---

### S: "N = 40 yeterince büyük mü?"

**C:** Korelasyon analizleri için 40 gözlem **kabul edilebilir** bir örneklemdir.
- Genel kural: değişken başına en az 10 gözlem → 7 değişken × 10 = 70 ideal, ama 40 da
  literatürde yaygın kullanılan bir eşik olan 30'un üzerinde.
- Daha önemlisi, bu 40 ülke **tüm dünyayı** temsil etmiyor; orta-büyük ekonomili,
  güvenilir savunma verisine sahip ülkeleri temsil ediyor. Bu bir sınırlılık olarak açıkça belirtilmeli.

---

### S: "Grafikteki sonuçlar nedensellik gösteriyor mu?"

**C:** Hayır, **kesinlikle hayır.** Korelasyon ≠ Nedensellik.
Bu grafik yalnızca şunu söylüyor: *"Bu iki değişken birlikte hareket etme eğiliminde mi?"*
Nedensellik iddiası için kontrol değişkenleri, regresyon modelleri ve tercihen panel veri analizi gerekirdi.

---

### S: "Neden sadece NATO ülkeleri?"

**C:** Örneklem NATO üyeleriyle sınırlı değil. Çin, Rusya, Hindistan, Brezilya, İsrail, Suudi Arabistan,
BAE, Katar, Singapur ve G. Afrika da dahil. Seçim kriteri "NATO üyesi olmak" değil; **SIPRI ve WDI'da
eksiksiz veriye sahip olmak** ve küresel savunma gündeminde kayda değer yer tutmak.

---

### S: "2022 yılı neden seçildi? Ukrayna Savaşı etkisi yok mu?"

**C:** SIPRI'den 2022 verisi alındı çünkü analizin yazıldığı dönemde en güncel eksiksiz yıldı.
2022, Rusya'nın Ukrayna'yı işgal ettiği yıl olduğu için özellikle **Ukrayna, Polonya, Estonya** gibi
ülkelerin savunma harcamalarında ani sıçrama gözlemlendi. Bu durum analizi bozmuyor; aksine
güncel ve gerçekçi bir tablo sunuyor. İsterseniz "Bu korelogramı 2021 verisiyle çizseydiniz ne değişirdi?"
sorusu ilginç bir karşılaştırma konusu olabilir.

---

### S: "Grafikte boş kalan hücreler ne anlama geliyor?"

**C:** Seçici versiyonda (p < 0.05) boş hücre, o korelasyonun **istatistiksel olarak anlamsız**
olduğunu gösteriyor — yani gözlemlenen ilişki tesadüften kaynaklanıyor olabilir. Bu bir hata değil,
aksine dürüst bir istatistiksel sunum. Anlamsız ilişkileri göstererek okuyucuyu yanıltmamak tercih edildi.

---

## 11. Sunum İpuçları

1. **Önce soruyu sun, sonra grafiği:** *"Savunmaya çok harcayan ülkeler sağlığa ve eğitime daha az mı harcıyor?"* sorusunu söyle, ardından grafiği göster.

2. **Renk mantığını hemen açıkla:** "Mavi = birlikte artıyor, turuncu = biri artarken diğeri azalıyor, daire büyüklüğü ilişkinin gücünü gösteriyor."

3. **Seçici versiyonu öne çıkar:** Boş hücreler kalabalığı azaltıyor, önemli ilişkilere odaklanmayı sağlıyor.

4. **Sınırlılıkları kendin söyle:** "Bu 40 ülkelik bir kesit analizi, nedensellik değil ilişki gösteriyor" — bunu kendin söylersen sormadan önce güven kazanırsın.

5. **"Beklenen" ile "şaşırtıcı" bulguları ayır:** Kişi başı gelir ile kişi başı savunma korelasyonu beklenendirdir. Asıl ilginç bulgu, savunma/GSYH oranının sosyal harcama oranlarıyla **anlamlı bir ilişki taşımaması** — bunu vurgula.

---

## 12. Hızlı Başvuru: Değişken Kodları

| Grafikteki İsim | Veri Kaynağı | Kod/Sayfa | Birim |
|-----------------|--------------|-----------|-------|
| Savunma % GSYH | SIPRI | "Share of GDP" | % |
| Savunma Kişi Başı | SIPRI | "Per capita" | USD (log10) |
| Savunma Bütçe Payı | SIPRI | "Share of Govt. spending" | % |
| Sağlık % GSYH | World Bank | SH.XPD.CHEX.GD.ZS | % |
| Eğitim % GSYH | World Bank | SE.XPD.TOTL.GD.ZS | % |
| Kişi Başı GSYH | World Bank | NY.GDP.PCAP.CD | USD (log10) |
| Yaşam Beklentisi | World Bank | SP.DYN.LE00.IN | Yıl |

---

*Hazırlayan: AI Asistan · SIPRI + World Bank Verileri · Spearman Korelasyon Analizi*
