# Integracja na urządzeniu końcowym z systemem Windows

Najprostszym sposobem na instalację Listy w systemie Windows jest pobranie listy domen w formacie "hosts" i dopisanie jej zawartości do pliku `C:\Windows\System32\drivers\etc\hosts`. Aktualną listę można pobrać z adresu https://hole.cert.pl/domains/v2/domains_hosts.txt. Zgodnie z komentarzem w [README](../README.md), aktualizowanie wpisów ręcznie jest bezcelowe, rekomendujemy więc synchronizację listy automatycznie co 5 minut.

Dostarczamy w tym celu zestaw pomocniczych narzędzi opartych na skrypcie [CERTPL2Hosts](https://github.com/gtworek/PSBits/tree/master/CERTPL2Hosts) Grzegorza Tworka. Oba skrypty nie powinny działać jednocześnie - w celu instalacji skryptu CERT Polska należy odinstalować CERTPL2Hosts.

## Instalacja automatyczna

Najprostszą metodą instalacji jest uruchomienie skryptu [Install-CertListaToHosts.ps1](./Install-CertListaToHosts.ps1) jako użytkownik z prawami Administratora.

## Instalacja ręczna

Skrypt `Install-CertListaToHosts.ps1` ma dwa główne zadania:

* Pobiera skrypt `Update-CertListaToHosts.ps1` do folderu `C:\Windows\Program Files\`.
* Tworzy i konfiguruje Scheduled Task o nazwie `CertListaToHosts`. który cyklicznie uruchamia skrypt `Update-CertListaToHosts.ps1`

Oba te kroki można wykonać ręcznie:

* Należy pobrać skrypt z adresu [Update-CertListaToHosts.ps1](./Update-CertListaToHosts.ps1) i umieścić go w folderze `C:\Windows\Program Files\`.
  * Prawa do edycji pliku powinni mieć jedynie administratorzy. Jest to domyślne zachowanie w przypadku wrzucenia pliku do folderu jako administrator.
* Należy stworzyć scheduled task działający z prawami administratora wykonujący polecenie `powershell` z parametrem `-File "C:\Windows\Program Files\Update-CertListaToHosts.ps1"` co 5 minut.

## Weryfikacja instalacji

W celu weryfikacji, czy integracja działa prawidłowo, można odwiedzić stronę https://lista.cert.pl/ i sprawdzić czy przeglądarka poprawnie blokuje domeny wpisane na listę. 

## Rozwiązywanie problemów:

Jeśli weryfikacja nie powiodła się, w celu znalezienia problemu może pomóc:

* Otworzenie pliku `C:\Windows\System32\drivers\etc\hosts` edytorem tekstu i weryfikacja jego zawartości (po poprawnej instalacji powinien zawierać listę około 50 tysięcy domen, oraz linijkę `# CERT.PL's Warning List`)
* Upewnienie się, że plik `C:\Windows\Program Files\Update-CertListaToHosts.ps1` istnieje.
* Uruchomienie skryptu `C:\Windows\Program Files\Update-CertListaToHosts.ps1` ręcznie i sprawdzenie logów na standardowym wyjściu.
* Sprawdzenie logów Task Schedulera - w tym celu należy uruchomić UI Task Schedulera (np. kombinacją `Windows+r`, `taskschd.msc`, `enter`), znaleźć task `CertListaToHosts` i sprawdzić status taska.
* Jeśli problemy występują po instalacji automatycznej, pomóc może deinstalacja i dokonanie instalacji ręcznej.

W przypadku kiedy mimo wyczerpania prób naprawy narzędzie dalej nie działa, można rozważyć kontakt z zespołem CERT Polska opisując dotychczasowo podjęte kroki.

## Deinstalacja

W celu usunięcia integracji należy:

* Usunąć plik `C:\Windows\Program Files\Update-CertListaToHosts.ps1`
* Usunąć Scheduled Task za pomoca polecenia `Unregister-ScheduledTask -TaskName CertListaToHosts -Confirm:$false`.
* Usunąć istniejące wpisy w pliku `C:\Windows\System32\drivers\etc\hosts` za pomocą edytora tekstu.

## Uwagi

W celu instalacji Listy na poziomie organizacji, jednym z rozwiązań jest uruchomienie niniejszego skryptu na wszystkich komputerach w organizacji.
Natomiast rekomendowanym sposobem integracji Listy na poziomie organizacji jest skorzystanie z mechanizmu opisanego w [dedykowanym artykule](../WindowsDomain/README.md).
