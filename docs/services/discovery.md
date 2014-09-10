################################################################################

### Doc Status: WIP


Currently using serf.

- autodiscovery using mdns (dns srv records apparently)


Want to replace with:
- standard dns-based solution
- tinydns or equivalent small daemons
- securely tunneled
- multicast discovery


Components needed:
- small dns server (w/dnssec?)
- secured communication layer

mini http server:
- http://www.fefe.de/fnord/
- http://publicfile.org/
- http://cliffle.com/article/2013/01/26/publicfile-patches/

Question: why not use a service discovery protocol such as finger?
- http://tools.ietf.org/html/rfc742
- http://tools.ietf.org/html/rfc1288#section-2.5.5

"Vending machines SHOULD respond to a {C} request with a list of all
   items currently available for purchase and possible consumption.
   Vending machines SHOULD respond to a {U}{C} request with a detailed
   count or list of the particular product or product slot.  Vending
   machines should NEVER NEVER EVER eat money."

Question: why not use a service management/configuration protocol such as snmp?
- http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol#Version_2
- can use knoerre...
- http://www.tuxad.com/nagios-fwb/knoerre.1.html

- http://www.tuxad.com/english-speaking.html
- http://www.tuxad.com/download-sac-tools.html
