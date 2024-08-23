# Konfiguracja bezpiecznego serwera DNS

Listę można prosto zintegrować z dowolnym urządzeniem przez skorzystanie z bezpiecznego resolvera DNS, który odrzuca zapytania o domeny znajdujące się na Liście Ostrzeżeń.

Warto podkreślić, że to rozwiązanie nie jest bezproblemowe i **nie jest zalecane mniej technicznym użytkownikom**. Przykładowo, po nadpisaniu konfiguracji DNS mogą wystąpić problemy z podłączeniem do HotSpotów, albo z dostępem do zasobów w sieci firmowej po VPN. 

Nie jest to odpowiednia instrukcja jeśli celem jest skonfigurowanie własnego serwera DNS zamiast konfiguracja istniejącego rozwiązania na urządzeniu.
Może w tym celu pomóc instrukcja konfiguracji wybranych [zewnętrznych rozwiązań](../ThirdParty/), albo serwerów [Windows](../WindowsDomain/).

### Dostawcy

CERT Polska nie utrzymuje obecnie publicznego serwera DNS, który filtruje odpowiedzi pod względem obecności na liście. Istnieją natomiast zewnętrzne rozwiązanie integrujące się z listą CERT Polska. Między innymi są to:

* [Quad9](https://quad9.net/) (ip: 9.9.9.9, 149.112.112.112. DoH: https://dns.quad9.net/dns-query)
* [dns0.eu](https://www.dns0.eu/) (ip: 193.110.81.0, 185.253.5.0)
* [nextdns.io](https://nextdns.io/) (usługa komercyjna)

### Konfiguracja w systemie Android

W celu ustawienia alternatywnego serwera DNS w telefonie marki Android należy wejśc w `Ustawienia` -> `Sieć` -> `Prywatny DNS` i wpisać jeden z wymienionych powyżej serwerów DNS over HTTPS w pole "nazwa hosta dostawcy DNS". Przykładowo, dla dostawcy Quad9 będzie to https://dns.quad9.net/dns-query.
