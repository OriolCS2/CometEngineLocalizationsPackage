# Comet Engine Localizations Package

Simplify your game's translation workflow with the **Comet Engine Localizations Package**. This tool allows you to manage all your localization data directly from Google Sheets and seamlessly integrate it into your Comet project.

<div align="center">
  <a href="https://github.com/OriolCS2/CometEngineLocalizationsPackage">
    <img src="https://img.shields.io/badge/GitHub-Repository-blue?style=for-the-badge&logo=github" alt="GitHub Repo" />
  </a>
  <a href="https://www.cometengine.org">
    <img src="https://img.shields.io/badge/Comet_Engine-Website-orange?style=for-the-badge&logo=target" alt="Comet Engine Website" />
  </a>
  <a href="https://www.cometengine.org/marketplace/localizations">
    <img src="https://img.shields.io/badge/Marketplace-Package-brightgreen?style=for-the-badge&logo=googleplay" alt="Marketplace Package" />
  </a>
</div>

---

## 🚀 Quick Start Tutorial

Follow these steps to set up the localization system in your project.

### 1. Set up your Google Sheet
Create a new Google Sheet. The first tab **must** be named `Index`. This tab acts as a manifest, listing all other sheets that should be imported.

For your translation tabs:
*   **Column 1:** The translation **Key**.
*   **Column 2:** **Context** (notes on where the text is used).
*   **Subsequent Columns:** One column for each **Language** you support.
*   *Note: Ensure the language order is identical across all tabs.*

![Google Sheet Setup](TutorialImages/Tuto1.png)

### 2. Identify Sheet GIDs
Each tab in a Google Sheet has a unique ID called a **GID**, found at the end of the URL (e.g., `gid=829223160`). 
In your `Index` tab, list the name of each tab you want to import and its corresponding GID.

![Index Tab Setup](TutorialImages/Tuto2.png)

### 3. Configure Comet Editor
Open the Comet Editor and navigate to **Project Settings > Localizations**.
*   Paste your **Google Sheet URL** (ensure "Anyone with the link" has at least viewer access).
*   Enter the **GID** of your `Index` tab.

![Comet Configuration](TutorialImages/Tuto3.png)

### 4. Fetch Translations
To download your data, click **Regenerate Localizations** in the Project Settings or go to **Localizations > Generate** in the main menu bar. 

Once triggered, the system will download each tab as a `.csv` file into the `Assets/RuntimeAssets/Localizations` directory. Perform this action whenever you update your Google Sheet.

![Regenerate Localizations](TutorialImages/Tuto4.png)

### 5. Initialize the Manager
Go to **Project Settings > Unique Instances**, click **Add Script**, and select the `LanguageManager`. This ensures the localization system is ready when your project runs.

![Language Manager Setup](TutorialImages/Tuto5.png)

### 6. Localizing UI Text
To localize UI elements, add the `LocaleText` behaviour to your text entities. Use this behaviour to assign the translation key; the text will automatically update to reflect the active language.

![LocaleText Behaviour](TutorialImages/Tuto6.png)

---

## 💻 Scripting API

You can easily interact with the localization system via code using the following methods:

| Property / Method | Description |
| :--- | :--- |
| `Language::get.currentLanguage` | Returns the currently active language. |
| `Language::get.availableLanguages` | Returns a list of all imported languages. |
| `Language::get.Load(string language)` | Switches the project's language at runtime. |
| `Language::get.GetLocalization(string key)` | Returns the translated value for a specific key in the current language. |

---

## ✨ Extra Features

### Main Menu Bar
The **Localizations** menu provides quick access to essential tools:
*   **Language Preview:** Switch languages in the editor to see UI changes instantly.
*   **Regenerate:** Quickly update all local localization files.
*   **Localization Manager:** Open the dedicated table view.
*   **Remote Source:** Quickly open the linked Google Sheet.

![Menu Bar](TutorialImages/Tuto7.png)

### Localization Manager
A dedicated window to browse and manage your translations inside the editor. It includes:
*   **Filtering:** Filter by specific languages or tabs.
*   **Search:** Search for specific keys or values.
*   **Validation:** Quickly identify missing translations (empty values).

![Localization Manager](TutorialImages/Tuto8.png)