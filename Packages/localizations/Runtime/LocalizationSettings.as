using namespace CometEngine;
using namespace CometEditor;

namespace Localization
{
	class /*@*/ LocalizationSettings : ProjectSetting
	{
		[Serialize, Tooltip("Where should the localizations be downloaded?")]
		private string localizationsPath = "RuntimeAssets/Localizations";

		string LocalizationsPath
		{
			get
			{
				string path = "Assets/" + localizationsPath;
				if (path.at(path.length() - 1) != "/")
				{
					path += "/";
				}
				return path;
			}
		}

#ifdef COMET_EDITOR
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

		[HideInInspector]
		CometDelegateHandler onRegenerateLocalizationsRequested;

		[ShowButton("Regenerate Localizations")]
		private void Generate()
		{
			onRegenerateLocalizationsRequested.Invoke();
		}

		[ShowButton("Open Sheet")]
		private void OpenSheet()
		{
			App::OpenURL(GoogleSheetURL);
		}

		void OnEdited()
		{
			if (LocalizationsPath.findFirst("RuntimeAssets") < 0)
			{
				Debug::LogError("Localizations path must a `RuntimeAssets` folder.");
			}
		}

		ProjectSettingInfo GetInfo()
		{
			ProjectSettingInfo info;
			info.name = "Localizations";
			info.icon = RawIcon::Book;
			return info;
		}
#else
		void OnStart()
		{
			Language().Load(LanguageManager::DEFAULT_LANGUAGE);
		}
#endif
	}

	namespace LocalizationSettings
	{
		LocalizationSettings@ Get()
		{
			return cast<LocalizationSettings>(ProjectSetting::Get("LocalizationSettings"));
		}

		string DEFAULT_LANGUAGE = "English";
	}
}
