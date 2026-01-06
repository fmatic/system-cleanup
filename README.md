🧹 system-cleanup.sh

Debian / DietPi maintenance & cleanup script
Turvallinen huoltoskripti Raspberry Pi -laitteille ja Linux-palvelimille.

📌 Yleiskuvaus

system-cleanup.sh on Bash-skripti, joka suorittaa järjestelmän perushuollon ja siivouksen Debian-pohjaisissa järjestelmissä (Debian, DietPi, Ubuntu Server jne.).

Skripti keskittyy:
	•	levytilan vapauttamiseen
	•	turhien pakettien ja välimuistien poistoon
	•	lokien ja väliaikaistiedostojen siivoamiseen
	•	RAM-välimuistin vapauttamiseen
	•	swapin kierrättämiseen (jos käytössä)

Skripti on suunniteltu turvalliseksi ja ei-tuhoavaksi:
	•	ei koske käyttäjien tiedostoihin
	•	ei poista konffitiedostoja (pl. automaattisesti orvoksi jääneet paketit)
	•	kestää virheitä ei-kriittisissä kohdissa

⸻

⚙️ Mitä skripti tekee?

1️⃣ Root-tarkistus

Skripti varmistaa, että se ajetaan root-oikeuksilla:

sudo ./system-cleanup.sh

2️⃣ Muistin tila (ennen)

Tulostaa RAM- ja swap-tilanteen ennen huoltoa:

free -h

3️⃣ APT-huolto
	•	Poistaa käyttämättömät paketit
	•	Poistaa myös niiden konffit (--purge)
	•	Tyhjentää APT-välimuistin

apt-get autoremove -y
apt-get autoremove --purge -y
apt-get clean
apt-get autoclean

4️⃣ systemd journal -lokien siivous

Poistaa yli 2 viikkoa vanhat journal-lokit:

journalctl --vacuum-time=2weeks

Sopiva kompromissi levytilan ja diagnostiikan välillä.

5️⃣ Väliaikaistiedostot

Tyhjentää:
	•	/tmp
	•	/var/tmp

6️⃣ Käyttäjäkohtaiset cachet

Poistaa kaikkien käyttäjien .cache-hakemistojen sisällön:

/home/*/.cache/*

 Huomio:
	•	Ei poista itse .cache-hakemistoja
	•	Ohittaa virheet hiljaisesti

⸻

7️⃣ RAM-välimuistin tyhjennys

Pakottaa Linuxin vapauttamaan levyvälimuistit:

sync
echo 3 > /proc/sys/vm/drop_caches

Hyödyllinen erityisesti:
	•	vähämuistisilla Raspberry Pi -laitteilla
	•	pitkään uptimea keränneillä palvelimilla

⸻

8️⃣ Swapin kierrätys (valinnainen)

Jos swap on käytössä:

swapoff -a
swapon -a

Tämä:
	•	vapauttaa fragmentoituneen swapin
	•	ei tee mitään, jos swap ei ole käytössä

⸻

9️⃣ Logrotate

Pakottaa lokien rotaation:

logrotate -f /etc/logrotate.conf

Virheet ohitetaan, jotta skripti ei keskeydy.

⸻

🔟 Muistin tila (jälkeen)

Näyttää RAM-tilanteen huollon jälkeen:

free -h

✅ Kenelle tämä skripti sopii?

✔ Raspberry Pi (DietPi, Debian)
✔ Headless-palvelimet
✔ Kokeilu- ja harrastekoneet
✔ Vähämuistiset järjestelmät
✔ Ajettavaksi cronista (esim. kerran kuussa)

⸻

⏱️ Esimerkki cron-ajosta

Aja kerran kuussa:

sudo crontab -e

0 3 1 * * /usr/local/sbin/system-cleanup.sh >> /var/log/system-cleanup.log 2>&1

 Turvallisuus
	•	Ei poista käyttäjätiedostoja
	•	Ei koske /etc-konffeihin
	•	Ei tee kernel- tai reboot-operaatioita
	•	Ajaa kaikki komennot eksplisiittisesti (ei eval / wildcard-ansoja)

⸻

📜 Lisenssi

Vapaa käyttö omaan ja ei-kaupalliseen käyttöön.
Käytä omalla vastuulla – kuten kaikkia järjestelmäscriptejä.

⸻

🧠 Vinkki

Yhdistä tämä:
	•	säännölliseen varmuuskopiointiin
	•	ncdu-analyysiin
	•	systemctl --failed -tarkistukseen

→ saat kevyen mutta tehokkaan Linux-huoltorutiinin.

