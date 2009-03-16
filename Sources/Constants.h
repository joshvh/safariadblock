/*
 This file is part of Safari AdBlock.
 
 Safari AdBlock is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 any later version.
 
 Safari AdBlock is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Safari AdBlock.  If not, see <http://www.gnu.org/licenses/>.
*/

#define IsEnabledPrefsKey					@"ABIsEnabled"
#define ShouldCheckForUpdatesPrefsKey		@"ABCheckForUpdates"
#define LastVersionCheckPrefsKey			@"ABLastVersionCheck"
#define SubscriptionsPrefsKey				@"ABSubscriptions"

#define SubscriptionNameKey					@"SubscriptionName"
#define SubscriptionIsSubscribedKey			@"IsSubscribed"
#define SubscriptionIsCustomKey				@"IsCustom"
#define SubscriptionURLsKey					@"SubscriptionURLs"
#define SubscriptionsLanguageKey			@"SubscriptionLanguage"
#define SubscriptionsOrderKey				@"SubscriptionOrder"

#define ShortApplicationSupportFolderPath	@"~/Library/Application Support/Safari AdBlock"
#define BundleIdentifier					@"net.sourceforge.SafariAdBlock"
#define CheckForUpdateURL					@"http://safariadblock.sourceforge.net/versioncheck.php?v=%@"
#define SafariAdBlockProtocolScheme			@"safariadblock"
#define UserAgentFormat						@"Safari AdBlock/%@"

#define FiltersPlistFullName				@"Filters.plist"
#define CustomFiltersFileFullName			@"CustomFilters.txt"
#define SubscriptionsPlistFullName			@"Subscriptions.plist"
#define FiltersVersion						2
#define VersionFiltersKey					@"Version"
#define WhiteListFiltersKey					@"WhiteList"
#define PageWhiteListFiltersKey				@"PageWhiteList"
#define BlockListFiltersKey					@"BlockList"
#define LastUpdatedFiltersKey				@"LastUpdated"

#define	SafariAdBlockToolbarIdentifier		@"SafariAdBlockToolbarIdentifier"

#define MaxVersionOfSafariTestedWith		55231006

#define RegexKitDefaultOptions				(RKCompileUTF8 | RKCompileNoUTF8Check | RKCompileCaseless)