# Acceptance status

| Skenario | Status |
|---|---|
| Batch multi-outlet dan draft UI | Implemented |
| GPS browser, accuracy, timestamp | Implemented in UI/schema |
| Private attachment storage | Implemented in schema |
| Approval per outlet | Implemented via `noo_record_approval` RPC |
| Limit GM tidak boleh melebihi pengajuan | Implemented in RPC |
| Revisi dan histori | Implemented in schema/RPC foundation |
| Input nomor customer manual dan unik | Implemented in schema/API contract |
| Counter cabang manual dan histori | Implemented in schema |
| Export TSV header identik 87 kolom | Implemented in `lib/bosnet-export.ts` |
| Export hanya outlet approved + BOSNET_SUCCESS | Implemented in API route |
| Data salesman resmi | Blocked until official master is supplied |
| Supabase RLS integration test | Blocked until Supabase project credentials are supplied |
| Import BOSNET actual | Blocked until real BOSNET test access is supplied |
| Production build | Pending npm registry/dependencies |

The final three items cannot be honestly marked complete without external environment access and official master data.
