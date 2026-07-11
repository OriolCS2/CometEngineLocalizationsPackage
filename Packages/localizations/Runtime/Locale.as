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
			return Language::get.GetLocalization(key);
		}
	}
}
