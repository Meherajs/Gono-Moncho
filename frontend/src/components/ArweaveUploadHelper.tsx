"use client";

import { useState } from "react";
import { useToast } from "@/context/ToastContext";

interface ArweaveUploadProps {
  onUploadComplete?: (hash: string, metadata: any) => void;
}

export default function ArweaveUploadHelper({ onUploadComplete }: ArweaveUploadProps) {
  const [uploading, setUploading] = useState(false);
  const [uploadedHash, setUploadedHash] = useState("");
  const { showToast } = useToast();

  const handleFileUpload = async (file: File) => {
    setUploading(true);
    try {
      // For now, we'll simulate Arweave upload with a mock hash
      // In production, you would integrate with Arweave's upload API
      
      // Read file content
      const content = await file.text();
      
      // Generate a mock IPFS/Arweave hash
      const mockHash = `Qm${Math.random().toString(36).substring(2, 15)}${Math.random().toString(36).substring(2, 15)}`;
      
      // In production, you would do something like:
      // const formData = new FormData();
      // formData.append('file', file);
      // const response = await fetch('/api/arweave/upload', {
      //   method: 'POST',
      //   body: formData
      // });
      // const { hash, metadata } = await response.json();
      
      const metadata = {
        filename: file.name,
        size: file.size,
        type: file.type,
        uploadedAt: new Date().toISOString(),
        content: content.substring(0, 500) // Preview
      };

      setUploadedHash(mockHash);
      showToast("File uploaded successfully!", "success");
      
      if (onUploadComplete) {
        onUploadComplete(mockHash, metadata);
      }
    } catch (error) {
      console.error("Upload error:", error);
      showToast("Upload failed. Please try again.", "error");
    } finally {
      setUploading(false);
    }
  };

  const handleJSONUpload = async (jsonData: object) => {
    setUploading(true);
    try {
      // Convert JSON to string
      const jsonString = JSON.stringify(jsonData, null, 2);
      
      // Generate mock hash
      const mockHash = `Qm${Math.random().toString(36).substring(2, 15)}${Math.random().toString(36).substring(2, 15)}`;
      
      const metadata = {
        type: 'application/json',
        size: jsonString.length,
        uploadedAt: new Date().toISOString(),
        content: jsonData
      };

      setUploadedHash(mockHash);
      showToast("Metadata uploaded successfully!", "success");
      
      if (onUploadComplete) {
        onUploadComplete(mockHash, metadata);
      }
    } catch (error) {
      console.error("Upload error:", error);
      showToast("Upload failed. Please try again.", "error");
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">📤 Arweave Upload Helper</h2>
      <p className="text-gray-600 mb-6">
        Upload files to decentralized storage (Arweave/IPFS) for permanent, censorship-resistant storage.
      </p>

      <div className="space-y-4">
        {/* File Upload */}
        <div className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-400 transition">
          <label className="cursor-pointer block text-center">
            <input
              type="file"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleFileUpload(file);
              }}
              className="hidden"
              disabled={uploading}
              accept=".txt,.md,.json,.pdf,.jpg,.png"
            />
            <div className="py-4">
              <svg
                className="mx-auto h-12 w-12 text-gray-400"
                stroke="currentColor"
                fill="none"
                viewBox="0 0 48 48"
              >
                <path
                  d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
              <p className="mt-2 text-sm text-gray-600">
                {uploading ? "Uploading..." : "Click to upload file or drag and drop"}
              </p>
              <p className="text-xs text-gray-500">
                Supported: TXT, MD, JSON, PDF, JPG, PNG
              </p>
            </div>
          </label>
        </div>

        {/* Upload Result */}
        {uploadedHash && (
          <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
            <p className="text-sm font-semibold text-green-800 mb-2">✅ Upload Successful</p>
            <div className="flex items-center gap-2">
              <code className="flex-1 px-3 py-2 bg-white rounded text-sm font-mono break-all">
                {uploadedHash}
              </code>
              <button
                onClick={() => {
                  navigator.clipboard.writeText(uploadedHash);
                  showToast("Hash copied to clipboard!", "success");
                }}
                className="px-3 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
              >
                Copy
              </button>
            </div>
            <p className="text-xs text-green-700 mt-2">
              Use this hash when publishing articles or registering credentials
            </p>
          </div>
        )}

        {/* Info Section */}
        <div className="mt-6 bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold text-gray-800 mb-2">ℹ️ About Decentralized Storage</h3>
          <ul className="text-sm text-gray-700 space-y-1">
            <li>• <strong>Arweave:</strong> Permanent, pay-once storage solution</li>
            <li>• <strong>IPFS:</strong> Content-addressed distributed file system</li>
            <li>• <strong>Censorship-resistant:</strong> Files cannot be taken down</li>
            <li>• <strong>Verifiable:</strong> Content hash ensures integrity</li>
            <li>• <strong>Use cases:</strong> Article content, credentials, evidence</li>
          </ul>
        </div>

        {/* Integration Note */}
        <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
          <p className="text-sm text-yellow-800">
            <strong>🔧 Development Mode:</strong> Currently generating mock hashes. 
            In production, this will integrate with Arweave/IPFS upload services.
          </p>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => {
              const sampleData = {
                name: "Sample Reporter",
                organization: "Independent",
                experience: "5 years",
                credentials: "Press badge #12345"
              };
              handleJSONUpload(sampleData);
            }}
            disabled={uploading}
            className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50 text-sm"
          >
            Upload Sample Credentials
          </button>
          <button
            onClick={() => {
              const sampleArticle = {
                title: "Sample Article",
                content: "This is sample article content...",
                author: "Reporter Name",
                timestamp: new Date().toISOString()
              };
              handleJSONUpload(sampleArticle);
            }}
            disabled={uploading}
            className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50 text-sm"
          >
            Upload Sample Article
          </button>
        </div>
      </div>

      {/* How to Use */}
      <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <h3 className="font-semibold text-blue-800 mb-2">📖 How to Use</h3>
        <ol className="text-sm text-blue-700 space-y-1 list-decimal list-inside">
          <li>Upload your file or JSON data</li>
          <li>Copy the generated hash</li>
          <li>Use the hash when registering or publishing</li>
          <li>The content is stored permanently and verifiably</li>
        </ol>
      </div>
    </div>
  );
}
