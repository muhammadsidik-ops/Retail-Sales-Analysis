-- 01. Total Sales dan Rata-rata Sales Keseluruhan 2025
SELECT 
    sum(total_sales) AS revenue, 
    avg(total_sales) AS rerata_total_sales
FROM toko_peralatan_dapur.orders
WHERE status_clean = 'complete';

-- 02. Kinerja Pendapatan (Revenue) per Kategori Produk
SELECT 
    category_clean, 
    sum(total_sales) AS revenue
FROM toko_peralatan_dapur.orders
WHERE status_clean = 'complete' 
GROUP BY category_clean
ORDER BY revenue DESC;

-- 03. Segmentasi Penjualan Pelanggan (Kecil, Sedang, Besar)
WITH sementara AS (
    SELECT
        order_id,
        CASE 
            WHEN total_sales > 2000000 THEN 'besar'
            WHEN total_sales > 500000 THEN 'sedang'
            ELSE 'kecil'
        END AS category_spending
    FROM toko_peralatan_dapur.orders
    WHERE sales_date IS NOT NULL
)
SELECT 
    category_spending, 
    count(order_id) AS total_pesanan
FROM sementara
GROUP BY category_spending;

-- 04. Total dan Rata-rata Ongkos Kirim (Shipping Fee)
SELECT
    SUM(shipping_fee) AS total_ongkos_kirim,
    ROUND(AVG(shipping_fee), 0) AS rata_rata_ongkir
FROM toko_peralatan_dapur.orders
WHERE sales_date IS NOT NULL;

-- 05. Top 5 Produk Berdasarkan Unit Terjual (Hero Products)
SELECT 
    product_name, 
    SUM(quantity) AS total_unit
FROM toko_peralatan_dapur.orders
WHERE status_clean = 'complete'
GROUP BY product_name
ORDER BY total_unit DESC 
LIMIT 5;

-- 06. Performa Kuartal Akhir: Total Pesanan dan Revenue Q4 (Okt - Des)
SELECT 
    COUNT(order_id) AS jumlah_pesanan, 
    SUM(total) AS total_revenue
FROM toko_peralatan_dapur.orders
WHERE status_clean = 'complete' 
  AND EXTRACT(QUARTER FROM sales_date) = 4;

-- 07. Analisis Rata-rata Ongkos Kirim Kota Termahal dan Selisihnya (Subquery)
WITH rata_rata_kota AS (
    SELECT city_clean, AVG(shipping_fee) AS avg_ongkir
    FROM toko_peralatan_dapur.orders
    WHERE sales_date IS NOT NULL
    GROUP BY city_clean
)
SELECT 
    (SELECT city_clean FROM rata_rata_kota ORDER BY avg_ongkir DESC LIMIT 1) AS kota_termahal,
    (SELECT MAX(avg_ongkir) FROM rata_rata_kota) - (SELECT MIN(avg_ongkir) FROM rata_rata_kota) AS selisih_ongkir;

-- 08. Menghitung Total dan Persentase Kerugian dari Refund
SELECT 
    SUM(CASE WHEN status_clean = 'refund' THEN total_sales ELSE 0 END) AS total_refund,
    ROUND((SUM(CASE WHEN status_clean = 'refund' THEN total_sales ELSE 0 END) / SUM(total_sales)) * 100, 2) AS persentase_refund
FROM toko_peralatan_dapur.orders
WHERE sales_date IS NOT NULL;

-- 09. Top 5 Produk dengan Rata-rata Quantity Tertinggi (Min. 50 Pesanan)
SELECT 
    product_name, 
    AVG(quantity) AS rata_rata_qty, 
    COUNT(order_id) AS jumlah_pesanan
FROM toko_peralatan_dapur.orders
WHERE status_clean = 'complete'
GROUP BY product_name
HAVING COUNT(order_id) >= 50
ORDER BY rata_rata_qty DESC
LIMIT 5;

-- 10. Mengidentifikasi Bulan dengan Revenue Tertinggi per Kategori (Window Function)
WITH revenue_bulanan AS (
    SELECT 
        category_clean, 
        EXTRACT(MONTH FROM sales_date) AS bulan, 
        SUM(total) AS revenue
    FROM toko_peralatan_dapur.orders
    WHERE status_clean = 'complete'
    GROUP BY category_clean, bulan
)
SELECT category_clean, bulan, revenue
FROM (
    SELECT 
        *, 
        ROW_NUMBER() OVER(PARTITION BY category_clean ORDER BY revenue DESC) AS peringkat
    FROM revenue_bulanan
)
WHERE peringkat = 1;

-- 11. Analisis Prinsip Pareto: Jumlah Produk yang Menyumbang 80% Total Revenue
WITH revenue_produk AS (
    SELECT product_name, SUM(total) AS revenue
    FROM toko_peralatan_dapur.orders
    WHERE status_clean = 'complete'
    GROUP BY product_name
),
kumulatif AS (
    SELECT 
        product_name, 
        revenue,
        SUM(revenue) OVER(ORDER BY revenue DESC) AS running_rev,
        SUM(revenue) OVER() AS total_rev
    FROM revenue_produk
)
SELECT COUNT(product_name) AS jumlah_produk_top_80_persen
FROM kumulatif
WHERE (running_rev - revenue) <= (total_rev * 0.8);

-- 12. Analisis Retensi: Jeda Waktu Pesanan Pelanggan (Pelanggan > 5 Pesanan)
WITH pesanan_pelanggan AS (
    SELECT 
        customer_name_clean, 
        sales_date AS order_date
    FROM toko_peralatan_dapur.orders
    WHERE status_clean = 'complete'
),
jeda_hari AS (
    SELECT 
        customer_name_clean, 
        DATE_DIFF(order_date, LAG(order_date) OVER(PARTITION BY customer_name_clean ORDER BY order_date), DAY) AS jeda
    FROM pesanan_pelanggan
),
agregasi_jeda AS (
    SELECT 
        customer_name_clean, 
        AVG(jeda) AS rata_rata_jeda, 
        COUNT(jeda) + 1 AS total_pesanan
    FROM jeda_hari
    WHERE jeda IS NOT NULL
    GROUP BY customer_name_clean
    HAVING (COUNT(jeda) + 1) > 5
)
SELECT 
    (SELECT AVG(rata_rata_jeda) FROM agregasi_jeda) AS rata_rata_jeda_semua_pelanggan,
    customer_name_clean AS pelanggan_jeda_tersingkat,
    rata_rata_jeda AS nilai_jeda_tersingkat
FROM agregasi_jeda
ORDER BY rata_rata_jeda ASC
LIMIT 1;

-- 13. Audit QC: Refund Rate Produk dan Potensi Revenue Diselamatkan
WITH data_produk AS (
    SELECT 
        product_name,
        COUNT(order_id) AS total_orders,
        COUNTIF(status_clean = 'refund') AS refund_orders,
        SUM(total_sales) AS gross_sales_produk
    FROM toko_peralatan_dapur.orders
    WHERE sales_date IS NOT NULL
    GROUP BY product_name
),
rata_toko AS (
    SELECT COUNTIF(status_clean = 'refund') / COUNT(order_id) AS avg_refund_rate
    FROM toko_peralatan_dapur.orders
    WHERE sales_date IS NOT NULL
)
SELECT 
    p.product_name, 
    (p.refund_orders / p.total_orders) AS refund_rate,
    (p.refund_orders - (p.total_orders * s.avg_refund_rate)) * (p.gross_sales_produk / p.total_orders) AS potensi_revenue_selamat
FROM data_produk p
CROSS JOIN rata_toko s
ORDER BY refund_rate DESC
LIMIT 1;
