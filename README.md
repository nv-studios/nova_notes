# 🌌 Nova_Notes Suite

An advanced, hybrid local/online terminal notes manager backed by a centralized **Node.js Server Core**. Nova_Notes allows you to create, save, read, and index documents completely **Offline (Local Mode)**, or securely sync them across machines over a network via an **Online Server IP Connection**.

---

## 🛠️ How the Network Ecosystem Works
1. **The Server Node (`server.js`):** Run natively using Node.js. It launches a lightweight local database listener and displays a status dashboard website inside your web browser (`http://localhost:3000`).
2. **The Terminal Clients:** Users open `nova_notes.bat` (Windows) or `nova_notes.sh` (Linux). On launch, they choose whether to operate completely standalone offline, or type in a target hosting IP address to pull notes straight from the server cloud storage directory.

---

## 🚀 Step-by-Step Server Setup Guide

### 1. Install Node.js Dependencies
Before running the online server, ensure Node.js is active on the hosting system:
- **Windows:** Download the installer wrapper from `nodejs.org`.
- **Linux (ThinkPad):** Execute `sudo apt install nodejs npm` in your terminal shell.

### 2. Deploy and Launch Server Core
1. Create a folder named `NovaNotes_Server` and save `server.js` inside it.
2. Open your terminal or command prompt inside that folder and execute:
   ```bash
   node server.js
   ```
3. Open your browser and navigate to: `http://localhost:3000`
4. The website will display: **"Your Nova Notes Server is Active"** and show you the exact command strings your clients need to type to hook up to your workspace!
