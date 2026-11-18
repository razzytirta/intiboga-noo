import { z } from 'zod';

export const outletSchema = z.object({
  batch_id: z.string().uuid(),
  customer_name: z.string().trim().min(1), owner_name: z.string().trim().min(1), contact_person: z.string().trim().min(1),
  nik: z.string().regex(/^\d{16}$/, 'NIK harus 16 digit'), phone: z.string().min(8), address: z.string().min(5),
  province: z.string().min(1), city: z.string().min(1), district: z.string().min(1), village: z.string().min(1),
  country: z.string().default('INDONESIA'), outlet_type: z.string().min(1), payment: z.enum(['CASH','CREDIT']), top: z.string().min(1),
  requested_credit_limit: z.coerce.number().nonnegative().default(0), latitude: z.number().finite(), longitude: z.number().finite(),
  gps_accuracy: z.number().nonnegative().max(10000).optional(), gps_captured_at: z.string().datetime(), gps_captured_by: z.string().uuid(), gps_source: z.enum(['BROWSER','MANUAL_SALESMAN']).default('BROWSER'), gps_reported_by: z.string().trim().optional(), gps_reported_at: z.string().datetime().optional(),
}).superRefine((v,ctx)=>{if(v.payment==='CREDIT'&&v.requested_credit_limit<=0)ctx.addIssue({code:'custom',path:['requested_credit_limit'],message:'Limit kredit wajib untuk tipe CREDIT'});if(v.payment==='CASH'&&v.requested_credit_limit!==0)ctx.addIssue({code:'custom',path:['requested_credit_limit'],message:'Pembayaran cash tidak boleh memiliki limit kredit'});if(v.gps_source==='MANUAL_SALESMAN'&&!v.gps_reported_by)ctx.addIssue({code:'custom',path:['gps_reported_by'],message:'Nama salesman pemberi koordinat wajib'});});

export const approvalSchema = z.object({ outlet_id: z.string().uuid(), decision: z.enum(['APPROVED','REVISION','REJECTED']), notes: z.string().trim().optional(), credit_limit: z.coerce.number().nonnegative().optional(), data_version: z.number().int().positive() }).superRefine((v, ctx) => {
  if (v.decision !== 'APPROVED' && !v.notes) ctx.addIssue({ code: 'custom', path: ['notes'], message: 'Catatan wajib untuk revisi atau penolakan' });
});

export function gpsQuality(accuracy: number) { return accuracy <= 20 ? 'GOOD' : accuracy <= 50 ? 'WARNING' : 'RETAKE'; }
