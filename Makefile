
XTF_PATH=data/$(XTF_FILE)

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

result/OeREBKRMtrsfr_V2_0.xtf: xsl/$(MODEL).oereblex.trafo.xsl
	xsltproc --stringparam theme_code "$(THEME_CODE)" --stringparam oereblex_host "$(OEREBLEX_HOST)" --stringparam model "$(MODEL)" $^ $(XTF_PATH) > $@

mgdm2oereb: result/OeREBKRMtrsfr_V2_0.xtf

.PHONY: clean
clean:
	rm -f result/oereblex.xml
	rm -f result/OeREBKRMtrsfr_V2_0.xtf
