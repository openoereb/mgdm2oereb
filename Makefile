
OUTPUT_XTF_PATH=$(shell pwd)/result/OeREBKRMtrsfr_V2_0.xtf
XTF_PATH=data/$(XTF_FILE)
CATALOG_PATH=$(shell pwd)/catalogs/$(CATALOG)
OEREBLEX_XML=result/oereblex.xml

.PHONY: mgdm2oereb-prepare-oereblex-docs-native
mgdm2oereb-prepare-oereblex-docs-native: xsl/oereblex.download.py
	XTF_PATH="$(XTF_PATH)" \
	RESULT_FILE_PATH=$(OEREBLEX_XML) \
	GEOLINK_LIST_TRAFO_PATH="xsl/$(MODEL).oereblex.geolink_list.xsl" \
	OEREBLEX_HOST="$(OEREBLEX_HOST)" \
	OEREBLEX_CANTON="$(OEREBLEX_CANTON)" \
	THEME_CODE="$(THEME_CODE)" \
	TARGET_BASKET_ID="$(TARGET_BASKET_ID)" \
	DUMMY_OFFICE_NAME="$(DUMMY_OFFICE_NAME)" \
	DUMMY_OFFICE_URL="$(DUMMY_OFFICE_URL)" \
	python3 $^

.PHONY: mgdm2oereb-prepare-oereblex-docs-geolink2oereb
mgdm2oereb-prepare-oereblex-docs-geolink2oereb: xsl/oereblex.geolink2oereb.py
	XTF_PATH="$(XTF_PATH)" \
	RESULT_FILE_PATH=$(OEREBLEX_XML) \
	GEOLINK_LIST_TRAFO_PATH="xsl/$(MODEL).oereblex.geolink_list.xsl" \
	OEREBLEX_HOST="$(OEREBLEX_HOST)" \
	THEME_CODE="$(THEME_CODE)" \
	PYRAMID_OEREB_CONFIG_PATH="$(PYRAMID_OEREB_CONFIG_PATH)" \
	SECTION="$(SECTION)" \
	SOURCE_CLASS_PATH="$(SOURCE_CLASS_PATH)" \
	C2CTEMPLATE_STYLE="$(C2CTEMPLATE_STYLE)" \
	TARGET_BASKET_ID="$(TARGET_BASKET_ID)" \
	python3 $^

mgdm2oereb-oereblex: xsl/$(MODEL).oereblex.trafo.xsl
	xsltproc \
		--stringparam target_basket_id "$(TARGET_BASKET_ID)" \
		--stringparam theme_code "$(THEME_CODE)" \
		--stringparam oereblex_host "$(OEREBLEX_HOST)" \
		--stringparam model "$(MODEL)" \
		--stringparam catalog "$(CATALOG_PATH)" \
		--stringparam oereblex_output $(shell pwd)/"result/oereblex.xml" \
		--stringparam xsl_path $(shell pwd)/"xsl" \
		$^ $(XTF_PATH) > $(OUTPUT_XTF_PATH)

mgdm2oereb: xsl/$(MODEL).trafo.xsl
	xsltproc \
		--stringparam target_basket_id "$(TARGET_BASKET_ID)" \
		--stringparam theme_code "$(THEME_CODE)" \
		--stringparam model "$(MODEL)" \
		--stringparam catalog "$(CATALOG_PATH)" \
		--stringparam xsl_path $(shell pwd)/"xsl" \
		$^ $(XTF_PATH) > $(OUTPUT_XTF_PATH)

validate: $(OUTPUT_XTF_PATH)
	cd /tmp && java -jar /ilivalidator/ilivalidator.jar --verbose --trace --allObjectsAccessible $(OUTPUT_XTF_PATH)

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
