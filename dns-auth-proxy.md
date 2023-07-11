%%%
title = "Implementation Guidelines for Authoritative DNS Proxies"
abbrev = "igadp"
area = "Internet"
workgroup = "DNSOP"

[seriesInfo]
status = "standard"
name = "Internet-Draft"
value = "draft-homburg-dnsop-igadp-00"
stream = "IETF"

date = 2023-07-06T00:00:00Z

[[author]]
initials="P.C."
surname="Homburg"
fullname="Philip Homburg"
organisation = "NLnet Labs"
  [author.address]
  email = "philip@nlnetlabs.nl"
%%%

.# Abstract

In some situations it can attractive to have an authoritative DNS server that 
does not have a local copy of the zone or zones that it serves.
In particular in anycast operations, it is attractive to have a great 
geographical and topological diversity. However, sometimes the expect use of
a particular site does not warrant the cost of keep local copies of the
zones up-to-date. 
This can be the case if the zone is very big or if the anycast cluster serves
many zones and only a few on them are expect to get significant use.
In these cases it is attractive to have a proxy serve some or all of the zones.
The proxy does not have a local copy of the zones it serves, instead it
forwards request to another server tat is authoritaive for the zone. 
The proxy may have a cache.
This document describes the details of such proxies.

{mainmatter}

# Discussion Venues

This note is to be removed before publishing as an RFC.
Source for this draft and an issue tracker can be found at
https://github.com/NLnetLabs/draft-homburg-dnsop-igadp.git .

# Introduction

In some situations it can attractive to have an authoritative DNS server that 
does not have a local copy of the zone or zones that it serves.
In particular in anycast operations, it is attractive to have a great 
geographical and topological diversity.
Benefits of an extra site can be reduced latency, DDoS protection by 
serving a zone locally and thus be protected from a DDoS that originates in
other parts of the network, and DDoS mitigation by attracting local DDoS
traffic.

However, sometimes the expect use of a particular site does not warrant the
cost of keep local copies of the zones up-to-date. 
This can be the case if the zone is very big or if the anycast cluster serves
many zones and only a few on them are expect to get significant use.

In these cases it is attractive to have a proxy serve some or all of the zones.
The proxy does not have a local copy of the zones it serves, instead it
forwards request to another server tat is authoritaive for the zone. 
The proxy may have a cache.

A proxy can operate in two basic modes: with or without cache. Without a cache,
the proxy forward each incoming request to another that is authoritative 
for te domain. This is very simple, but also provides limited benefits.

With a cache the proxy becomes more complex. The reason is that we
want the proxy to behave like an authoritative server, i.e. provide similar
behavior with respect to TTLs and data consistency.

Another issue that may complicate matters is the EDNS Client Subnet option.

# Basic Requirements

The proxy MUST drop replies with the AA bit clear. The reasoning is that
the proxy may accidentally reach a recursive resolver.

The proxy sends requests upstream with RD bit clear. 

The proxy sends replies to clients with the original TTL. Caching is not 
controlled by TTL but by the parameters in the SOA record.

# Cache replacement

The goal of the cache replacement strategy described here is mimic the 
behavior of a standard secondary as much as possible.

The basic idea is that the proxy fetches SOA records just like a secondary
would do based on the parameters in the SOA record, in response to a NOTIFY
and taking the contents of the EXPIRE option RFC 7314.

Cache entries are tags with the zone serial number from the most recent SOA
record. A cache entry is valid only when the serial number in the cache
entry match the serial number of the current SOA record.

When a new SOA record arrives with a higher serial number there are two
options. 
The first option is to take this as the new current SOA record. This has the
effect of immediately invalidating the cache.

The second option is to delay accepting this SOA and load new copies of
hot cache items first.

Note that DNS replies may contain SOA records. If a DNS replies contains a
SOA record with a higher serial number then the proxy updates its copy of
the SOA records using one of the two techniques descibed above.

# Aggressive negative caching

A caching proxy is allowed to generate negative responses (NODATA or NXDOMAIN)
based on information in NSEC or NSEC3 records. Obviously this can be done 
only for DNSSEC signed zones, and NXDOMAIN only for NSEC or NSEC3 without
opt-out.

# ENDS Client Subnet Option

A proxy MAY support RFC 7871 (Client Subnet in DNS Queries). Support is optional because many authoritative server have no need to know the IP address of the client.

If the proxy supports ECS, it SHOULD be disabled by default. The reason is that
ECS sends privacy sensitive data over the internet.

A proxy that does not support ECS or where ECS support is disabled MUST not
send queries upstream that contain the ECS option. In addition, the proxy
MUST NOT send replies that contain an ECS option.




{backmatter}

