using namespace CometEngine;

namespace Localization
{
	class /*@*/ Language
	{
		string currentLanguage;
		array<string> availableLanguages;
		dictionary currentLocalizationData;

		Language()
		{
			Language::get = this;
		}

		~Language()
		{
			Language::get = null;
		}

		string GetLocalization(const string&in key)
		{
			string returnValue;
			currentLocalizationData.get(key, returnValue);
			return returnValue;
		}

		dictionary@GetLocalizations()
		{
			return currentLocalizationData;
		}

		void Load(const string&in language)
		{
			currentLanguage = language;
			availableLanguages.resize(0);
			currentLocalizationData.deleteAll();

			array<string> files = FileSystem::GetFilesAt(LanguageManager::LOCALIZATIONS_ROOT_FOLDER);
			uint filesCount = files.length();
			for (uint i = 0; i < filesCount; i++)
			{
				string fileName = files[i];
				array<string> fileParts = fileName.split(".");
				if (fileParts.length() >= 2 && fileParts[fileParts.length() - 1] == "csv")
				{
					string pageName = fileName.substr(0, fileName.length() - 4).toLowerCase();

					string fileData = FileSystem::Load(LanguageManager::LOCALIZATIONS_ROOT_FOLDER + fileName);
					if (!fileData.isEmpty())
					{
						array<string> lines = fileData.split("\n");
						if (lines.length() > 1)
						{
							array<string> header = lines[0].split(",");
							if (availableLanguages.isEmpty())
							{
								for (uint j = 1; j < header.length(); j++)
								{
									availableLanguages.insertLast(header[j]);
								}
								availableLanguages.sortAsc();

								if (currentLanguage.isEmpty() || availableLanguages.find(currentLanguage) < 0)
								{
									availableLanguages.find(LanguageManager::DEFAULT_LANGUAGE) >= 0 ? currentLanguage = LanguageManager::DEFAULT_LANGUAGE : currentLanguage = availableLanguages[0];
								}
							}

							for (uint j = 1; j < lines.length(); j++)
							{
								array<string> lineData = lines[j].split(",");
								if (lineData.length() >= 2)
								{
									for (uint k = 1; k < header.length(); k++)
									{
										if (header[k] == currentLanguage)
										{
											string value = k >= lineData.length() ? "" : lineData[k];

											if (!value.isEmpty() && value.at(value.length() - 1) == "\r")
											{
												value = value.substr(0, value.length() - 1);
											}

											currentLocalizationData[pageName + "_" + lineData[0]] = value;
											break;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	namespace Language
	{
		Language@ get;
	}
}
