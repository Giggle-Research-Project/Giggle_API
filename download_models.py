import os
import gdown

def download_gdrive_folder(folder_url, destination_folder):
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    # Get the folder ID from the shared URL
    folder_id = folder_url.split('/')[-1].split('?')[0]  # Remove query parameters
    
    # Use gdown to recursively download the folder
    gdown.download_folder(f"https://drive.google.com/drive/folders/{folder_id}", output=destination_folder, quiet=False)

    print(f"Download completed: {destination_folder}")

# Google Drive folder URL
folder_url = "https://drive.google.com/drive/folders/1HnswSUtmuAL2FNsVJm8ky2pWmD_mVZaC?usp=sharing"
destination_folder = "/code/models"  # Use absolute path in Docker

# Download the folder
download_gdrive_folder(folder_url, destination_folder)