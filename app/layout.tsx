import './globals.css';
import RegisterSW from './register-sw';
export const metadata = { title: 'NOO Intiboga', description: 'New Outlet Opening Management System' };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="id"><body><RegisterSW />{children}</body></html>; }
