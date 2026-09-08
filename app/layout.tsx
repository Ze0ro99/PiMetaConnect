import { SpeedInsights } from "@vercel/speed-insights/next";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <title>PiMetaConnect</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </head>
      <body>
        {children}
        {/* Add Vercel Speed Insights for performance tracking */}
        <SpeedInsights />
      </body>
    </html>
  );
}
