import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { getSupabaseServer } from './supabase';

export async function getAuthenticatedContext(){
  const url=process.env.NEXT_PUBLIC_SUPABASE_URL; const key=process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if(!url||!key) throw new Error('Supabase belum dikonfigurasi');
  const cookieStore=await cookies();
  const client=createServerClient(url,key,{cookies:{getAll:()=>cookieStore.getAll(),setAll:(items)=>{try{items.forEach(({name,value,options})=>cookieStore.set(name,value,options))}catch{}}}});
  const {data:{user},error}=await client.auth.getUser(); if(error||!user) throw new Error('Sesi login tidak valid');
  const admin=getSupabaseServer(); const {data:profile}=await admin.from('profiles').select('*').eq('id',user.id).single();
  if(!profile?.is_active) throw new Error('User tidak aktif'); return {user,profile,admin};
}
