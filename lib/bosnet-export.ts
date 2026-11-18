import { BOSNET_HEADERS, validateBosnetRow, validateCustomerNumber } from './bosnet-template';

export type ExportOutlet = { customer_number: string; customer_name: string; contact_person?: string; address: string; district: string; village: string; city: string; postal_code?: string; province: string; country?: string; phone?: string; latitude: number; longitude: number; workplace_code: string; sales_code: string };

export function toBosnetRow(o: ExportOutlet): string[] {
  const row = Array<string>(87).fill('');
  const put = (index: number, value: unknown) => { row[index] = value == null ? '' : String(value); };
  put(0, o.customer_number); put(1, o.customer_name); put(2, o.contact_person); put(6, o.address); put(7, o.district); put(8, o.village); put(9, o.city); put(10, o.postal_code); put(11, o.province); put(12, o.country || 'INDONESIA'); put(16, o.phone); put(19, o.latitude); put(20, o.longitude);
  put(21, 1); put(22, 1); put(23, 1); put(24, 1); put(25, o.customer_number); put(26, o.customer_number); put(27, o.customer_number); put(28, o.customer_number); put(29, 0); put(30, 0); put(31, 0); put(43, 'ACT'); put(45, o.workplace_code); put(46, o.workplace_code); put(47, o.workplace_code); put(48, o.workplace_code); put(49, 'R'); put(50, 'IDR'); put(59, o.sales_code); put(73, 1); put(74, 1); put(75, 1); put(76, 0); put(77, 0); put(78, 0); put(79, 0); put(80, 0); put(86, 'NEW');
  return row;
}

export function buildBosnetTsv(outlets: ExportOutlet[]) {
  const errors: string[] = [];
  const ids = new Set<string>();
  const rows = outlets.map((o, i) => { if (ids.has(o.customer_number)) errors.push(`Duplikat nomor customer pada baris ${i + 2}`); ids.add(o.customer_number); if (!validateCustomerNumber(o.customer_number, o.workplace_code)) errors.push(`Prefix customer tidak cocok pada baris ${i + 2}`); const row = toBosnetRow(o); const check = validateBosnetRow(row); errors.push(...check.errors.map(e => `Baris ${i + 2}: ${e}`)); return row; });
  if (errors.length) throw new Error(errors.join('\n'));
  return [BOSNET_HEADERS, ...rows].map(row => row.join('\t')).join('\r\n') + '\r\n';
}
