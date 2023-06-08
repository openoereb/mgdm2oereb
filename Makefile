
XTF_PATH=data/$(XTF_FILE)
CATALOG_PATH=$(shell pwd)/catalogs/$(CATALOG)

result/oereblex.xml: xsl/oereblex.download.py
	XTF_PATH="$(XTF_PATH)" \
	RESULT_FILE_PATH=$@ \
	GEOLINK_LIST_TRAFO_PATH="xsl/$(MODEL).oereblex.geolink_list.xsl" \
	OEREBLEX_HOST="$(OEREBLEX_HOST)" \
	OEREBLEX_CANTON="$(OEREBLEX_CANTON)" \
	THEME_CODE="$(THEME_CODE)" \
	TARGET_BASKET_ID="$(TARGET_BASKET_ID)" \
	DUMMY_OFFICE_NAME="$(DUMMY_OFFICE_NAME)" \
	DUMMY_OFFICE_URL="$(DUMMY_OFFICE_URL)" \
	python3 $^

clean_oereblex_xml: result/oereblex.xml

result/OeREBKRMtrsfr_V2_0.oereblex.xtf: xsl/$(MODEL).oereblex.trafo.xsl
	xsltproc \
		--stringparam target_basket_id "$(TARGET_BASKET_ID)" \
		--stringparam theme_code "$(THEME_CODE)" \
		--stringparam oereblex_host "$(OEREBLEX_HOST)" \
		--stringparam model "$(MODEL)" \
		--stringparam catalog "$(CATALOG_PATH)" \
		--stringparam oereblex_output $(shell pwd)/"result/oereblex.xml" \
		--stringparam xsl_path $(shell pwd)/"xsl" \
		$^ $(XTF_PATH) > $@

mgdm2oereb-oereblex: result/OeREBKRMtrsfr_V2_0.oereblex.xtf

result/OeREBKRMtrsfr_V2_0.xtf: xsl/$(MODEL).trafo.xsl
	xsltproc \
		--stringparam target_basket_id "$(TARGET_BASKET_ID)" \
		--stringparam theme_code "$(THEME_CODE)" \
		--stringparam model "$(MODEL)" \
		--stringparam catalog "$(CATALOG_PATH)" \
		--stringparam xsl_path $(shell pwd)/"xsl" \
		$^ $(XTF_PATH) > $@

mgdm2oereb: result/OeREBKRMtrsfr_V2_0.xtf

.PHONY: clean
clean:
	rm -f result/oereblex.xml
	rm -f result/OeREBKRMtrsfr_V2_0.xtf
	rm -f result/OeREBKRMtrsfr_V2_0.oereblex.xtf
	rm -f result/OeREBKRMtrsfr_V2_0.mgdm2oereb.log
	rm -f result/flattened_documents.json
	rm -f result/flattened_files.json
	rm -f result/oereblex_geolink_unique.json
	rm -f result/oereblex_geolink_unique_with_oereblex.json
	rm -f result/unique_authorities.json
	rm -f result/unique_join_mgdm_tid.json
	rm -f result/uuid_authorities.json
	rm -f result/xslt_result.xml
