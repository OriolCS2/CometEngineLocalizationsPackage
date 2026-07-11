using namespace CometEngine;
using namespace CometEditor;

namespace Localization
{
	class /*@*/ LocalizationSettings : ProjectSetting
	{
		[Serialize, Tooltip("The URL for the GoogleSheet document")]
		private string googleSheetURL = "";

		[Serialize, Tooltip("The GID of the page that contains the index with all other localization pages GID")]
		private int googleSheetIndexPageGID = 0;

		string GoogleSheetURL
		{
			get
			{
				return googleSheetURL;
			}
		}

		string GoogleSheetDownloadURL
		{
			get
			{
				return GoogleSheetURL + "/export?format=csv&gid=";
			}
		}

		int GoogleSheetIndexPageGID
		{
			get
			{
				return googleSheetIndexPageGID;
			}
		}

		[ShowButton("Regenerate Localizations")]
		void Generate()
		{
			LocalizationEditorManager::get.Regenerate();
		}

		ProjectSettingInfo GetInfo()
		{
			ProjectSettingInfo info;
			info.name = "Localizations";
			info.icon = RawIcon::Book;
			return info;
		}
	}

	namespace LocalizationSettings
	{
		LocalizationSettings@ Get()
		{
			return cast<LocalizationSettings>(ProjectSetting::Get("LocalizationSettings"));
		}
	}
}
