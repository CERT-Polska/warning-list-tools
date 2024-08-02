# Integracja Listy na poziomie Domeny Active Directory

Z uwagi na różnorodność środowisk i konfiguracji, nie ma jednego sposobu na integrację listy na poziomie organizacji.

Jeśli organizacja korzysta z zewnętrznych urządzeń filtrujących ruch sieciowy albo działających jako serwer DNS, prawdopodobnie można dokonać integracji na tym poziomie. Pomocna może okazać się tutaj instrukcja [integracji z zewnętrznymi rozwiązaniami](../ThirdParty/). 

Istnieje też możliwość blokowania domen bezpośrednio na poziomie serwera DNS wbudowanego w Active Directory. Niniejszy skrypt
wykorzystuje fakt, że w większości instalacji domen Windowsowych serwer DNS jest wspólny dla wszystkich urządzeń i zarządzany centralnie. W szczególności,
**warunkiem działania skryptu jest to, żeby domenowy serwer DNS był ustawiony jako jedyny resolver DNS na wszystkich komputerach użytkowników**.

## Instalacja automatyczna

Najprostszą metodą instalacji jest pobranie i uruchomienie skryptu [Install-CertListaToDnsPolicy.ps1](./Install-CertListaToDnsPolicy.ps1) na kontrolerze domeny, jako użytkownik z prawami Administratora Domeny.

## Instalacja ręczna

Skrypt `Install-CertListaToDnsPolicy.ps1` ma dwa główne zadania:

* Pobiera skrypt `Update-CertListaToDnsPolicy.ps1` do folderu `C:\Windows\Program Files\`.
* Tworzy i konfiguruje Scheduled Task o nazwie `CertListaToDnsPolicy`. który cyklicznie uruchamia skrypt `Update-CertListaToDnsPolicy.ps1`

Oba te kroki można wykonać ręcznie:

* Należy pobrać skrypt [Update-CertListaToDnsPolicy.ps1](./Update-CertListaToDnsPolicy.ps1) i umieścić go w folderze `C:\Windows\Program Files\`.
  * Prawa do edycji pliku powinni mieć jedynie administratorzy. Jest to domyślne zachowanie w przypadku umieszczenia pliku w folderze jako administrator.
* Należy stworzyć scheduled task działający z prawami administratora wykonujący polecenie `powershell` z parametrem `-File "C:\Windows\Program Files\Update-CertListaToDnsPolicy.ps1"` co 5 minut.

## Weryfikacja instalacji

W celu weryfikacji, czy integracja działa prawidłowo, można odwiedzić stronę https://lista.cert.pl/ i sprawdzić czy przeglądarka poprawnie blokuje domeny wpisane na listę.

Weryfikację należy przeprowadzić niezależnie z kilku komputerów w organizacji.

## Rozwiązywanie problemów:

Jeśli weryfikacja nie powiodła się, w celu znalezienia problemu może pomóc:

* Odczekanie chwili - pierwsze uruchomienie synchronizacji może potrwać trochę dłużej, z uwagi na dużą listę polityk które należy stworzyć (kolejne wykonania są znacznie szybsze).
* Uruchomienie polecenia `ipconfig /flushdns`, w celu upewnienia się że adres złośliwej domeny nie znajduje się w lokalnym cache DNS.
* Upewnienie się, że plik `C:\Windows\Program Files\Update-CertListaToDnsPolicy.ps1` istnieje.
* Uruchomienie skryptu `C:\Windows\Program Files\Update-CertListaToDnsPolicy.ps1` ręcznie i sprawdzenie logów na standardowym wyjściu.
* Sprawdzenie logów Task Schedulera - w tym celu należy uruchomić interfejs Task Schedulera (np. kombinacją `Windows+r`, `taskschd.msc`, `enter`), znaleźć task `CertListaToHosts` i sprawdzić status taska.
* Przejrzenie istniejących polityk: można w tym celu wykonać powershellowe polecenie `Get-DnsServerQueryResolutionPolicy | Where-Object { $_.Name.Startswith("CERTPL_") }`. Wynikiem powinna być długa na około 50 tysięcy domen lista polityk.
* Sprawdzenie, czy jedynymi skonfigurowanymi resolverami DNS na komputerach użytkowników są serwery AD. W tym celu można wykonać polecenie `ipconfig /all` i upewnić się że wszystkie wpisy w `DNS Servers` kierują na serwery domeny. W szczególności, wpisy np. `1.1.1.1` albo `8.8.8.8` oznaczają że blokowanie *nie* będzie działać poprawnie.

W przypadku kiedy mimo wyczerpania prób naprawy narzędzie dalej nie działa, można rozważyć kontakt z zespołem CERT Polska opisując dotychczasowo podjęte kroki.

## Deinstalacja

W celu usunięcia integracji należy:

* Usunąć plik `C:\Windows\Program Files\Update-CertListaToDnsPolicy.ps1`
* Usunąć Scheduled Task za pomoca polecenia `Unregister-ScheduledTask -TaskName CertListaToDnsPolicy -Confirm:$false`.
* Usunąć stworzone przez skrypt polityki za pomocą polecenia `Get-DnsServerQueryResolutionPolicy | Where-Object { $_.Name.Startswith("CERTPL_") } | Sort-Object ProcessingOrder -Descending | Remove-DnsServerQueryResolutionPolicy -Force`

## Uwagi

Jeśli z jakiegoś powodu użycie tego skryptu w organizacji nie wchodzi w grę, można za pomocą GroupPolicy zainstalować skrypt [Update-CertListaToHosts.ps1](../WindowsEndpoint/README.md) na wszystkich systemach Windows w organizacji. Nie jest to natomiast rekomendowana metoda.

Można też przyjrzeć się opcjom integracji z [zewnętrznymi rozwiązaniami](../ThirdParty/).
