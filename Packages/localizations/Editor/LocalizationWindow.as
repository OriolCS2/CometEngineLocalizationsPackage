using namespace CometEngine;
using namespace CometEditor;

namespace Localization
{
	class LanguageKey
	{
		string language;
		string value;
	}

	class KeyEntry
	{
		string key;
		array<LanguageKey> languageValues;
		array<uint> missingLanguageIndexes;
	}

	class Page
	{
		string name;
		array<KeyEntry> entries;
		array<string> languages;
	}

	[MainMenuItemWindow("Localizations/Localization Manager", "Localization Manager")]
	class /*@*/ LocalizationWindow : EditorWindow
	{
		private array<Page@> pages;

		[Serialize] private string filter;
		[Serialize] private bool onlyMissing = false;
		[Serialize] private bool allTogether = false;
		[Serialize] private bool textFilterOnlyKeys = true;
		[Serialize] private array<bool> languagesEnabledIndexes;
		[Serialize] private uint totalLanguagesEnabled = 0;

		void Awake()
		{
			pages.resize(0);
			string localizationsRootFolder = LocalizationSettings::Get().LocalizationsPath;
			array<string> files = FileSystem::GetFilesAt(localizationsRootFolder);
			uint filesCount = files.length();
			for (uint i = 0; i < filesCount; i++)
			{
				string fileName = files[i];
				array<string> fileParts = fileName.split(".");
				if (fileParts.length() >= 2 && fileParts[fileParts.length() - 1] == "csv")
				{
					string pageName = fileName.substr(0, fileName.length() - 4);
					Page@page = Page();
					page.name = pageName;

					string fileData = FileSystem::Load(localizationsRootFolder + fileName);
					if (!fileData.isEmpty())
					{
						array<string> lines = fileData.split("\n");
						if (lines.length() > 1)
						{
							array<string> header = lines[0].split(",");
							for (uint j = 1; j < lines.length(); j++)
							{
								array<string> lineData = lines[j].split(",");
								if (lineData.length() >= 2)
								{
									KeyEntry@entry = KeyEntry();
									entry.key = lineData[0];

									for (uint k = 1; k < header.length(); k++)
									{
										LanguageKey@langKey = LanguageKey();
										langKey.language = header[k];
										langKey.value = k >= lineData.length() ? "" : lineData[k];

										if (!langKey.value.isEmpty() && langKey.value.at(langKey.value.length() - 1) == "\r")
										{
											langKey.value = langKey.value.substr(0, langKey.value.length() - 1);
										}

										if (langKey.value.isEmpty())
										{
											entry.missingLanguageIndexes.insertLast(k - 1);
										}
										entry.languageValues.insertLast(langKey);
									}

									for (uint k = 1; k < header.length(); k++)
									{
										if (page.languages.find(header[k]) < 0)
										{
											page.languages.insertLast(header[k]);
										}
									}

									page.entries.insertLast(entry);
								}
							}
						}
					}

					pages.insertLast(page);
				}
			}

			if (!pages.isEmpty())
			{
				totalLanguagesEnabled = pages[0].languages.length();
				languagesEnabledIndexes.resize(totalLanguagesEnabled);
				for (uint i = 0; i < languagesEnabledIndexes.length(); i++)
				{
					languagesEnabledIndexes[i] = true;
				}
			}
		}

		void OnGUI()
		{
			ShowMenuBar();

			if (!pages.isEmpty() && (allTogether || GUI::BeginTabBar("LocalizationPagesTabBar")))
			{
				if (!allTogether || StartPageTable(pages[0]))
				{
					uint pagesCount = pages.length();
					for (uint i = 0; i < pagesCount; i++)
					{
						Page@page = pages[i];
						if (allTogether || GUI::BeginTabItem(page.name))
						{
							if (allTogether || StartPageTable(page))
							{
								ShowPageEntries(page);

								if (!allTogether)
								{
									GUI::EndTable();
								}
							}

							if (!allTogether)
							{
								GUI::EndTabItem();
							}
						}
					}

					if (allTogether)
					{
						GUI::EndTable();
					}
					else
					{
						GUI::EndTabBar();
					}
				}
			}
		}

		void ShowMenuBar()
		{
			if (GUI::BeginMenuBar())
			{
				GUI::PushStyleVarVector(GUI::StyleVar::FramePadding, Vector2(4.0f, 0.4f));

				float windowWidth = GUI::GetWindowSize().x;
				bool isBigEnoughForOptions = windowWidth > 255.0f;

				GUI::AlignTextToFramePadding();
				GUI::SetCursorPosY(GUI::GetCursorPosY() - 1.0f);
				GUI::Text(RawIcon::Search);
				GUI::SameLine();
				GUI::Text("Filter");
				GUI::SameLine();
				GUI::SetNextItemWidth(isBigEnoughForOptions ? windowWidth - 170.0f : 85.0F);
				GUI::SetCursorPosY(GUI::GetCursorPosY() + 3.5F);
				filter = GUI::InputText("##LocalizationFilter", filter, GUI::InputTextFlags::AutoSelectAll);

				GUI::SameLine();
				GUI::SetNextItemWidth(85.0f);
				GUI::SetCursorPosY(GUI::GetCursorPosY() + 3.5F);
				if (GUI::BeginCombo("##Options", "Options"))
				{
					if (GUI::Selectable("All Together", allTogether, GUI::SelectableFlags::NoAutoClosePopups))
					{
						allTogether = !allTogether;
					}
					if (GUI::Selectable("Text Filter Only Keys", textFilterOnlyKeys, GUI::SelectableFlags::NoAutoClosePopups))
					{
						textFilterOnlyKeys = !textFilterOnlyKeys;
					}
					if (GUI::Selectable("Only Missing", onlyMissing, GUI::SelectableFlags::NoAutoClosePopups))
					{
						onlyMissing = !onlyMissing;
					}
					GUI::Separator();
					if (!pages.isEmpty())
					{
						Page@page = pages[0];
						for (uint i = 0; i < page.languages.length(); i++)
						{
							if (GUI::Selectable(page.languages[i], languagesEnabledIndexes[i], GUI::SelectableFlags::NoAutoClosePopups))
							{
								languagesEnabledIndexes[i] = !languagesEnabledIndexes[i];
								totalLanguagesEnabled += languagesEnabledIndexes[i] ? 1 : -1;
							}
						}
					}

					GUI::EndCombo();
				}
				GUI::PopStyleVar(1);
				GUI::EndMenuBar();
			}
		}

		bool StartPageTable(Page@page)
		{
			if (GUI::BeginTable("LocalizationTable" + page.name, totalLanguagesEnabled + 1, GUI::TableFlags::RowBg | GUI::TableFlags::Borders))
			{
				GUI::TableSetupColumn(" Key", GUI::TableColumnFlags::NoReorder);
				if (totalLanguagesEnabled > 0)
				{
					for (uint j = 0; j < page.languages.length(); j++)
					{
						if (languagesEnabledIndexes[j])
						{
							GUI::TableSetupColumn(page.languages[j], GUI::TableColumnFlags::NoReorder);
						}
					}
				}
				GUI::TableHeadersRow();
				GUI::TableNextRow();
				return true;
			}
			return false;
		}

		void ShowPageEntries(Page@page)
		{
			CometEditor::GUI::TextFilter textFilter = CometEditor::GUI::TextFilter(filter);
			for (uint j = 0; j < page.entries.length(); j++)
			{
				KeyEntry@entry = page.entries[j];
				if (onlyMissing)
				{
					if (entry.missingLanguageIndexes.isEmpty())
					{
						continue;
					}

					bool hasAnyMissingInEnabledLanguages = false;
					for (uint k = 0; k < entry.missingLanguageIndexes.length(); k++)
					{
						if (languagesEnabledIndexes[entry.missingLanguageIndexes[k]])
						{
							hasAnyMissingInEnabledLanguages = true;
							break;
						}
					}
					if (!hasAnyMissingInEnabledLanguages)
					{
						continue;
					}
				}

				if (!filter.isEmpty())
				{
					bool isKeyValid = textFilter.Pass(entry.key);
					if (!isKeyValid)
					{
						if (textFilterOnlyKeys)
						{
							continue;
						}

						bool anyValueValid = false;
						for (uint k = 0; k < entry.languageValues.length(); k++)
						{
							if (languagesEnabledIndexes[k] && textFilter.Pass(entry.languageValues[k].value))
							{
								anyValueValid = true;
								break;
							}
						}

						if (!anyValueValid)
						{
							continue;
						}
					}
				}

				GUI::TableNextRow();
				GUI::TableSetColumnIndex(0);
				GUI::AlignTextToFramePadding();
				GUI::Text(" " + entry.key);
				ShowPopupContextForEntry(entry.key, "");

				for (uint k = 0; k < entry.languageValues.length(); k++)
				{
					if (!languagesEnabledIndexes[k])
					{
						continue;
					}

					LanguageKey@langKey = entry.languageValues[k];
					GUI::TableNextColumn();

					if (langKey.value.isEmpty())
					{
						GUI::PushStyleColor(GUI::Col::Text, Color(1.0f, 0.1f, 0.1f, 1.0f));
						GUI::Text(RawIcon::ExclamationTriangle + " MISSING");
						GUI::PopStyleColor();
					}
					else
					{
						GUI::Text(langKey.value);
						ShowPopupContextForEntry(langKey.value, langKey.language);
					}
				}
			}
		}

		void ShowPopupContextForEntry(const string&in entryKey, const string&in language)
		{
			if (GUI::BeginPopupContextItem("LocalizationEntryContext" + entryKey + language))
			{
				if (GUI::MenuItem("Copy"))
				{
					GUI::SetClipboardText(entryKey);
				}
				GUI::EndPopup();
			}
		}

		WindowConfig OnGetWindowConfig()
		{
			WindowConfig config;
			config.hasMenuBar = true;
			config.iconRaw = RawIcon::Language;
			return config;
		}
	}
}
