# This file is part of get-tiger
# https://github.com/fitnr/get-tiger

# Licensed under the GNU General Public License v3 (GPLv3) license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, Neil Freeman <contact@fakeisthenewreal.org>

# Year of census data.
# Check API for most recent year available
include key.ini

YEAR = 2014
CONGRESS = 114

export KEY YEAR

comma = ,
STATE_FIPS = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 \
			 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 \
			 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 72

CARTO_BASE = ftp://ftp2.census.gov/geo/tiger/GENZ$(YEAR)/shp
SHP_BASE = ftp://ftp2.census.gov/geo/tiger/TIGER$(YEAR)
API_BASE = http://api.census.gov/data

SERIES = acs5

DATASETS = AREAWATER NATION REGION DIVISION AIANNH AITSN ANRC \
	BG CBSA CD CNECTA CONCITY COUNTY COUNTY_WITHIN_UA COUSUB CSA \
	ELSD ESTATE LINEARWATER METDIV MIL NECTA NECTADIV PLACE PRISECROADS \
	PRIMARYROADS PUMA RAILS ROADS SCSD SLDL SLDU STATE SUBBARRIO \
	TABBLOCK TBG TTRACT TRACT UAC UNSD ZCTA5

# Some files can be drawn from the cartographic boundary or tiger datasets.
# Default is cartographic.
CARTOGRAPHIC ?= true

ifeq ($(CARTOGRAPHIC),true)
    base = $(1)/cb_$(YEAR)_$(2)_$(3)_500k

    carto_national = $(AIANNH) $(ANRC) $(COUNTY) $(CD) $(STATE)
    CARTO_BY_STATE = $(COUSUB) $(PLACE) $(SLDL) $(SLDU) $(TRACT)
    carto_nodata = $(SUBBARRIO)

else
    base = $(1)/tl_$(YEAR)_$(2)_$(3)

    tiger_national = $(AIANNH) $(ANRC) $(COUNTY) $(CD) $(STATE)
    tiger_by_state = $(COUSUB) $(PLACE) $(SLDL) $(SLDU) $(TRACT)
    tiger_nodata = $(SUBBARRIO)
endif

ifeq ($(wildcard counties/$(YEAR)/*),"")
    AREAWATER =
    AREAWATERCOUNTY =
    LINEARWATER =
    LINEARWATERCOUNTY =
    ROADS =
    ROADSCOUNTY =

else
    COUNTY_FIPS = $(foreach a,$(STATE_FIPS),$(addprefix $a,$(shell cat counties/$(YEAR)/$a)))
    AREAWATERCOUNTY = $(foreach f,$(COUNTY_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater)
    AREAWATER = $(foreach f,$(STATE_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater)
    LINEARWATER = $(foreach f,$(STATE_FIPS),LINEARWATER/tl_$(YEAR)_$f_linearwater)
    LINEARWATERCOUNTY = $(foreach f,$(COUNTY_FIPS),LINEARWATER/tl_$(YEAR)_$f_linearwater)
    ROADS = $(foreach f,$(STATE_FIPS),ROADS/tl_$(YEAR)_$f_roads)
    ROADSCOUNTY = $(foreach f,$(COUNTY_FIPS),ROADS/tl_$(YEAR)_$f_roads)
endif

# general file definitions
DIVISION = DIVISION/cb_$(YEAR)_us_division_5m
NATION = NATION/cb_$(YEAR)_us_nation_5m
REGION = REGION/cb_$(YEAR)_us_region_500k

AIANNH = $(call base,AIANNH,us,aiannh)
AITSN = AITSN/tl_$(YEAR)_us_aitsn
ANRC = $(call base,ANRC,02,anrc)

BG = $(foreach f,$(STATE_FIPS),BG/tl_$(YEAR)_$f_bg)
CBSA = CBSA/tl_$(YEAR)_us_cbsa
CD = $(call base,CD,us,cd$(CONGRESS))
CNECTA = CNECTA/tl_$(YEAR)_us_cnecta

CONCITY = $(foreach f,09 13 18 20 21 30 47,CONCITY/tl_2014_$f_concity)

COUNTY = $(call base,COUNTY,us,county)
COUSUB = $(foreach f,$(STATE_FIPS),$(call base,COUSUB,$f,cousub))
COUNTY_WITHIN_UA = $(foreach f,$(STATE_FIPS),COUNTY_WITHIN_UA/cb_$(YEAR)_$f_county_within_ua_500k)
CSA = CSA/tl_$(YEAR)_us_csa

_elsd_fips = 60 69 04 06 09 13 17 21 23 25 26 27 29 30 33 34 36 38 40 41 44 45 47 48 50 51 55 56
ELSD = $(foreach f,$(filter $(_elsd_fips),$(STATE_FIPS)),ELSD/tl_$(YEAR)_$f_elsd)

ESTATE = ESTATE/tl_$(YEAR)_78_estate
METDIV = METDIV/tl_$(YEAR)_us_metdiv
MIL = MIL/tl_$(YEAR)_us_mil
NECTA = NECTA/tl_$(YEAR)_us_necta
NECTADIV = NECTADIV/tl_$(YEAR)_us_nectadiv

PLACE = $(foreach f,$(STATE_FIPS),$(call base,PLACE,$(f),place))
PRISECROADS = $(foreach f,$(STATE_FIPS),PRISECROADS/tl_$(YEAR)_$f_prisecroads)
PRIMARYROADS = PRIMARYROADS/tl_$(YEAR)_us_primaryroads
PUMA = $(foreach f,$(filter-out 60 69,$(STATE_FIPS)),PUMA/cb_$(YEAR)_$f_puma10_500k)
RAILS = RAILS/tl_$(YEAR)_us_rails

_scsd_fips = 04 06 09 13 17 21 23 25 27 30 33 34 36 40 41 44 45 47 48 50 55
_scsds = $(filter $(_scsd_fips),$(STATE_FIPS))
SCSD = $(foreach f,$(_scsds),SCSD/tl_$(YEAR)_$f_scsd)

# Remove DC and Nebraska.
SLDL = $(foreach f,$(filter-out 11 31,$(STATE_FIPS)),$(call base,SLDL,$(f),sldl))

SLDU = $(foreach f,$(STATE_FIPS),$(call base,SLDU,$(f),sldu))
STATE = $(call base,STATE,us,state)
SUBBARRIO = $(call base,SUBBARRIO,72,subbarrio)


TABBLOCK = $(foreach f,$(STATE_FIPS),TABBLOCK/tl_$(YEAR)_$f_tabblock10)
TBG = TBG/tl_$(YEAR)_us_tbg
TTRACT = TTRACT/tl_$(YEAR)_us_ttract
TRACT = $(foreach f,$(STATE_FIPS),$(call base,TRACT,$(f),tract))

UAC = UAC/cb_$(YEAR)_us_ua10_500k
UNSD = $(foreach f,$(STATE_FIPS),UNSD/tl_$(YEAR)_$f_unsd)

ZCTA5 = ZCTA5/cb_$(YEAR)_us_zcta510_500k

# lists of data (two kinds of files)

# 1. Cartographic boundary files
# National data sets
CARTO_NATIONAL = $(carto_national) $(DIVISION) $(REGION)
# Data sets that need to be joined w/ 'GEOID10' instead of GEOID.
CARTO_2010 = $(UAC) $(ZCTA5)
# Per-state data sets that need to be joined w/ 'GEOID10' instead of GEOID.
CARTO_2010_STATE = $(PUMA)
CARTO_NODATA = $(carto_nodata) $(NATION) $(COUNTY_WITHIN_UA)

CARTO = $(CARTO_NATIONAL) $(CARTO_2010) $(CARTO_BY_STATE) $(CARTO_2010_STATE)

# 2. TIGER data files
# National data sets
TIGER_NATIONAL = $(tiger_national) $(AITSN) $(CNECTA) $(CBSA) \
	$(CSA) $(METDIV) $(NECTA) $(NECTADIV) $(TBG)
# Per-state data sets.
TIGER_BY_STATE = $(tiger_by_state) $(BG) $(CONCITY) $(ELSD) \
	$(SCSD) $(TTRACT) $(UNSD)
# Geodata with no survey data available from the API
TIGER_NODATA = $(tiger_nodata) $(ESTATE) $(MIL) $(PRIMARYROADS) \
	$(PRISECROADS) $(RAILS) $(ROADSCOUNTY) $(TABBLOCK) \
	$(AREAWATERCOUNTY) $(LINEARWATERCOUNTY)

TIGER = $(TIGER_NATIONAL) $(TIGER_BY_STATE)

# data fields #

DATA_FIELDS ?= B06011_001E B25105_001E B25035_001E B01003_001E \
	B25001_001E B25002_002E B25002_003E B25003_001E B25003_002E B25003_003E \
	B08101_001E B08101_009E B08101_017E B08101_025E B08101_033E B08101_041E \
	B08101_049E B25024_001E B25024_002E B25024_003E B25024_004E B25024_005E \
	B25024_006E B25024_007E B25024_008E B25024_009E B25024_010E B25024_011E \
	B25033_001E B25033_002E B25033_008E B05012_001E B05012_002E B05012_003E

OUTPUT_FIELDS ?= ROUND(B01003_001/(ALAND/1000000.), 2) AS PopDensKm, \
	ROUND(B25001_001/(ALAND/1000000.), 2) AS HuDensKm, \
	ROUND(B08101_001/B01003_001, 2) AS WrkForcPct, \
	ROUND(B25033_008 / B25033_001, 2) AS RentPct,

OUTPUT_FIELDS_10 ?= ROUND(B01003_001 / (ALAND10 / 1000000.), 2) AS PopDensKm, \
	ROUND(B25001_001 / (ALAND10 / 1000000.), 2) AS HuDensKm, \
	ROUND(B08101_001 / B01003_001, 2) AS WrkForcPct, \
	ROUND(B25033_008 / B25033_001, 2) AS RentPct,

CENSUS_DATA_FIELDS = GEOID,$(subst $( ) $( ),$(comma),$(DATA_FIELDS))

CURL = curl $(CURLFLAGS)
CURLFLAGS = --get $(API_BASE)/$(YEAR)/$(SERIES) \
	-o $@ \
	--data key=$(KEY) \
	--data get=$(CENSUS_DATA_FIELDS)

format = shp
driver.shp  = 'ESRI Shapefile'
driver.json = GeoJSON

export CPL_MAX_ERROR_REPORTS=3
OGRFLAGS = -f $(driver.$(format)) -dialect sqlite

.PHONY: all $(DATASETS)

all:
	@echo Available data sets:
	@echo '(run with "make DATASET")'
	@echo NATION - United States
	@echo DIVISION - four very broad sections of the country
	@echo REGION - nine broad sections of the country
	@echo AIANNH - American Indian areas, Alaska Native areas, Hawaiian home lands
	@echo AITSN - American Indian tribal subvidisions
	@echo ANRC - Alaska Native regional corporations
	@echo BG - Block groups
	@echo CNECTA - Combined New England city and town areas
	@echo CBSA - Core-based statistical qreas
	@echo CD - Congressional districts 
	@echo CONCITY - Consolidated cities 
	@echo COUNTY - Counties
	@echo COUNTY_WITHIN_UA - Urban areas segmented by county
	@echo COUSUB - County subvidisions
	@echo CSA - Consolidated statistical areas
	@echo ELSD - Elementary school districts
	@echo ESTATE - Estates [US Virgin Islands]
	@echo METDIV - Metropolitan Divisions
	@echo MIL - Military areas
	@echo NECTA - New England city and town areas
	@echo NECTADIV - New England city and town area divisions
	@echo PLACE - Places
	@echo PRIMARYROADS - Primary roads [national]
	@echo PRISECROADS - Primary and secondary roads [by state]
	@echo PUMA - Public use microdata areas
	@echo RAILS - Railroads
	@echo ROADS - Roads. Downloads one file for each county, then combines into state files.
	@echo SCSD - Secondary school districts 
	@echo SLDL - State legislative districts [lower chamber]
	@echo SLDU - State legislative districts [upper chamber]
	@echo STATE - States and territories
	@echo SUBBARRIO - Sub-barrios [Puerto Rico]
	@echo TABBLOCK - Blocks
	@echo TBG - Tribal block groups
	@echo TRACT - Census tracts
	@echo TTRACT - Tribal Census tracts
	@echo UAC - Urbanized areas
	@echo UNSD - Unified school districts
	@echo ZCTA5 - Zip code tabulation areas
	@echo AREAWATER - Water polygons. Downloads one file for each county, then combines into state files.
	@echo LINEARWATER - Water lines. Downloads one file for each county, then combines into state files.

.SECONDEXPANSION:

$(DATASETS): $$(addprefix $(YEAR)/,$$(addsuffix .$(format),$$($$@)))
	@echo $^

merge = BG CONCITY COUNTY_WITHIN_UA COUSUB ELSD PLACE PRISECROADS PUMA SCSD SLDL SLDU TABBLOCK TRACT UNSD

$(foreach x,$(merge),$(YEAR)/$x.$(format)): $(YEAR)/%.$(format): $$(foreach x,$$($$*),$(YEAR)/$$x.$(format))
	@rm -rf $@
	for f in $(basename $(^F)); do \
	    ogr2ogr $@ $(<D)/$$f.$(format) -update -append; \
	done;

# Merge shp and acs data, e.g:
# 2014/AIANNH/tl_2014_us_aiannh.shp: 2014/AIANNH/tl_2014_us_aiannh.zip 2014/AIANNH/tl_2014_us_aiannh_acs5.csv

NODATA = $(addsuffix .$(format),$(addprefix $(YEAR)/,$(CARTO_NODATA) $(TIGER_NODATA)))

$(NODATA): $(YEAR)/%.$(format): $(YEAR)/%.zip
	unzip -oqd $(@D) $<
	@touch $@

$(addprefix $(YEAR)/,$(addsuffix .$(format),$(CARTO_2010))): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$</$(@F) $(OGRFLAGS) \
	-sql "SELECT *, \
	    $(OUTPUT_FIELDS_10) \
	    ROUND(ALAND10/1000000., 6) LANDKM, ROUND(AWATER10/1000000., 6) WATERKM \
	    FROM $(basename $(@F)) a \
	    LEFT JOIN '$(lastword $^)'.$(basename $(lastword $(^F))) b ON (a.GEOID10=b.GEOID)"

SHPS_2010 = $(addprefix $(YEAR)/,$(addsuffix .$(format),$(CARTO_2010_STATE)))

$(SHPS_2010): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$</$(@F) $(OGRFLAGS) \
	    -sql "SELECT *, \
	    $(OUTPUT_FIELDS) \
	    ROUND(ALAND/1000000., 6) LANDKM, ROUND(AWATER/1000000., 6) WATERKM \
	    FROM $(basename $(@F)) a \
	    LEFT JOIN '$(lastword $^)'.$(basename $(lastword $(^F))) b ON (a.GEOID10=b.GEOID)"

SHPS = $(addprefix $(YEAR)/,$(addsuffix .$(format),$(CARTO_NATIONAL) $(CARTO_BY_STATE) $(TIGER_NATIONAL) $(TIGER_BY_STATE)))

$(SHPS): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$</$(@F) $(OGRFLAGS) \
	    -sql "SELECT *, \
	    $(OUTPUT_FIELDS) \
	    ROUND(ALAND/1000000., 2) as LANDKM, ROUND(AWATER/1000000., 2) as WATERKM \
	    FROM $(basename $(@F)) \
	    LEFT JOIN '$(lastword $^)'.$(basename $(lastword $(^F))) USING (GEOID)"

%.dbf: %.csv %.csvt
	ogr2ogr -f 'ESRI Shapefile' $@ $< -overwrite -select $(CENSUS_DATA_FIELDS)
	@rm -f $(basename $@).{ind,idm}
	ogrinfo $@ -sql "CREATE INDEX ON $(basename $(@F)) USING GEOID"

# Totally fake type hinting. A String for GEOID, every other column is an Integer
%.csvt: %.csv
	head -n1 $< | \
	sed 's/^GEOID/"String"/; s/,[A-Za-z0-9_]*/,"Integer"/g' > $@

# County by State files
counties = $$(shell cat counties/$(YEAR)/$$*)
combinecountyfiles = for base in $(basename $(^F)); do \
	ogr2ogr $@ /vsizip/$(<D)/$$base.zip/$$base.shp $(OGRFLAGS) -update -append; \
	done;

areawaters = $(foreach x,$(AREAWATER),$(YEAR)/$x.$(format))
awfp := $(YEAR)/AREAWATER/tl_$(YEAR)_$$*$$x_areawater.zip
$(areawaters): $(YEAR)/AREAWATER/tl_$(YEAR)_%_areawater.$(format): $$(foreach x,$(counties),$(awfp))
	@rm -fr $@
	$(combinecountyfiles)

linearwaters = $(foreach x,$(LINEARWATER),$(YEAR)/$x.$(format))
lwfp := $(YEAR)/LINEARWATER/tl_$(YEAR)_$$*$$x_linearwater.zip
$(linearwaters): $(YEAR)/LINEARWATER/tl_$(YEAR)_%_linearwater.$(format): $$(foreach x,$(counties),$(lwfp))
	@rm -fr $@
	$(combinecountyfiles)

roads = $(foreach x,$(ROADS),$(YEAR)/$x.$(format))
rdfp := $(YEAR)/ROADS/tl_$(YEAR)_$$*$$x_roads.zip
$(roads): $(YEAR)/ROADS/tl_$(YEAR)_%_roads.$(format): $$(foreach x,$(counties),$(rdfp))
	@rm -fr $@
	$(combinecountyfiles)

$(YEAR)/BG/tl_$(YEAR)_%_bg_$(SERIES).csv: counties/$(YEAR)/% | $$(@D)
	$(eval COUNTIES=$(shell cat $<))
	$(MAKE) $(foreach x,$(COUNTIES),$(@D)/tl_$(YEAR)_$*_$x_bg_$(SERIES).csv)

	@rm -rf $@
	head -1 $(@D)/tl_$(YEAR)_$*_$(lastword $(COUNTIES))_bg_$(SERIES).csv > $@
	for COUNTY in $(COUNTIES); do \
		tail +2 $(@D)/tl_$(YEAR)_$*_$${COUNTY}_bg_$(SERIES).csv; \
		done >> $@

# Census API json has a strange CSV-like format, includes "YY000US" prefix on GEOID.
# Luckily, this makes it fairly easy to brute force into CSV
TOCSV = 's/,null,/,,/g; \
	s/"//g; \
	s/\[//g; \
	s/\]//g; \
	s/,$$//g; \
	s/^[0-9]*US//'

%.csv: %.json
	sed $(TOCSV) $< > $@

# Download ACS data

# Carto boundary files

$(YEAR)/$(NATION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=us:*'

$(YEAR)/$(REGION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=region:*'

$(YEAR)/$(DIVISION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=division:*'

# National data files

$(YEAR)/$(AIANNH)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=american+indian+area/alaska+native+area/hawaiian+home+land:*'

$(YEAR)/AITSN/tl_$(YEAR)_us_aitsn_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+subdivision/remainder:*'

# Not actually national, there's just one state with Alaska Native Regional Corps (Guess which one!)
$(YEAR)/$(ANRC)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=alaska+native+regional+corporation:*'

$(YEAR)/$(CD)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=congressional+district:*'

$(YEAR)/$(CBSA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=metropolitan+statistical+area/micropolitan+statistical+area:*'

$(YEAR)/$(CNECTA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=combined+new+england+city+and+town+area:*'

$(YEAR)/$(COUNTY)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county:*'

$(YEAR)/$(CSA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=combined+statistical+area:*'

$(YEAR)/$(METDIV)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=metropolitan+division:*'

$(YEAR)/$(NECTA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=new+england+city+and+town+area:*'

$(YEAR)/$(NECTADIV)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=necta+division:*'

$(YEAR)/$(STATE)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state:*'

$(YEAR)/$(TBG)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+block+group:*'

$(YEAR)/$(TTRACT)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+census+tract:*'

$(YEAR)/$(UAC)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=urban+area:*'

$(YEAR)/$(ZCTA5)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=zip+code+tabulation+area:*'

# County by state

# e.g. 2014/BG/36_047_acs5.json
$(YEAR)/BG/tl_$(YEAR)_%_bg_$(SERIES).json: | $$(@D)
	$(CURL) --data for='block+group:*' --data in=state:$(firstword $(subst _, ,$*))+county:$(lastword $(subst _, ,$*))

# State by state files

$(YEAR)/CONCITY/tl_$(YEAR)_%_concity_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=consolidated+city:*' --data in=state:$*

$(YEAR)/$(call base,COUSUB,%,cousub)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county+subdivision:*' --data in=state:$*

$(YEAR)/ELSD/tl_$(YEAR)_%_elsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(elementary):*' --data in=state:$*

$(YEAR)/$(call base,PLACE,%,place)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=place:*' --data in=state:$*

$(YEAR)/PUMA/cb_$(YEAR)_%_puma10_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=public+use+microdata+area:*' --data in=state:$*

$(YEAR)/SCSD/tl_$(YEAR)_%_scsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(secondary):*' --data in=state:$*

$(YEAR)/$(call base,SLDL,%,sldl)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(lower+chamber):*' --data in=state:$*

$(YEAR)/$(call base,SLDU,%,sldu)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(upper+chamber):*' --data in=state:$*

$(YEAR)/$(call base,TRACT,%,tract)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tract:*' --data in=state:$*

$(YEAR)/UNSD/tl_$(YEAR)_%_unsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(unified):*' --data in=state:$*

# Lists of county FIPS
COFIPS = $(addprefix counties/$(YEAR)/,$(STATE_FIPS))
.PHONY: countyfips
countyfips: $(COFIPS)

$(COFIPS): counties/$(YEAR)/%: $(YEAR)/COUNTY/tl_$(YEAR)_us_county.zip | $$(@D)
	ogr2ogr -f CSV /dev/stdout /vsizip/$</$(basename $(<F)).shp \
	    -where "STATEFP='$*'" -select COUNTYFP | \
	tail -n+2 | \
	xargs | \
	fold -s \
	> $@

# Download ZIP files

$(addsuffix .zip,$(addprefix $(YEAR)/,$(TIGER) $(TIGER_NODATA))): $(YEAR)/%: | $$(@D)
	curl -o $@ $(SHP_BASE)/$*

$(addsuffix .zip,$(addprefix $(YEAR)/,$(CARTO) $(CARTO_NODATA))): $(YEAR)/%: | $$(@D)
	curl -o $@ $(CARTO_BASE)/$(*F)

$(sort $(dir $(addprefix $(YEAR)/,$(TIGER) $(TIGER_NODATA) $(CARTO) $(CARTO_NODATA)))): $(YEAR)
	-mkdir $@

$(YEAR) counties/$(YEAR):; -mkdir $@
