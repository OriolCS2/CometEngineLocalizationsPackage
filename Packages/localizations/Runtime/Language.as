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
			@Language::get = this;
		}

		~Language()
		{
			if (Language::get is this)
			{
				@Language::get = null;
			}
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

			array<AssetHandle> localizationFiles = Assets::GetGroupAssets(LocalizationSettings::CONTENT_GROUP);
			uint filesCount = localizationFiles.length();
			for (uint i = 0; i < filesCount; i++)
			{
				AssetHandle handle = localizationFiles[i];
				string fileName = Assets::GetAddress(handle);
				DataAsset localizationData = cast<DataAsset>(Assets::Load(handle));
				array<string> fileParts = fileName.split("/");
				if (!fileParts.isEmpty())
				{
					string pageName = fileParts[fileParts.length() - 1];

					string fileData = localizationData.data;
					if (!fileData.isEmpty())
					{
						array < array < string>> rows = ParseCsv(fileData);
						if (rows.length() > 1)
						{
							array<string> header = rows[0];
							if (availableLanguages.isEmpty())
							{
								for (uint j = 1; j < header.length(); j++)
								{
									availableLanguages.insertLast(header[j]);
								}
								availableLanguages.sortAsc();

								if (currentLanguage.isEmpty() || availableLanguages.find(currentLanguage) < 0)
								{
									availableLanguages.find(LocalizationSettings::DEFAULT_LANGUAGE) >= 0 ? currentLanguage = LocalizationSettings::DEFAULT_LANGUAGE : currentLanguage = availableLanguages[0];
								}
							}

							for (uint j = 1; j < rows.length(); j++)
							{
								array<string> lineData = rows[j];
								if (lineData.length() >= 1)
								{
									for (uint k = 1; k < header.length(); k++)
									{
										if (header[k] == currentLanguage)
										{
											string value = k >= lineData.length() ? "" : lineData[k];

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

		private array < array < string>> ParseCsv(const string&in csvData) const
		{
			array < array < string>> rows;
			if (csvData.isEmpty())
			{
				return rows;
			}

			array<string> currentRow;
			string currentCell;
			bool insideQuotes = false;
			uint csvLength = csvData.length();
			for (uint i = 0; i < csvLength; i++)
			{
				string character = csvData.substr(i, 1);
				if (character == "\"")
				{
					if (insideQuotes && (i + 1) < csvLength && csvData.substr(i + 1, 1) == "\"")
					{
						currentCell += "\"";
						i++;
					}
					else
					{
						insideQuotes = !insideQuotes;
					}
				}
				else if (character == "," && !insideQuotes)
				{
					currentRow.insertLast(currentCell);
					currentCell = "";
				}
				else if ((character == "\n" || character == "\r") && !insideQuotes)
				{
					if (character == "\r" && (i + 1) < csvLength && csvData.substr(i + 1, 1) == "\n")
					{
						i++;
					}

					currentRow.insertLast(currentCell);
					currentCell = "";
					if (!IsCsvRowEmpty(currentRow))
					{
						rows.insertLast(currentRow);
					}
					currentRow.resize(0);
				}
				else
				{
					currentCell += character;
				}
			}

			currentRow.insertLast(currentCell);
			if (!IsCsvRowEmpty(currentRow))
			{
				rows.insertLast(currentRow);
			}

			return rows;
		}

		private bool IsCsvRowEmpty(const array<string>&in row) const
		{
			uint rowLength = row.length();
			for (uint i = 0; i < rowLength; i++)
			{
				if (!row[i].isEmpty())
				{
					return false;
				}
			}
			return true;
		}
	}

	namespace Language
	{
		Language@ get;
	}
}
