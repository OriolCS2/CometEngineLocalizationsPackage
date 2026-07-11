using namespace CometEngine;
using namespace CometEngine::Json;

namespace Localization
{
	class /*@*/ LanguageManager : CometBehaviour
	{
		LanguageManager()
		{
			if (LanguageManager::get !is null)
			{
				Debug::LogWarning("Another UniqueInstance created of type LanguageManager that will override the previous one.");
			}
			LanguageManager::get = this;
		}

		~LanguageManager()
		{
			LanguageManager::get = null;
		}

		void Awake()
		{
#ifndef COMET_EDITOR
			Language(); // create the singleton
#endif
			Language::get.Load(LanguageManager::DEFAULT_LANGUAGE);
		}
	}

	namespace LanguageManager
	{
		LanguageManager get;

		string LOCALIZATIONS_ROOT_FOLDER = "Assets/RuntimeAssets/Localizations/";
		string DEFAULT_LANGUAGE = "English";
	}
}
