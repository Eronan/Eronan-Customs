# Eronan-Customs
Custom Cards for EDOPro

## Installation Instructions
1. Open the "configs.json" file located in "ProjectIgnis/config" in Notepad or an alternative Text Editor (e.g. Notepad++).
2. Copy the following after the "Puzzles" block

        ,
            {
              "url": "https://github.com/Eronan/Eronan-Customs",
              "repo_name": "Eronan Custom Cards",
              "repo_path": "./repositories/Eronan Customs",
              "should_update": true,
              "should_read": true
            }

3. It should look like this. The file's "repos" section should now look like this:

        "repos": [
          {
            "url": "https://github.com/ProjectIgnis/DeltaUtopia",
            "repo_name": "Project Ignis updates",
            "repo_path": "./repositories/delta-utopia",
            "has_core": true,
            "core_path": "bin",
            "data_path": "",
            "script_path": "script",
            "should_update": true,
            "should_read": true
          },
          {
            "url": "https://github.com/ProjectIgnis/LFLists",
            "repo_name": "Forbidden & Limited Card Lists",
            "repo_path": "./repositories/lflists",
            "lflist_path": ".",
            "should_update": true,
            "should_read": true
          },
          {
            "url": "https://github.com/ProjectIgnis/Puzzles",
            "repo_name": "Project Ignis puzzles",
            "repo_path": "./puzzles/Canon collection",
            "should_update": true,
            "should_read": true
          },
          {
            "url": "https://github.com/Eronan/Eronan-Customs",
            "repo_name": "Eronan Custom Cards",
            "repo_path": "./repositories/Eronan Customs",
            "should_update": true,
            "should_read": true
          }
        ],

4. Save the File, and Run EDOPro and wait for the files to download.
