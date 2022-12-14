
XTF_PATH=data/$(XTF_FILE)
CATALOG_PATH=$(shell pwd)/catalogs/$(CATALOG)

result/oereblex.xml: xsl/oereblex.download.py
	XTF_PATH="$(XTF_PATH)" \
	RESULT_FILE_PATH=$@ \
	GEOLINK_LIST_TRAFO_PATH="xsl/$(MODEL).oereblex.geolink_list.xsl" \
	OEREBLEX_HOST="$(OEREBLEX_HOST)" \
	OEREBLEX_CANTON="$(OEREBLEX_CANTON)" \
	THEME_CODE="$(THEME_CODE)" \
	DUMMY_OFFICE_NAME="$(DUMMY_OFFICE_NAME)" \
	DUMMY_OFFICE_URL="$(DUMMY_OFFICE_URL)" \
	python3 $^

clean_oereblex_xml: result/oereblex.xml

result/OeREBKRMtrsfr_V2_0.oereblex.xtf: xsl/$(MODEL).oereblex.trafo.xsl
	xsltproc \
		--stringparam theme_code "$(THEME_CODE)" \
		--stringparam oereblex_host "$(OEREBLEX_HOST)" \
		--stringparam model "$(MODEL)" \
		--stringparam catalog "$(CATALOG_PATH)" \
		--stringparam oereblex_output $(shell pwd)/"result/oereblex.xml" \
		$^ $(XTF_PATH) > $@

mgdm2oereb-oereblex: result/OeREBKRMtrsfr_V2_0.oereblex.xtf

result/OeREBKRMtrsfr_V2_0.xtf: xsl/$(MODEL).trafo.xsl
	xsltproc \
		--stringparam theme_code "$(THEME_CODE)" \
		--stringparam model "$(MODEL)" \
		--stringparam catalog "$(CATALOG_PATH)" \
		$^ $(XTF_PATH) > $@

mgdm2oereb: result/OeREBKRMtrsfr_V2_0.xtf

.PHONY: clean
clean:
	rm -f result/oereblex.xml
	rm -f result/OeREBKRMtrsfr_V2_0.xtf
	rm -f result/OeREBKRMtrsfr_V2_0.oereblex.xtf
	rm -f result/OeREBKRMtrsfr_V2_0.mgdm2oereb.log

