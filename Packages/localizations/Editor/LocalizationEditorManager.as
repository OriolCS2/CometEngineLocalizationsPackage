using namespace CometEngine;
using namespace CometEditor;
using namespace CometEngine::SceneManagement;

namespace Localization
{
	[CustomInspector("Localization::Locale")]
	class /*@*/ LocalizationEditorManager : EditorBehaviour
	{
		private string LOCALIZATIONS_CURRENT_LANGUAGE_KEY = "LocalizationEditorManager.CurrentLanguage";
		private uint CONTEXT_COLUMN_INDEX = 1;

		private Language language = Language();
		private array<string> keysToShow;
		private string filter;
		private Locale@ lastOpened;

		LocalizationEditorManager()
		{
			LocalizationEditorManager::get = this;
			LoadLocalizations();
		}

		string GetLocalization(const string&in key)
		{
			return language.GetLocalization(key);
		}

		dictionary@GetLocalizations()
		{
			return language.GetLocalizations();
		}

		private void LoadLocalizations()
		{
			language.Load(EditorPrefs::Local().GetString(LOCALIZATIONS_CURRENT_LANGUAGE_KEY, LanguageManager::DEFAULT_LANGUAGE));
			CalculateFilteredKeys();
		}

		private void CalculateFilteredKeys()
		{
			if (filter.isEmpty())
			{
				keysToShow = language.GetLocalizations().getKeys();
			}
			else
			{
				CometEditor::GUI::TextFilter textFilter = CometEditor::GUI::TextFilter(filter);
				keysToShow.resize(0);
				array<string> keys = language.GetLocalizations().getKeys();
				uint keysCount = keys.length();
				for (uint i = 0; i < keysCount; i++)
				{
					string key = keys[i];
					if (textFilter.Pass(key))
					{
						keysToShow.insertLast(key);
					}
				}
			}
		}

		void OnCustomInspector(Locale@ locale)
		{
			GUI::BeginGroup();

			GUI::Spacing();
			GUI::Spacing();
			GUI::StandardFieldName("Key");
			float startX = GUI::GetItemRectMin().x;
			GUI::SetCursorAtStandardPropertyWidgetPosition();
			GUI::SetNextItemWidthToStandardPropertyWidget();
			string currentKey = locale.GetKey();
			if (GUI::BeginCombo("##ComboKey", currentKey, GUI::ComboFlags::HeightLarge))
			{
				lastOpened = locale;
				GUI::AlignTextToFramePadding();
				GUI::SetCursorPosX(GUI::GetCursorPosX() + 3.0f);
				GUI::Text(RawIcon::Search);
				GUI::SameLine();
				float regionAvailableWidth = GUI::GetContentRegionAvail().x;
				if (GUI::IsInsideGraphNodeContext())
				{
					regionAvailableWidth = Math::Max(regionAvailableWidth, 200.0F);
				}
				GUI::SetNextItemWidth(regionAvailableWidth);
				bool edited = false;
				filter = GUI::InputText("##LocalizationFilter", filter, edited, GUI::InputTextFlags::AutoSelectAll);
				if (edited)
				{
					CalculateFilteredKeys();
				}
				GUI::Separator();

				regionAvailableWidth += 20;
				if (GUI::BeginChild("##KeysChild", regionAvailableWidth, 0.0F, GUI::ChildFlags::AutoResizeY | GUI::ChildFlags::AutoResizeX | GUI::ChildFlags::AlwaysUseWindowPadding))
				{
					bool keyFound = false;
					uint keysCount = keysToShow.length();
					CometEditor::GUI::ListClipper clipper = CometEditor::GUI::ListClipper(keysCount);
					while (clipper.Build())
					{
						for (int i = clipper.GetStartIndex(); i <= clipper.GetLastIndex(); i++)
						{
							string key = keysToShow[i];
							bool isSelected = !keyFound && key == currentKey;
							keyFound = keyFound || isSelected;
							if (GUI::MenuItem(key, isSelected))
							{
								GUI::SaveState();
								locale.SetKey(isSelected ? "" : key);
								GUI::CloseCurrentPopup();
							}
						}
					}
				}
				GUI::EndChild();
				GUI::EndCombo();
			}
			else if (!filter.isEmpty() && locale is lastOpened)
			{
				filter.resize(0);
				CalculateFilteredKeys();
			}

			string currentValue = locale.GetValue();
			if (!currentValue.isEmpty())
			{
				float endX = GUI::GetItemRectMax().x;
				float availableWidth = endX - startX;

				bool isNode = GUI::IsInsideGraphNodeContext();
				GUI::Spacing();
				GUI::SetCursorAtStandardFieldPosition();
				GUI::PushStyleColor(GUI::Col::Text, isNode ? Color(0.0, 0.0, 0.0, 0.8) : Color(0.4f, 0.7f, 1.0f, 1.0f));
				GUI::Text(WrapText(locale.GetValue(), availableWidth));
				GUI::PopStyleColor();

				GUI::Spacing();
				GUI::Spacing();
				GUI::EndGroup();

				Vector2 rectMin = GUI::GetItemRectMin();
				Vector2 rectMax = GUI::GetItemRectMax() + Vector2(isNode ? 3.0F : 8.0F, 0.0F);
				GUI::DrawRect(rectMin, rectMax, Color(0.0f, 0.0f, 0.0f, 0.5f));
			}
		}

		[MainMenu("Localizations/Active Editor Locale")]
		private void ShowActiveEditorLanguageMenu()
		{
			for (uint i = 0; i < language.availableLanguages.length(); i++)
			{
				bool isCurrent = language.availableLanguages[i] == language.currentLanguage;
				if (GUI::MenuItem(language.availableLanguages[i], isCurrent) && !isCurrent)
				{
					EditorPrefs::Local().SetString(LOCALIZATIONS_CURRENT_LANGUAGE_KEY, language.availableLanguages[i]);
					LoadLocalizations();
					UpdateAllActiveLocales();
				}
			}
		}

		private void UpdateAllActiveLocales()
		{
			int sceneCount = SceneManager::GetScenesLoadedCount();
			for (int i = 0; i < sceneCount; i++)
			{
				array<Entity>@roots = Scene::GetRoots(SceneManager::GetSceneLoadedAt(i));
				if (roots !is null)
				{
					for (uint j = 0; j < roots.length(); j++)
					{
						UpdateLocalesOf(LocaleText::GetAll(roots[j]));
						UpdateLocalesOf(LocaleText::GetAllInChildren(roots[j]));
					}
				}
			}
		}

		private void UpdateLocalesOf(array<LocaleText>@locales)
		{
			if (locales !is null)
			{
				for (uint i = 0; i < locales.length(); i++)
				{
					locales[i].OnEdited();
				}
			}
		}

		[MainMenuItem("Localizations/Open Sheet")]
		private void OpenLocalizationsSheetMenuItem()
		{
			App::OpenURL(LocalizationSettings::Get().GoogleSheetURL);
		}

		[MainMenuItem("Localizations/Generate")]
		private void GenerateLocalizationsMenuItem()
		{
			Regenerate();
		}

		void Regenerate()
		{
			PopupManager::OpenActionInProgressPopupWithCallback("Generating Localizations", "", CometDelegate(GenerateLocalizations));
		}

		private void GenerateLocalizations()
		{
			if (Shell::ExecuteCommand("curl --version") == 0)
			{
				string indexPageData;
				if (Shell::ExecuteCommandWithOutput("curl -sL \"" + LocalizationSettings::Get().GoogleSheetDownloadURL + LocalizationSettings::Get().GoogleSheetIndexPageGID + "\"", indexPageData))
				{
					array<string> pages = indexPageData.split("\n");
					uint totalPages = pages.length();
					if (totalPages > 0)
					{
						FileSystem::CreateDir(LanguageManager::LOCALIZATIONS_ROOT_FOLDER);

						array<string> filesCreated;
						for (uint i = 0; i < pages.length(); i++)
						{
							array<string> pageData = pages[i].split(",");
							if (pageData.length() >= 2)
							{
								string filePath = LoadPage(pageData[0], pageData[1]);
								if (!filePath.isEmpty())
								{
									filesCreated.insertLast(filePath);
								}
							}
							else
							{
								Debug::LogError("Invalid page index data format for page " + (i + 1) + ": " + pages[i]);
								continue;
							}
						}

						if (!filesCreated.isEmpty())
						{
							array<string> allLocalizationFiles = FileSystem::GetFilesAt(LanguageManager::LOCALIZATIONS_ROOT_FOLDER);
							for (uint i = 0; i < allLocalizationFiles.length(); i++)
							{
								string file = LanguageManager::LOCALIZATIONS_ROOT_FOLDER + allLocalizationFiles[i];
								if (filesCreated.find(file) < 0)
								{
									FileSystem::Remove(file);
								}
							}

							LoadLocalizations();
							LocalizationWindow localizationWindow = cast<LocalizationWindow>(EditorWindow::Get("Localization Manager"));
							if (localizationWindow !is null)
							{
								localizationWindow.Awake();
							}
						}
						else
						{
							FileSystem::RemoveAll(LanguageManager::LOCALIZATIONS_ROOT_FOLDER);
						}
					}
				}
				else
				{
					Debug::LogError("Failed to download localization data.");
				}
			}
			else
			{
				Debug::LogError("Curl is not installed or not added to PATH. Please install curl to use this feature.\nYou may need to restart the editor after installing curl for it to be recognized.");
			}
		}

		private string LoadPage(const string&in pageName, const string&in pageGid)
		{
			string pageData;
			if (Shell::ExecuteCommandWithOutput("curl -sL \"" + LocalizationSettings::Get().GoogleSheetDownloadURL + pageGid + "\"", pageData))
			{
				string filteredPageData;
				array<string> lines = pageData.split("\n");
				uint lineCount = lines.length();
				for (uint i = 0; i < lineCount; i++)
				{
					array<string> columns = lines[i].split(",");
					uint columnCount = columns.length();
					string columnData;
					for (uint j = 0; j < columnCount; j++)
					{
						if (j != CONTEXT_COLUMN_INDEX)
						{
							if (!columnData.isEmpty())
							{
								columnData += ",";
							}
							columnData += columns[j];
						}
					}

					if (!columnData.isEmpty())
					{
						filteredPageData += columnData;
						if (i < lineCount - 1)
						{
							filteredPageData += "\n";
						}
					}
				}

				string filePath = LanguageManager::LOCALIZATIONS_ROOT_FOLDER + pageName + ".csv";
				FileSystem::Save(filePath, filteredPageData);
				return filePath;
			}
			else
			{
				Debug::LogError("Failed to download localization page: " + pageName);
			}
			return "";
		}

		private string WrapText(const string&in text, float width)
		{
			if (width <= 0)
				return text;
			array<string> lines = text.split("\n");
			string finalResult = "";
			for (uint i = 0; i < lines.length(); i++)
			{
				if (i > 0)
					finalResult += "\n";
				finalResult += WrapLine(lines[i], width);
			}
			return finalResult;
		}

		private string WrapLine(const string&in line, float width)
		{
			if (GUI::CalcTextSize(line).x <= width)
				return line;

			array<string> words = line.split(" ");
			string wrapped = "";
			string currentLine = "";

			for (uint i = 0; i < words.length(); i++)
			{
				string testLine = currentLine + (currentLine.isEmpty() ? "" : " ") + words[i];
				if (GUI::CalcTextSize(testLine).x > width)
				{
					if (!currentLine.isEmpty())
					{
						wrapped += currentLine + "\n";
						currentLine = words[i];
					}
					else
					{
						wrapped += words[i] + "\n";
						currentLine = "";
					}
				}
				else
				{
					currentLine = testLine;
				}
			}
			wrapped += currentLine;
			return wrapped;
		}
	}

	namespace LocalizationEditorManager
	{
		LocalizationEditorManager get;
	}
}
