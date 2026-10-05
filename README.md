# SPORTIME Demo

`Kobiltek/Raporlar/SPORTIME-Gunluk-Kullanim-Raporu.md` raporundaki önerilerin çalışan Flutter demosu. Tüm veriler kurgusaldır (`lib/mock_data.dart`). Canlı skorlar ve bildirimler uygulama içinde simüle edilir. Harici paket kullanılmaz.

## Çalıştırma

```powershell
$env:Path += ";C:\src\flutter\bin"
cd C:\staj\sportime_demo
flutter run                # açık Android emülatörü
flutter run -d chrome      # web
```

Android derlemesi için `android/app/build.gradle.kts` içinde bu makinede kurulu NDK sürümü (30.0.16248370) seçilidir.

### Web demosunda doğrudan ekran açma

Sunum ve ekran görüntüsü için adres parametreleri:

| Parametre | Açılan ekran |
|---|---|
| `?tab=0` … `?tab=4` | Anasayfa, Maçlar, Müsabakalar, Keşfet, Profilim |
| `?tab=3&sub=1` | Keşfet → Kulüpler |
| `?screen=match:m1` | Maç detayı (canlı skor) |
| `?screen=athlete:a3` | Sporcu detayı |
| `?screen=club:c1` | Kulüp detayı |
| `?screen=notifications` | Bildirimler (bugünün hatırlatmaları gönderilmiş olarak) |
| `?screen=metrics` | Kullanım ölçümleri |

## Rapordaki öneri → demodaki karşılığı

| Öneri | Nerede |
|---|---|
| Anasayfanın ilk sekmeye alınması, "Dahası" yerine "Profilim" | Alt menü (`main.dart`) |
| "Bugün" bloğu | Anasayfa → *Bugünün maçları*, son başvuru kartı |
| Kademeli bildirimler (3 gün kala / 1 gün kala / son gün) | Müsabakalar → zil simgesi + *Hatırlatmaları gönder (demo)*; tercihler Profilim'de |
| Takip edilen sporcu ve kulüplerin akışı | Keşfet → *Takip et* → Anasayfa → *Takip ettiklerin* |
| Kulüp/sporcu mini akışı | Keşfet → Kulüpler → kulüp sayfası (duyurular, sporcular) |
| Canlı skor / maç takibi | Maçlar, maç detay ekranı (her 2 sn'de bir sayı) |
| Maç başladı, set ve maç sonucu bildirimleri | Takip edilen sporcuların ve kulüplerin sporcularının maçlarında otomatik; ~40 sn sonra Elif Yıldız'ın maçı başlar |
| Kişisel istatistik paneli | Sporcu detayı ve Profilim (sıralama grafiği, galibiyet oranı, son 5 maç) |
| Rozet sistemi | Profilim → *Rozetler* (8 rozet) |
| Antrenman günlüğü ve seri | Profilim → *Antrenman ekle*; seri anasayfada da görünür |
| Ölçümleme (§6) | Profilim → Yönetim → *Kullanım ölçümleri*: DAU/MAU, bildirim açılma oranı (örnek veri) + bu cihazdaki gerçek olay sayaçları |
| Erişilebilirlik | Avatar, grafik ve skorlarda `Semantics` etiketleri; 320 px ekran ve %130 yazı boyutunda taşma testleri |

Kapsam dışında kalanlar: ana ekran widget'ı, topluluk/forum, çoklu federasyon içeriği, gerçek push bildirimi (Firebase vb.), gerçek analitik servisi ve SBS entegrasyonu.

## Kod yapısı

```
lib/
  main.dart          uygulama, alt menülü iskelet, bildirim gösterimi, web bağlantı parametreleri
  app_state.dart     tüm durum, canlı skor simülasyonu, rozet kuralları, ölçüm sayaçları
  models.dart        veri modelleri (badminton set kuralı dahil)
  mock_data.dart     kurgusal sporcu, kulüp, maç, turnuva ve kullanım verisi
  format.dart        Türkçe tarih yardımcıları
  theme.dart         TBF kırmızısı tema
  widgets.dart       ortak bileşenler ve ekran açma yardımcıları
  screens/           ekranlar (anasayfa, maçlar, maç detayı, müsabakalar, keşfet,
                     sporcu ve kulüp detayı, profilim, bildirimler, ölçümler)
test/
  widget_test.dart   9 test: akış, kulüp takibi, rozet, set kuralları, hatırlatma, seri, bildirim sayacı, gezinme
  layout_test.dart   7 test: küçük ekran ve büyük yazı boyutunda taşma kontrolü
```

```powershell
flutter analyze   # statik analiz
flutter test      # 16 test
```
