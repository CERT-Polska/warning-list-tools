# Integracja Listy z rozwiązaniami zewnętrznymi

CERT Polska obecnie nie dostarcza instrukcji integracji listy z zewnętrznymi rozwiązaniami.
Natomiast dla wygody czytelnika linkujemy tutaj materiały na ten temat stworzone oraz utrzymywane przez podmioty zewnętrzne.
Nie możemy zagwarantować ich poprawności oraz kompletności.

**Ważne**:

* Wykonując instrukcje należy podmieniać adresy URL z `https://hole.cert.pl/domains/domains.txt` na `https://hole.cert.pl/domains/v2/domains.txt`, i analogicznie dla innych zasobów.
* Niektóre instrukcje korzystają z adresu `http://` zamiast `https://`. Należy zawsze korzystać z adresów `https://`.
* Wiele instrukcji nie przewiduje, że domeny mogą zostać usunięte. Taka sytuacja jest możliwa na liście CERT Polska i musi być poprawnie obsłużona. Wdrożenie listy bez wsparcia dla usuwania może długoterminowo prowadzić do fałszywych alarmów i niesłusznie zablokowanych stron.
* Rekomendowana częstotliwość aktualizacji listy to co 5 minut, nawet jeśli artykuł sugeruje inny okres.
* Ponownie: CERT Polska nie gwarantuje poprawności i kompletności linkowanych tutaj materiałów.

### FortiGate

* [Zintegruj swojego FortiGate z bazą niebezpiecznych stron od CERT Polska](https://avlab.pl/zintegruj-swojego-fortigate-z-baza-niebezpiecznych-stron-od-cert-polska/) (avlab.pl)
* [40funky - Ochrona w oparciu o bazy dostarczane przez CERT](https://www.youtube.com/watch?v=-mNIHBFfz1U) (youtube.com)

### Pi-Hole

* [Zabezpieczamy domową sieć przed stronami wyłudzającymi od nas dane (konfiguracja Pi-Hole](https://sekurak.pl/zabezpieczamy-domowa-siec-przed-stronami-wyludzajacymi-od-nas-dane-konfiguracja-pi-hole/) (sekurak.pl)
* [6 sposobów wdrożenia Listy Ostrzeżeń CERT Polska w sieci firmowej](https://avlab.pl/lista-ostrzezen-cert-polska-6-sposobow-wdrozenia/) (avlab.pl)
* [Blokowanie domen z listy HoleCert na Mikrotik, Pihole](https://www.certyficate.it/blokowanie-domen-z-listy-holecert-na-mikrotik/) (certyficate.it)

### pfSense

* [6 sposobów wdrożenia Listy Ostrzeżeń CERT Polska w sieci firmowej](https://avlab.pl/lista-ostrzezen-cert-polska-6-sposobow-wdrozenia/) (avlab.pl)

### Mikrotik RouterOS

* [6 sposobów wdrożenia Listy Ostrzeżeń CERT Polska w sieci firmowej](https://avlab.pl/lista-ostrzezen-cert-polska-6-sposobow-wdrozenia/) (avlab.pl)
* [Blokowanie domen z listy HoleCert na Mikrotik, Pihole](https://www.certyficate.it/blokowanie-domen-z-listy-holecert-na-mikrotik/) (certyficate.it)

### Inne rozwiązania

Mimo, że CERT Polska nie wspiera zewnętrznych rozwiązań, dostarczamy listy w różnych formatach w celu uproszczenia integracji z różnymi środowiskami. Przykładowo:

* Lista w [formacie RPZ](https://hole.cert.pl/domains/v2/domains_rpz.db) jest wspierana natywnie przez większość rozwiązań typu Firewall oraz serwerów DNS. Najprostszym rozwiązaniem będzie regularny import listy w formacie RPZ do stosowanego rozwiązania sieciowego.
* Lista w [formacie RSC](https://hole.cert.pl/domains/v2/domains_mikrotik.rsc) wspierana automatycznie przez rozwiązania z rodziny Mikrotik.
* Ewentualnie można również skorzystać z listy w formatach [txt](https://hole.cert.pl/domains/v2/domains.txt), [json](https://hole.cert.pl/domains/v2/domains.json), [xml](https://hole.cert.pl/domains/v2/domains.xml) i [csv](https://hole.cert.pl/domains/v2/domains.csv) i samodzielnie zautomatyzować blokowanie złośliwych domen w organizacji.
