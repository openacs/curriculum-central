# Paths
XSLTPROC=/usr/bin/xsltproc
XSL=../../../../../packages/acs-core-docs/www/xml/openacs.xsl

all: html

clean:
	rm -f *.html
	rm -f ../*.html
	rm -f ../../../../acs-core-docs/www/xml/XSL

XSL: clean
	if [ ! -d XSL -a ! -L XSL ]; then \
		echo -e "\n\nNo XSL directory here.  I am looking for one...\n"; \
		for d in \
	 		/sw/share/xml/docbook-xsl \
			/usr/share/sgml/docbook/xsl-stylesheets-* \
			/usr/share/sgml/docbook/xsl-stylesheets \
			/usr/share/sgml/docbook/stylesheet/xsl/nwalsh; \
		do \
			if [ -d $$d ]; then \
				echo "Found $$d"; \
				EXISTS=$$d; \
			fi; \
		done; \
		if [ "$$EXISTS" = "" ]; then \
			echo -e "\
\nNo xsl stylesheets found in /usr/share/sgml/docbook/\n\
You need to install them on your system or if they exist already,\n\
symlink them here so that XSL/html/chunk.xsl exists\n\
see http://sourceforge.net/projects/docbook/ for the docbook-xsl stylesheets\n"; \
			exit 1; \
		else \
			echo "I think $$EXISTS is the best one\n\n"; \
			ln -s $$EXISTS ../../../../acs-core-docs/www/xml/XSL; \
		fi; \
	fi;

html: XSL
	$(XSLTPROC) $(XSL) curriculum-central.sgml
	mv *.html ..