{
  "version": 2,
  "builds": [
    {
      "src": "index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/validation-key.txt",
      "dest": "/public/validation-key.txt"
    },
    {
      "src": "/privacy-policy",
      "dest": "/public/privacy-policy.html"
    },
    {
      "src": "/terms-of-service",
      "dest": "/public/terms-of-service.html"
    },
    {
      "src": "/api/(.*)",
      "dest": "index.js"
    },
    {
      "src": "/(.*)",
      "dest": "client/build/index.html"
    }
  ]
}