namespace Localization
{
	class Locale
	{
		[Serialize] private string key;

		string GetKey()
		{
			return key;
		}

		void SetKey(const string&in newKey)
		{
			key = newKey;
		}

		string GetValue()
		{
			Language@ currentLanguage = Language::get;
			if (currentLanguage is null)
			{
				return key;
			}
			return currentLanguage.GetLocalization(key);
		}
	}
}
