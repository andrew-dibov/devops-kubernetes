```bash
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

sudo chmod +x bash/* && ./bash/init.sh
source aws.env # для работы
```