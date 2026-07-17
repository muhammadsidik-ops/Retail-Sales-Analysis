#  Analisis Penjualan dan Rekomendasi Bisnis untuk Toko Peralatan Dapur

**Oleh:** Muhammad Sidik  
**Role:** Data Analyst  

---

## 📌 Latar Belakang Masalah (Business Problem)
Di balik operasional harian sebuah toko ritel peralatan dapur, terdapat ribuan transaksi yang terjadi setiap bulannya. Sekilas, melihat barang terjual dan pendapatan masuk sudah terasa cukup. Namun, untuk bisa bertumbuh dan bertahan di pasar yang kompetitif, manajemen perlu menjawab pertanyaan strategis yang lebih dalam: 
* *"Dari puluhan kategori barang yang kita jual, mana yang sebenarnya menjadi urat nadi perusahaan?"* 
* *"Seberapa efisien pengiriman kita?"* 
* *"Berapa banyak potensi pendapatan yang hangus karena pelanggan mengembalikan barang (refund)?"*

Proyek ini bertujuan untuk menyelesaikan masalah tersebut. Dengan menganalisis dataset riwayat operasional toko selama tahun 2025 yang berisi **10.000 catatan transaksi**, saya mengekstraksi data mentah ini menjadi *insight* bisnis yang nyata. Fokus utamanya bukan sekadar memaparkan angka penjualan, melainkan menemukan kebocoran pendapatan dan merumuskan strategi optimasi inventaris.

## 🧭 Metodologi & Alur Kerja
Untuk menjaga agar repositori ini tetap bersih, seluruh proses pengolahan teknis (kode) dipisahkan ke dalam folder khusus. Berikut adalah gambaran alur analisis yang saya lakukan:

1. **Eksplorasi & Transformasi Data (Google BigQuery - SQL):** 
   Saya menggunakan SQL untuk membersihkan data, mengelompokkan segmentasi daya beli pelanggan, menghitung *retention rate* (jeda waktu antar-pembelian), dan mengaudit tingkat *refund* per produk. 
   *(Seluruh script SQL untuk tahap ini dapat Anda lihat di dalam folder `SQL_Scripts` pada repository ini).*
2. **Visualisasi Data (Google Looker Studio):** 
   Hasil agregasi dari BigQuery kemudian saya hubungkan ke Looker Studio untuk membangun *dashboard* interaktif, sehingga pemangku kepentingan (manajemen) dapat memantau KPI secara *real-time* tanpa harus memahami kueri *database*.

> 💡 **Lihat Hasilnya:** 
> Anda dapat berinteraksi langsung dengan data (melakukan filter rentang waktu, kategori, atau wilayah) melalui *Live Dashboard* berikut:  
> 👉 **[https://datastudio.google.com/reporting/fc198718-700d-49ac-bb6c-e19ae3be8d5e](#)** 

## 🔍 Temuan Utama (Key Insights)
Dari proses analisis mendalam, data mengungkap beberapa realita bisnis berikut:

* **Satu Kategori Memonopoli Pendapatan:** Walaupun toko ini menjual beragam alat rumah tangga, **79,5%** dari total pendapatan (lebih dari Rp 5,8 Miliar) ditopang secara masif oleh kategori **Alat Masak**. 
* **Sang Bintang Penjualan:** Produk *Mesin Kopi Espresso Rumahan* keluar sebagai penyumbang *gross sales* tertinggi (mencapai lebih dari Rp 700 Juta), disusul oleh Food Processor.
* **Persaingan Aglomerasi Ketat:** Wilayah Jakarta Pusat memimpin total penjualan, namun persaingannya sangat tipis dengan Jakarta Barat dan Jakarta Selatan.
* **Kebocoran Pendapatan dari Refund:** Secara umum, pesanan berhasil (*Completed Rate*) berada di angka yang baik (89,72%). Namun, analisis granular menemukan beberapa produk spesifik memiliki *refund rate* yang jauh di atas rata-rata batas toleransi toko.

## 🎯 Rekomendasi Bisnis (Actionable Insights)
Berdasarkan temuan di atas, berikut adalah rekomendasi strategis yang dapat segera dieksekusi oleh manajemen untuk memaksimalkan margin keuntungan:

1. **Prioritas Utama Manajemen Inventaris:** Tim Rantai Pasok (*Supply Chain*) harus memberikan prioritas pengamanan stok pada Top 5 Produk (terutama Mesin Kopi Espresso). Mengingat ketergantungan toko yang sangat tinggi pada produk-produk ini, *Out of Stock* (kekosongan barang) pada kuartal krusial akan melumpuhkan target pendapatan.
2. **Taktik Promosi Silang (Cross-Selling):** Kategori *Alat Simpan* (10,6%) dan *Alat Saji* (9,9%) sangat tertinggal. Tim *Marketing* disarankan membuat kampanye promosi *bundling* silang. Misalnya: Memberikan diskon spesial untuk set cangkir/toples kopi setiap kali pelanggan membeli Mesin Kopi Espresso.
3. **Investigasi Kualitas Pengemasan (Quality Control):** Perlu ada kolaborasi antara tim logistik dan QC untuk mengaudit produk dengan angka *refund* tertinggi. Memperbaiki standar keamanan pengemasan pada produk rentan ini akan langsung menambal kebocoran bisnis dan menyelamatkan potensi pendapatan.
