# CmdCrate

**Reinstall all your Windows apps with one command, choosing them from a GUI.**
**Reinstalla tutte le tue app Windows con un solo comando, scegliendole da un'interfaccia grafica.**

[English](#english) · [Italiano](#italiano) · **[User guide / Guida all'uso](GUIDE.md)**

![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue) ![Windows 10/11](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6) ![License: MIT](https://img.shields.io/badge/License-MIT-green) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen)

---

## English

### Quick start

Open **PowerShell** (no admin needed) and run:

```powershell
irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1 | iex
```

A window opens with apps grouped by category. Tick what you want, press **Install selected**, done.
Nothing is installed until you press the button and confirm.

> **Inspect before you run.** Piping a script from the internet into `iex` runs it right away.
> You can read [`install.ps1`](install.ps1) and [`CmdCrate.ps1`](CmdCrate.ps1) first, or download the repository and run `.\CmdCrate.ps1` locally.

Pin a specific release instead of `main`:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1))) -Ref v1.0.1
```

### Features

- **GUI** (WPF, built into Windows): categories, search, select all/none per category, link to each app's official website.
- **Recommended** (★): one click selects the recommended apps that are not installed yet.
- **No admin needed**: run CmdCrate as a normal user; installers that need it ask for UAC on their own.
- **Already-installed detection**: apps already on your PC are marked ✓.
- **Export / Import**: export the apps installed on your current PC to a JSON file (`winget export`), then import it after a reset to preselect the same apps. Apps not in the catalog are added under "Imported".
- **Save selection** to a file to reuse it on other PCs.
- **Command-line mode**:
  ```powershell
  .\CmdCrate.ps1 -Apps 7zip.7zip,VideoLAN.VLC         # install without GUI
  .\CmdCrate.ps1 -Import .\my-apps.export.json         # install from an export file
  .\CmdCrate.ps1 -Apps 7zip.7zip -WhatIf               # preview only
  ```
  Before installing, the command line asks you to confirm that you accept the apps' licenses.
  For unattended use, add `-AcceptPackageAgreements` to give that consent in advance.
- **Italian / English** UI, chosen from your Windows language (`-Language it|en` to force).

### Requirements

- Windows 10 1809 or newer, or Windows 11
- [winget / App Installer](https://apps.microsoft.com/detail/9NBLGGH4NNS1) (preinstalled on recent Windows; CmdCrate opens the Store page if it is missing)
- Windows PowerShell 5.1 (built in) or PowerShell 7

### Privacy and security

- **No telemetry, no accounts, no data collection.** See [PRIVACY.md](PRIVACY.md).
- Apps come only from the official `winget` source, matched by exact ID (`--exact --source winget`).
- Package IDs are validated before use, so a crafted catalog or import file cannot inject commands.
- `install.ps1` checks the SHA256 of the downloaded files against [`checksums.txt`](checksums.txt) and stops on a mismatch. This protects against corrupted or partial downloads; it is not a substitute for reading the code.
- Local log: `%LOCALAPPDATA%\CmdCrate\logs`, without user name, PC name or profile path, deleted after 30 days. Use **Delete local data** in the app or `-NoLog` to write none.
- Report vulnerabilities as described in [SECURITY.md](SECURITY.md).

### App licenses

CmdCrate only automates `winget`. Every app keeps its own license and terms (EULA), which you accept when you install it (`--accept-package-agreements`). CmdCrate is not affiliated with Microsoft or any listed publisher; names and trademarks belong to their owners.

### Disclaimer

CmdCrate is free software provided "as is", without warranty of any kind (see [LICENSE](LICENSE)). You use it at your own risk. You are responsible for checking and respecting the license of every app you install, and for how you use it. CmdCrate does not host, modify or redistribute any third-party software: apps are downloaded by winget from the sources listed in the Microsoft winget repository. The catalog is a convenience list, not an endorsement.

### Add an app to the catalog

Edit [`apps.json`](apps.json), add an entry with a valid winget ID (check it with `winget show --id <ID> -e`), run `.\tools\Update-Checksums.ps1`, and open a pull request.

```json
{ "id": "Publisher.App", "name": "App", "description": "What it does", "homepage": "https://example.com/", "default": false }
```

---

## Italiano

### Avvio rapido

Apri **PowerShell** (non servono permessi di amministratore) ed esegui:

```powershell
irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1 | iex
```

Si apre una finestra con le app divise per categoria. Spunta quelle che vuoi, premi **Installa selezionate** e conferma.
Nulla viene installato finché non premi il pulsante.

> **Controlla prima di eseguire.** Il comando `irm ... | iex` esegue subito lo script scaricato.
> Puoi leggere prima [`install.ps1`](install.ps1) e [`CmdCrate.ps1`](CmdCrate.ps1), oppure scaricare il repository ed eseguire `.\CmdCrate.ps1` in locale.

Per usare una versione precisa invece di `main`:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1))) -Ref v1.0.1
```

### Funzionalità

- **Interfaccia grafica** (WPF, inclusa in Windows): categorie, ricerca, seleziona tutte/nessuna per categoria, link al sito ufficiale di ogni app.
- **Consigliate** (★): un clic seleziona le app consigliate non ancora installate.
- **Nessun permesso di amministratore richiesto**: gli installer che ne hanno bisogno chiedono l'UAC da soli.
- **Rilevamento app già installate**: segnate con ✓.
- **Esporta / Importa**: esporta le app installate sul PC attuale in un file JSON (`winget export`) e reimportalo dopo un reset per preselezionare le stesse app. Le app non presenti nel catalogo finiscono in "Importate".
- **Salva selezione** su file per riusarla su altri PC.
- **Modalità riga di comando**: vedi gli esempi nella sezione inglese (`-Apps`, `-Import`, `-WhatIf`). Prima di installare chiede conferma dell'accettazione delle licenze; `-AcceptPackageAgreements` la dà in anticipo.
- Interfaccia **italiano / inglese** in base alla lingua di Windows (`-Language it|en` per forzarla).

### Privacy e sicurezza (GDPR)

- **Nessuna telemetria, nessun account, nessun dato raccolto.** Dettagli in [PRIVACY.md](PRIVACY.md).
- Le app arrivano solo dalla sorgente ufficiale `winget`, con ID esatto.
- Gli ID dei pacchetti sono validati: un catalogo o un file importato manomesso non può iniettare comandi.
- `install.ps1` verifica lo SHA256 dei file scaricati con [`checksums.txt`](checksums.txt) e si ferma se non corrispondono.
- Log locale in `%LOCALAPPDATA%\CmdCrate\logs`, senza nome utente, nome PC o percorso del profilo, cancellato dopo 30 giorni. Pulsante **Elimina dati locali** oppure `-NoLog` per non scriverlo.
- Segnalazione vulnerabilità: [SECURITY.md](SECURITY.md).

### Licenze delle app

CmdCrate automatizza soltanto `winget`. Ogni app ha la propria licenza (EULA), che accetti al momento dell'installazione. CmdCrate non è affiliato a Microsoft né ai produttori elencati; nomi e marchi appartengono ai rispettivi titolari.

### Esclusione di responsabilità

CmdCrate è software gratuito fornito "così com'è", senza garanzie di alcun tipo (vedi [LICENSE](LICENSE)). Lo usi a tuo rischio. Sei responsabile di verificare e rispettare la licenza di ogni app che installi e dell'uso che ne fai. CmdCrate non ospita, non modifica e non ridistribuisce software di terze parti: le app vengono scaricate da winget dalle fonti indicate nel repository ufficiale Microsoft winget. Il catalogo è un elenco di comodità, non una raccomandazione commerciale.

---

## License

[MIT](LICENSE)
