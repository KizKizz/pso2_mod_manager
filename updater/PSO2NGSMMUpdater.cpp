#include <iostream>
#include <windows.h>
#include <fstream>
#include <filesystem>

using namespace std;
namespace fs = std::filesystem;

int main(int argc, char* argv[])
{
    if (argc != 3) {
        cout << "Please run PSO2NGSModManager.exe instead" << endl;
        return 0;
    }
    else {
        string parentApp = argv[1];
        string verString = argv[2];
        string curDirPath = argv[3];

        if (parentApp != "PSO2NGSModManager") {
            cout << "Please run PSO2NGSModManager.exe instead" << endl;
            return 0;
        }
        else {
            system("taskkill /im PSO2NGSModManager.exe");
            Sleep(500);

            fs::copy(curDirPath + "/appUpdate/PSO2NGSModManager_v" + verString + "/PSO2NGSModManager", curDirPath, fs::copy_options::overwrite_existing);
            Sleep(100);

            string mmExePath = curDirPath + "/PSO2NGSModManager.exe";
            system(mmExePath.c_str());
        }
    }
}