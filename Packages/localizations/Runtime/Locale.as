namespace Localization
{
	class Locale
	{
		[Serialize] private string key;

		string GetKey() const
		{
			return key;
		}

		void SetKey(const string&in newKey)
		{
			key = newKey;
		}

		string GetValue() const
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
