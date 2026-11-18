import type { MetadataRoute } from 'next';
export default function manifest(): MetadataRoute.Manifest { return { name: 'NOO Intiboga', short_name: 'NOO', description: 'New Outlet Opening Management System', start_url: '/', display: 'standalone', background_color: '#f7f8fa', theme_color: '#102a2d' }; }
