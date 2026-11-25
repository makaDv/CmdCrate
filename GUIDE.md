# CmdCrate - User guide / Guida all'uso

[Italiano](#italiano) · [English](#english)

---

## Italiano

### 1. Avviare CmdCrate

**Metodo rapido (consigliato)**

1. Premi `Win + X` e scegli **Terminale** oppure **Windows PowerShell**. Non servono permessi di amministratore.
2. Incolla questo comando e premi Invio:
   ```powershell
   irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1 | iex
   ```
3. Il comando scarica CmdCrate, ne verifica l'integrità (SHA256) e apre la finestra.

**Metodo manuale (senza comando online)**

1. Su GitHub premi **Code > Download ZIP** ed estrai la cartella.
2. Apri PowerShell nella cartella estratta ed esegui:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\CmdCrate.ps1
   ```

### 2. La finestra

| Zona | A cosa serve |
|---|---|
| **Cerca** | Filtra le app per nome, ID o descrizione. |
| **Seleziona tutto / Deseleziona tutto** | Spunta o toglie tutte le app visibili. |
| **Consigliate** | Seleziona le app segnate con ★ che non hai ancora installato. |
| **tutte / nessuna** (accanto a ogni categoria) | Seleziona o deseleziona solo quella categoria. |
| **✓ installata** | L'app è già presente sul PC. |
| **sito** | Apre il sito ufficiale dell'app nel browser. |
| Barra e riquadro scuro in basso | Avanzamento e log di quello che sta succedendo. |

### 3. Installare le app

1. Spunta le app che vuoi (in basso a destra vedi quante ne hai selezionate).
2. Premi **Installa selezionate**.
3. Leggi la conferma: ogni app ha la sua licenza (EULA). Premi **Sì** per accettarle e procedere.
4. Le app vengono installate una alla volta. Accanto a ognuna compare l'esito:
   - **installata**: tutto ok;
   - **già installata / aggiornata**: era già presente;
   - **installata, serve un riavvio**: riavvia il PC alla fine;
   - **errore (codice ...)**: vedi la sezione [Problemi comuni](#6-problemi-comuni).
5. Alcuni installer mostrano la richiesta di Windows (UAC): premi **Sì** per continuare.
6. Per interrompere premi **Ferma dopo la corrente**: l'app in corso finisce, le altre vengono saltate.

### 4. Prima e dopo un reset del PC

**Prima del reset**, sul PC vecchio:
1. Avvia CmdCrate.
2. Premi **Esporta app installate...** e salva il file (es. `le-mie-app.export.json`).
3. Copia il file su una chiavetta USB o sul cloud.

**Dopo il reset**, sul PC nuovo:
1. Avvia CmdCrate con il metodo rapido.
2. Premi **Importa lista...** e scegli il file salvato.
3. Le app del file risultano spuntate. Quelle che non sono nel catalogo compaiono nella categoria **Importate**.
4. Controlla la selezione e premi **Installa selezionate**.

In alternativa, **Salva selezione...** salva solo le app spuntate in quel momento: utile per preparare un "kit" da riusare su più PC.

> Il file esportato contiene l'elenco delle tue app. Non pubblicarlo se non vuoi renderlo noto.

### 5. Uso da riga di comando (avanzato)

```powershell
.\CmdCrate.ps1 -Apps 7zip.7zip,VideoLAN.VLC        # installa queste app senza finestra
.\CmdCrate.ps1 -Import .\le-mie-app.export.json    # installa le app di un file esportato
.\CmdCrate.ps1 -Apps 7zip.7zip -WhatIf              # mostra cosa farebbe, senza installare
.\CmdCrate.ps1 -Apps 7zip.7zip -AcceptPackageAgreements   # nessuna domanda (accetti le licenze in anticipo)
.\CmdCrate.ps1 -Language en                         # interfaccia in inglese
.\CmdCrate.ps1 -NoLog                               # non scrive il file di log
Get-Help .\CmdCrate.ps1 -Full                       # guida completa dei parametri
```

Per trovare l'ID di un'app: `winget search <nome>`.

### 6. Problemi comuni

| Problema | Soluzione |
|---|---|
| Si apre il Microsoft Store invece di CmdCrate | Manca winget. Installa **Programma di installazione app** dallo Store e riavvia CmdCrate. |
| "Integrity check failed" | Download incompleto o file aggiornati proprio in quel momento. Riprova tra un minuto. |
| "esecuzione di script disabilitata" con il metodo manuale | Usa il comando con `-ExecutionPolicy Bypass` indicato sopra, oppure esegui `Unblock-File .\CmdCrate.ps1`. |
| **non trovata in winget** | L'ID non esiste più o è cambiato. Cerca l'app con `winget search <nome>`. |
| **errore (codice ...)** | Riprova dopo un riavvio. Alcune app richiedono di chiudere versioni aperte. Dettagli nel log. |
| La finestra non si apre | Serve Windows 10 1809 o successivo. Prova il metodo manuale per vedere l'errore. |

### 7. Log e dati locali

- **Apri cartella log** apre `%LOCALAPPDATA%\CmdCrate\logs`. I log non contengono nome utente, nome del PC o percorso del profilo e si cancellano dopo 30 giorni.
- **Elimina dati locali** cancella tutta la cartella `%LOCALAPPDATA%\CmdCrate`.
- Per rimuovere CmdCrate basta eliminare lo script (o la cartella estratta) e premere **Elimina dati locali**. Le app installate restano: si disinstallano da **Impostazioni > App** o con `winget uninstall --id <ID> -e`.

Maggiori dettagli: [PRIVACY.md](PRIVACY.md).

---

## English

### 1. Start CmdCrate

**Quick method (recommended)**

1. Press `Win + X` and choose **Terminal** or **Windows PowerShell**. No administrator rights needed.
2. Paste this command and press Enter:
   ```powershell
   irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1 | iex
   ```
3. The command downloads CmdCrate, checks its integrity (SHA256) and opens the window.

**Manual method (no online command)**

1. On GitHub press **Code > Download ZIP** and extract the folder.
2. Open PowerShell in the extracted folder and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\CmdCrate.ps1
   ```

### 2. The window

| Area | Purpose |
|---|---|
| **Search** | Filters apps by name, ID or description. |
| **Select all / Select none** | Ticks or unticks every visible app. |
| **Recommended** | Selects the ★ apps that are not installed yet. |
| **all / none** (next to each category) | Selects or clears that category only. |
| **✓ installed** | The app is already on this PC. |
| **website** | Opens the app's official website. |
| Bar and dark box at the bottom | Progress and a log of what is happening. |

### 3. Install apps

1. Tick the apps you want (the count is shown bottom right).
2. Press **Install selected**.
3. Read the confirmation: each app has its own license (EULA). Press **Yes** to accept and continue.
4. Apps are installed one at a time. Each shows a result:
   - **installed**: all good;
   - **already installed / up to date**: it was already there;
   - **installed, restart required**: restart the PC at the end;
   - **failed (code ...)**: see [Common problems](#6-common-problems).
5. Some installers show the Windows prompt (UAC): press **Yes** to continue.
6. To stop, press **Stop after current**: the running app finishes, the rest are skipped.

### 4. Before and after a PC reset

**Before the reset**, on the old PC:
1. Start CmdCrate.
2. Press **Export installed apps...** and save the file (e.g. `my-apps.export.json`).
3. Copy the file to a USB drive or cloud storage.

**After the reset**, on the new PC:
1. Start CmdCrate with the quick method.
2. Press **Import list...** and choose the saved file.
3. The apps from the file are ticked. Apps not in the catalog appear under **Imported**.
4. Check the selection and press **Install selected**.

**Save selection...** stores only the apps ticked right now: handy for a reusable "kit" for several PCs.

> The exported file lists your apps. Do not publish it if you want to keep that private.

### 5. Command line (advanced)

```powershell
.\CmdCrate.ps1 -Apps 7zip.7zip,VideoLAN.VLC        # install these apps without the window
.\CmdCrate.ps1 -Import .\my-apps.export.json       # install the apps from an export file
.\CmdCrate.ps1 -Apps 7zip.7zip -WhatIf              # show what would happen, install nothing
.\CmdCrate.ps1 -Apps 7zip.7zip -AcceptPackageAgreements   # no prompt (accept licenses in advance)
.\CmdCrate.ps1 -Language it                         # Italian UI
.\CmdCrate.ps1 -NoLog                               # do not write a log file
Get-Help .\CmdCrate.ps1 -Full                       # full parameter help
```

To find an app's ID: `winget search <name>`.

### 6. Common problems

| Problem | Fix |
|---|---|
| The Microsoft Store opens instead of CmdCrate | winget is missing. Install **App Installer** from the Store and start CmdCrate again. |
| "Integrity check failed" | Incomplete download, or files updated at that moment. Try again in a minute. |
| "running scripts is disabled" with the manual method | Use the `-ExecutionPolicy Bypass` command above, or run `Unblock-File .\CmdCrate.ps1`. |
| **not found in winget** | The ID no longer exists or changed. Search with `winget search <name>`. |
| **failed (code ...)** | Retry after a restart. Some apps need open copies closed first. Details in the log. |
| The window does not open | Windows 10 1809 or newer is required. Use the manual method to see the error. |

### 7. Logs and local data

- **Open log folder** opens `%LOCALAPPDATA%\CmdCrate\logs`. Logs contain no user name, PC name or profile path and are deleted after 30 days.
- **Delete local data** removes the whole `%LOCALAPPDATA%\CmdCrate` folder.
- To remove CmdCrate, delete the script (or extracted folder) and press **Delete local data**. Installed apps stay: uninstall them from **Settings > Apps** or with `winget uninstall --id <ID> -e`.

More details: [PRIVACY.md](PRIVACY.md).
