import type { NextConfig } from "next";

const apiInternalUrl = process.env.API_INTERNAL_URL || "http://localhost:3001";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/v1/:path*",
        destination: `${apiInternalUrl}/api/v1/:path*`,
      },
      {
        source: "/api/auth/:path*",
        destination: `${apiInternalUrl}/api/auth/:path*`,
      },
    ];
  },
};

export default nextConfig;
