import { NextResponse } from 'next/server';
export async function GET(){return NextResponse.json({app:'NOO Intiboga',status:'ok',supabaseConfigured:Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY),templateColumns:87,privateBucket:'noo-private'});}
