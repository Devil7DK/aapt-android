//
// Copyright 2006 The Android Open Source Project
//
// Android Asset Packaging Tool main entry point.
//

// Trimmed AAPT to only return apk packange name and application label.
// Edited by @Devil7DK on 01-06-2018

#include <cstdlib>
#include <getopt.h>
#include <cassert>
#include <errno.h>
#include <fcntl.h>

#include <iostream>
#include <string>
#include <sstream>

#include "AaptXml.h"
#include "ApkBuilder.h"
#include "Bundle.h"
#include "Images.h"
#include "Main.h"
#include "ResourceFilter.h"
#include "ResourceTable.h"
#include "XMLNode.h"

/*
 * Parse args.
 */
int main(int argc, char* const argv[])
{
	if (argc < 2){
		fprintf(stderr, "ERROR: no file supplied");
		return 1;
	}
	std::string package_name = "unknown";
	std::string app_name = "unknown";

	const char* filename = argv[1];

	AssetManager assets;
	int32_t assetsCookie;

	assets.addAssetPath(String8(filename), &assetsCookie);

	// Make a dummy config for retrieving resources...  we need to supply
	// non-default values for some configs so that we can retrieve resources
	// in the app that don't have a default.  The most important of these is
	// the API version because key resources like icons will have an implicit
	// version if they are using newer config types like density.
	ResTable_config config;
	memset(&config, 0, sizeof(ResTable_config));
	config.language[0] = 'e';
	config.language[1] = 'n';
	config.country[0] = 'U';
	config.country[1] = 'S';
	config.orientation = ResTable_config::ORIENTATION_PORT;
	config.density = ResTable_config::DENSITY_MEDIUM;
	config.sdkVersion = 10000; // Very high.
	config.screenWidthDp = 320;
	config.screenHeightDp = 480;
	config.smallestScreenWidthDp = 320;
	config.screenLayout |= ResTable_config::SCREENSIZE_NORMAL;
	assets.setConfiguration(config);

	const ResTable& res = assets.getResources(false);

	// The dynamicRefTable can be null if there are no resources for this asset cookie.
	// This fine.
	const DynamicRefTable* dynamicRefTable = res.getDynamicRefTableForCookie(assetsCookie);

	Asset* asset = NULL;

	asset = assets.openNonAsset(assetsCookie, "AndroidManifest.xml", Asset::ACCESS_BUFFER);

	ResXMLTree tree(dynamicRefTable);
	tree.setTo(asset->getBuffer(true), asset->getLength());
	tree.restart();

	Vector<String8> locales;
	res.getLocales(&locales);

	Vector<ResTable_config> configs;
	res.getConfigurations(&configs);
	SortedVector<int> densities;
	const size_t NC = configs.size();
	for (size_t i=0; i<NC; i++) {
		int dens = configs[i].density;
		if (dens == 0) {
			dens = 160;
		}
		densities.add(dens);
	}

	size_t len;
	ResXMLTree::event_code_t code;
	int depth = 0;
	String8 error;
	bool withinActivity = false;
	bool isMainActivity = false;
	bool isLauncherActivity = false;
	bool isLeanbackLauncherActivity = false;
	bool withinApplication = false;
	bool withinSupportsInput = false;
	bool withinFeatureGroup = false;
	bool withinReceiver = false;
	bool withinService = false;
	bool withinProvider = false;
	bool hasOtherActivities = false;
	bool hasOtherReceivers = false;
	bool hasOtherServices = false;
	bool hasIntentFilter = false;

	bool hasPaymentService = false;

	bool actHostApduService = false;
	bool actOffHostApduService = false;
	bool hasMetaHostPaymentCategory = false;
	bool hasMetaOffHostPaymentCategory = false;

	bool hasBindNfcServicePermission = false;

	String8 activityName;
	String8 activityLabel;
	String8 activityIcon;
	String8 activityBanner;
	String8 receiverName;
	String8 serviceName;
	Vector<String8> supportedInput;

	while ((code=tree.next()) != ResXMLTree::END_DOCUMENT &&
		   code != ResXMLTree::BAD_DOCUMENT) {
		if (code == ResXMLTree::END_TAG) {
			depth--;
			if (depth < 2) {
				withinApplication = false;
				withinSupportsInput = false;
				withinFeatureGroup = false;
			} else if (depth < 3) {
				if (!hasIntentFilter) {
					hasOtherActivities |= withinActivity;
					hasOtherReceivers |= withinReceiver;
					hasOtherServices |= withinService;
				} else {
					if (withinService) {
						hasPaymentService |= (actHostApduService && hasMetaHostPaymentCategory &&
											  hasBindNfcServicePermission);
						hasPaymentService |= (actOffHostApduService && hasMetaOffHostPaymentCategory &&
											  hasBindNfcServicePermission);
					}
				}
				withinActivity = false;
				withinService = false;
				withinReceiver = false;
				withinProvider = false;
				hasIntentFilter = false;
				isMainActivity = isLauncherActivity = isLeanbackLauncherActivity = false;
			}
			continue;
		}
		if (code != ResXMLTree::START_TAG) {
			continue;
		}
		depth++;

		const char16_t* ctag16 = tree.getElementName(&len);

		String8 tag(ctag16);
		if (depth == 1) {
			package_name = AaptXml::getAttribute(tree, NULL, "package", NULL);;
		} else if (depth == 2) {
			withinApplication = false;
			if (tag == "application") {
				withinApplication = true;

				String8 label;
				const size_t NL = locales.size();
				for (size_t i=0; i<NL; i++) {
					const char* localeStr =  locales[i].string();
					assets.setConfiguration(config, localeStr != NULL ? localeStr : "");
					String8 llabel = AaptXml::getResolvedAttribute(res, tree, 0x01010001, &error);
					if (llabel != "") {
						if (localeStr == NULL || strlen(localeStr) == 0) {
							label = llabel;
						} else {
							if (label == "") {
								label = llabel;
							}
						}
					}
				}
				assets.setConfiguration(config);
				app_name = label;
			}
		}
	}

	printf("%s=%s\n",ResTable::normalizeForOutput(package_name.c_str()).string(),ResTable::normalizeForOutput(app_name.c_str()).string());

	return 0;
}
