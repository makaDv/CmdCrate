# Privacy Policy / Informativa sulla privacy

_Last updated / Ultimo aggiornamento: 2026-11-25_

[English](#english) · [Italiano](#italiano)

## English

### Summary

CmdCrate is a local PowerShell script. **It does not collect, store remotely, share or sell any personal data.** It has no telemetry, analytics, crash reporting, accounts or cookies. The maintainers receive no information about you or your PC.

Because CmdCrate processes no personal data on behalf of its maintainers, the maintainers are not a data controller under the EU General Data Protection Regulation (GDPR, Regulation (EU) 2016/679) for your use of the tool.

### Data that stays on your PC

| Data | Where | Why | How long |
|---|---|---|---|
| Activity log (which apps were installed, results, errors) | `%LOCALAPPDATA%\CmdCrate\logs` | Troubleshooting | Deleted automatically after 30 days |
| Temporary list of installed apps | `%TEMP%`, random file name | Mark already-installed apps in the list | Deleted right after it is read |
| Export / selection files | Only where **you** choose to save them | Reinstall the same apps later | Until you delete them |

Before a line is written to the log, CmdCrate replaces your Windows user name, computer name and profile path with placeholders.

You stay in control:
- **Delete local data** button: removes the whole `%LOCALAPPDATA%\CmdCrate` folder.
- `-NoLog` parameter: writes no log file.
- Uninstall: delete the script and the folder above. Nothing else is left behind by CmdCrate.

### Third parties

CmdCrate itself makes no network requests except the download of its own files from GitHub when you use the one-line installer. When you install apps, these services are used by Windows and by the installers, under their own privacy policies:

- **GitHub** (download of CmdCrate files): [GitHub Privacy Statement](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement)
- **Microsoft winget / App Installer** (package catalog and downloads): [Microsoft Privacy Statement](https://privacy.microsoft.com/privacystatement). winget may send its own telemetry; you can turn it off in winget settings (`winget settings`, `"telemetry": { "disable": true }`).
- **App publishers**: each app you choose is downloaded from its publisher and is covered by that publisher's license and privacy policy.

### Your rights

Since no personal data reaches the maintainers, there is nothing for them to access, correct or delete. All data listed above is on your own device and under your control. For questions, open an issue on GitHub: https://github.com/makaDv/CmdCrate/issues (do not post personal data in public issues).

### Children

CmdCrate is a general-purpose system tool and collects no data from anyone, including children.

### Changes

Changes to this policy are published in this file and visible in the repository history.

---

## Italiano

### In sintesi

CmdCrate è uno script PowerShell che gira in locale. **Non raccoglie, non invia, non condivide e non vende dati personali.** Non ha telemetria, analytics, segnalazione crash, account o cookie. I manutentori non ricevono alcuna informazione su di te o sul tuo PC.

Poiché CmdCrate non tratta dati personali per conto dei manutentori, questi non sono titolari del trattamento ai sensi del Regolamento (UE) 2016/679 (GDPR) per l'uso che fai dello strumento.

### Dati che restano sul tuo PC

| Dato | Dove | Perché | Per quanto |
|---|---|---|---|
| Log attività (app installate, esiti, errori) | `%LOCALAPPDATA%\CmdCrate\logs` | Risoluzione problemi | Cancellato automaticamente dopo 30 giorni |
| Elenco temporaneo app installate | `%TEMP%`, nome casuale | Segnare le app già installate | Cancellato subito dopo la lettura |
| File di esportazione / selezione | Solo dove **tu** scegli di salvarli | Reinstallare le stesse app | Finché non li elimini |

Prima di scrivere nel log, CmdCrate sostituisce nome utente Windows, nome del computer e percorso del profilo con segnaposto (minimizzazione dei dati, art. 5 GDPR).

Hai il pieno controllo:
- pulsante **Elimina dati locali**: rimuove l'intera cartella `%LOCALAPPDATA%\CmdCrate`;
- parametro `-NoLog`: nessun file di log;
- disinstallazione: elimina lo script e la cartella indicata. Non resta nient'altro.

### Terze parti

CmdCrate non effettua richieste di rete, salvo il download dei propri file da GitHub quando usi il comando di installazione rapida. Durante l'installazione delle app intervengono, con le proprie informative:

- **GitHub** (download dei file di CmdCrate): [Informativa GitHub](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement)
- **Microsoft winget / Programma di installazione app**: [Informativa Microsoft](https://privacy.microsoft.com/privacystatement). winget può inviare telemetria propria; puoi disattivarla nelle impostazioni di winget (`winget settings`, `"telemetry": { "disable": true }`).
- **Produttori delle app**: ogni app scelta viene scaricata dal suo produttore ed è soggetta alla sua licenza e informativa.

### I tuoi diritti

Nessun dato personale arriva ai manutentori, quindi non c'è nulla da consultare, rettificare o cancellare presso di loro (artt. 15-22 GDPR). Tutti i dati elencati sono sul tuo dispositivo e sotto il tuo controllo. Per domande apri una issue su GitHub: https://github.com/makaDv/CmdCrate/issues (non inserire dati personali nelle issue pubbliche).

### Modifiche

Le modifiche a questa informativa sono pubblicate in questo file e visibili nella cronologia del repository.
