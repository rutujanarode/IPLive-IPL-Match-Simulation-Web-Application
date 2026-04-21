# IPLive Build Instructions

## IMPORTANT: Always run Maven from the project root directory!

### Project Structure:
```
C:\Users\hp\OneDrive\Desktop\IPLive\  <-- PROJECT ROOT (run Maven here)
├── pom.xml                           <-- Maven configuration
├── build.bat                         <-- Windows build script
├── build.ps1                         <-- PowerShell build script
├── src/
│   └── main/java/com/iplive/...      <-- Source code (DO NOT run Maven here)
└── target/                           <-- Build output
```

### How to Build:

#### Option 1: Use build scripts (Easiest)
- Double-click `build.bat` (Windows)
- Or run `.\build.ps1` (PowerShell)

#### Option 2: Command line
```bash
cd C:\Users\hp\OneDrive\Desktop\IPLive
mvn clean install
```

#### Option 3: Specify POM path
```bash
mvn clean install -f C:\Users\hp\OneDrive\Desktop\IPLive\pom.xml
```

### Common Mistake to Avoid:
❌ WRONG: Running from `C:\Users\hp\OneDrive\Desktop\IPLive\src\main\java\com\iplive`
✅ RIGHT: Running from `C:\Users\hp\OneDrive\Desktop\IPLive`

### Build Output:
- WAR file: `target/IPLive.war`
- Status: BUILD SUCCESS