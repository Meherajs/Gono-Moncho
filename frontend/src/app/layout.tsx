import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Header from "@/components/Header";
import { Providers } from "./providers";
import { ArticleProvider } from "@/context/ArticleContext"; // <-- IMPORT

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Gono Moncho",
  description: "A decentralized ecosystem for verifiable journalism.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <ArticleProvider> {/* <-- WRAP WITH ARTICLE PROVIDER */}
            <Header />
            {children}
          </ArticleProvider>
        </Providers>
      </body>
    </html>
  );
}