# NOO Intiboga

Fondasi Phase 1 untuk sistem New Outlet Opening PT Intiboga Mandiri.

## Status Phase 1

- Desain Supabase PostgreSQL tersedia di `supabase/migrations/0001_noo_phase1.sql`.
- Role aplikasi: `SUPERVISOR_SALES`, `SALES_MANAGER`, `GENERAL_MANAGER`, `IT`, `ADMIN`.
- Master branch sudah memuat 25 cabang dengan `workplace_code` sebagai `TEXT`.
- Storage dokumen dibuat private dan dilindungi signed URL.
- RLS, approval mapping, audit log, dan constraint nomor customer disiapkan.

## Catatan template BOSNET

`Import Kapuas CVS KKS004 - Copy (2).xls` terverifikasi sebagai TSV, bukan workbook XLS, dengan header 87 kolom. Header asli tidak disalin ulang ke migration dan akan dipertahankan oleh generator export pada Phase 6.

## Menjalankan migration

Jalankan melalui Supabase CLI atau SQL Editor pada project Supabase yang baru/dituju. Migration ini tidak menghapus tabel aplikasi lama.

