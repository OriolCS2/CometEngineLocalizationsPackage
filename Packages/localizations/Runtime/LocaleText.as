using namespace CometEngine;
using namespace CometEngine::UI;

namespace Localization
{
	[RequiereBehaviour("CometEngine::UI::Text")]
	class /*@*/ LocaleText : CometBehaviour
	{
		private Text text;
		[Serialize] private Locale locale;

		void Start()
		{
			text = Text::Get(entity);
			UpdateText();
		}

		void SetKey(const string&in newKey)
		{
			locale.SetKey(newKey);
			UpdateText();
		}

		private void UpdateText()
		{
			if (Object::IsNull(text))
			{
				Debug::LogWarning("LocaleText behaviour requires a Text behaviour on the same entity.");
				return;
			}
			text.text = locale.GetValue();
		}

#ifdef COMET_EDITOR
		void OnEdited()
		{
			Start();
		}
#endif
	}
}
