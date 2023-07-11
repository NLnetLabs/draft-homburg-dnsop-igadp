all: dns-auth-proxy.txt

dns-auth-proxy.txt: dns-auth-proxy.xml
	xml2rfc dns-auth-proxy.xml

dns-auth-proxy.xml: dns-auth-proxy.md
	mmark dns-auth-proxy.md > dns-auth-proxy.xml.new && \
		mv dns-auth-proxy.xml.new dns-auth-proxy.xml
