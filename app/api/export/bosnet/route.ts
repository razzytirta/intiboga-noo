import { NextResponse } from 'next/server';
import { getSupabaseServer } from '../../../../lib/supabase';
import { buildBosnetTsv, ExportOutlet } from '../../../../lib/bosnet-export';

export async function POST(request: Request) {
  try {
    const body = await request.json() as { outlet_ids?: string[] };
    if (!body.outlet_ids?.length) return NextResponse.json({ error: 'Pilih minimal satu outlet' }, { status: 400 });
    const supabase = getSupabaseServer();
    const { data, error } = await supabase.from('noo_outlets').select('id,customer_name,owner_name,nik,contact_person,address,district,village,city,postal_code,province,country,phone,latitude,longitude,bank_name,bank_account_number,notes,outlet_type,batch_id,status,noo_batches(branch_id,salesmen(bosnet_sales_code),branches(workplace_code)),noo_bosnet_data(customer_number,bosnet_status)').in('id', body.outlet_ids);
    if (error) throw error;
    const outlets: ExportOutlet[] = [];
    for (const row of (data || []) as any[]) {
      if (row.status !== 'WAITING_IT' && row.status !== 'BOSNET_SUCCESS' && row.status !== 'COMPLETED') throw new Error(`Outlet ${row.id} belum approved GM`);
      const bos = Array.isArray(row.noo_bosnet_data) ? row.noo_bosnet_data[0] : row.noo_bosnet_data;
      const batch = Array.isArray(row.noo_batches) ? row.noo_batches[0] : row.noo_batches;
      const branch = Array.isArray(batch?.branches) ? batch.branches[0] : batch?.branches;
      const sales = Array.isArray(batch?.salesmen) ? batch.salesmen[0] : batch?.salesmen;
      if (!bos?.customer_number || bos.bosnet_status !== 'BOSNET_SUCCESS') throw new Error(`Outlet ${row.id} belum memiliki nomor customer BOSNET sukses`);
      outlets.push({ ...row, customer_number: bos.customer_number, workplace_code: branch?.workplace_code, sales_code: sales?.bosnet_sales_code });
    }
    const tsv = buildBosnetTsv(outlets);
    return new NextResponse(tsv, { headers: { 'Content-Type': 'text/tab-separated-values; charset=utf-8', 'Content-Disposition': 'attachment; filename="noo-bosnet-import.tsv"' } });
  } catch (e) { return NextResponse.json({ error: e instanceof Error ? e.message : 'Export gagal' }, { status: 400 }); }
}
