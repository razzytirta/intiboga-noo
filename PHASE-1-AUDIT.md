# Phase 1 — Audit dan desain database

## Proyek yang diperiksa

Workspace sebelumnya adalah aplikasi pencatatan tagihan dengan tabel `profiles` dan `document_records`; role dan storage-nya tidak sesuai NOO. Proyek tersebut tidak diubah.

## Keputusan desain

- Kode workplace, kode sales, NIK, nomor HP, dan nomor customer disimpan sebagai `TEXT`.
- Nomor customer tidak digenerate oleh database; `noo_bosnet_data.customer_number` hanya menerima input IT dan unik global.
- Counter cabang hanya monitoring manual dan memiliki log perubahan.
- Approval disimpan per outlet dengan reviewer, role, keputusan, catatan, waktu, dan versi data.
- Lampiran disimpan sebagai path Supabase Storage private, bukan base64.
- Data outlet tetap menyimpan GPS, akurasi, waktu, dan user pengambil lokasi.
- RLS dasar memisahkan supervisor, reviewer berdasarkan mapping cabang, IT, dan admin.

## Risiko yang sengaja belum ditebak

- Kode salesman dan nilai default kolom BOSNET belum dibuat karena tidak ada master salesman yang diberikan.
- Mapping 87 kolom template belum dibuat karena field aplikasi belum dikonfirmasi ke kolom BOSNET.
- Kompatibilitas import BOSNET belum diklaim sebelum ada uji import aktual.

## Verifikasi sumber template

File `C:\Users\Razzi\Downloads\Import Kapuas CVS KKS004 - Copy (2).xls` dibaca sebagai TSV: header 87 kolom, data tab-separated, dan kolom kode seperti `C0150873`, `015`, serta NIK tetap diperlakukan sebagai teks.

## Langkah berikutnya

1. Jalankan migration pada Supabase project tujuan.
2. Tambahkan auth callback dan server-side role helpers di Next.js.
3. Seed salesman hanya dari master resmi.
4. Lanjut Phase 2: master cabang, master salesman, dan dashboard.

