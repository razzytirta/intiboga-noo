import {NextResponse} from 'next/server';
import {getAuthenticatedContext} from '../../../lib/supabase-auth';
export async function GET(){try{const {profile,admin}=await getAuthenticatedContext();if(!['ADMIN','IT'].includes(profile.role))return NextResponse.json({error:'Tidak berwenang'},{status:403});const {data,error}=await admin.from('noo_activity_logs').select('*').order('created_at',{ascending:false}).limit(200);if(error)throw error;return NextResponse.json({data});}catch(e){return NextResponse.json({error:e instanceof Error?e.message:'Audit gagal'},{status:400});}}
