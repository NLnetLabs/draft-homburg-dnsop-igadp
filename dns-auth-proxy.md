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

date = 2023-10-13T00:00:00Z

[[author]]
initials="P.C."
surname="Homburg"
fullname="Philip Homburg"
organisation = "NLnet Labs"
  [author.address]
  email = "philip@nlnetlabs.nl"
%%%

.# Abstract

In some situations it be can attractive to have an authoritative DNS server that does not have a local copy of the zone or zones that it serves.
In particular in anycast operations, it is sensible to have a great geographical and topological diversity.
However, sometimes the expected use of a particular site does not warrant the cost of keeping local copies of the zones.
This can be the case if a zone is very large or if the anycast cluster serves
many zones from which only a few are expected to receive significant traffic.
In these cases it can be useful to have a proxy serve some or all of the zones.
The proxy would not have a local copy of the zones it serves, instead it
forwards request to another server that is authoritative for the zone.
The proxy may have a cache.
This document describes the details of such proxies.

{mainmatter}

# Discussion Venues

This note is to be removed before publishing as an RFC.
Source for this draft and an issue tracker can be found at
https://github.com/NLnetLabs/draft-homburg-dnsop-igadp.git .

# Introduction

In some situations it can be attractive to have an authoritative DNS server that does not have a local copy of the zone or zones that it serves.
In particular in anycast operations, it is sensible to have a great geographical and topological diversity.
Benefits of an extra site can be: reduced latency, DDoS protection by
serving a zone locally and thus be protected from a DDoS that originates in
other parts of the network, and DDoS mitigation by attracting local DDoS
traffic.

However, sometimes the expected use of a particular site does not warrant the cost of keeping local copies of the zones up-to-date.
This can be the case if a zone is very large or if the anycast cluster serves
many zones and only a few of them are expected to receive significant traffic.

In these cases it can be useful to have a proxy serve some or all of the zones.
Instead of having a local copy of the zones, such a proxy
forwards requests to another server that is authoritative for the zone.
The proxy may have a cache.

A proxy can operate with or without cache. Without a cache,
the proxy forwards each incoming request to a name server that is authoritative
for the domain. This is straight forward, but also provides limited benefits.

Because we need the proxy to behave like an authoritative server and provide similar behavior with respect to TTLs and data consistency, proxy behavior *with a cache* is more involved.

Another issue that may complicate caching of responses is the EDNS Client Subnet option.

# Basic Requirements

The proxy sends requests upstream with RD bit clear.

The proxy sends replies to clients with the original TTL. Caching is not
controlled by TTL but by the parameters in the SOA record.

# Cache replacement

The goal of the cache replacement strategy described here is to mimic the
behavior of a standard secondary as much as possible.

The proxy fetches SOA records just like a secondary would do based on the parameters in the SOA record in response to a NOTIFY, and takes the contents of the EXPIRE option [@!RFC7314].

Cache entries are tagged with the zone serial number from the most recent SOA
record.
A cache entry is valid only when the serial number in the cache
entry matches the serial number of the current SOA record.

When a new SOA record arrives with a higher serial number, there are two
options.
The first option is to take this as the new current SOA record. This has the
effect of immediately invalidating the cache.

The second option is to delay accepting this SOA and load new copies of
hot cache items first.

Note that DNS replies may contain SOA records.
If a DNS replies contains a SOA record with a higher than the most recently seen serial number (taking into account Serial Number Arithmetic [@!RFC1982]), then the proxy updates its copy of the SOA records using one of the two techniques described above.

# Aggressive negative caching

A caching proxy is allowed to generate negative responses (NODATA or NXDOMAIN)
[@!RFC8198;@RFC9077] based on information in NSEC or NSEC3 records.
Obviously this can be done only for DNSSEC signed zones, and NXDOMAIN only for NSEC or NSEC3 without opt-out.

# ENDS Client Subnet Option

A proxy MAY support [@!RFC7871] (Client Subnet in DNS Queries).

If the proxy supports ECS, it SHOULD be disabled by default. The reason is that
ECS sends privacy sensitive data over the internet.

A proxy that does not support ECS or where ECS support is disabled MUST not
send queries upstream that contain the ECS option. In addition, the proxy
MUST NOT send replies that contain an ECS option.

# Acknowledgements

Many thanks to Willem Toorop for his feedback.

{backmatter}

