# DHCP-server-visualisointi

## Kuvaus
DHCP-server-visualisointi on sovellus, jonka tarkoituksena on tarkkailla ja havainnollistaa IP-osoitteiden tilaa ja toimintaa DHCP-ympäristössä. Sovellus esittää DHCP-palvelimet hierarkkisena rakenteena, jonka avulla kokonaiskuvaa verkosta on helppo ymmärtää ja hallita.

## Rakenne
Sovellun näkymä rakentuu seuraavasti:

- **DHCP-serverit**
  - **Subnetit**
    - **IP-osoitteet**

Jokainen taso on selkeästi hahmotettavissa, ja käyttäjä voi porautua yksityiskohtaisempaan näkymään tarpeen mukaan.

## IP-osoitteiden tiedot
Kullekin IP-osoitteelle näytetään muun muassa:
- IP-osoite
- Aliverkkomaski (subnet mask)
- MAC-osoite

## Details-näkymä
Jokaisella IP-osoitteella on oma **Details**-näkymä, jossa käyttäjä voi:

- Tarkastella lease-aikaa
- Hakea SNMP-tiedot
- Pingata IP-osoitetta
- Kirjoittaa kommentin tai muistiinpanon (note)

## Käyttötarkoitus
Sovellus soveltuu erityisesti:
- Verkkojen valvontaan ja hallintaan
- DHCP-ympäristöjen dokumentointiin
- Vianetsintään ja IP-osoitteiden seurantaan

---

## DHCP-serverin lisäys
***serverit.conf*** tiedostoon lisätään # name ip user type password(yes/no)
```bash
# name ip user type password(yes/no)
serveri1 10.10.10.10 kayttaja isc no
serveri2 11.11.11.11 user1 udm no
```
