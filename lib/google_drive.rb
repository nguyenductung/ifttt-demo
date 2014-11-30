class GoogleDrive
  class << self
    def upload_photo client, photo, title, description, folder, mime_type = "image/png"
      drive = client.discovered_api('drive', 'v2')
      result = client.execute(
        api_method: drive.files.list,
        parameters: {
          q: "title = '#{folder}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
          fields: "items/id"
        }
      )
      items = result.data.items
      if items.present?
        folder_id = items.first.id
      else
        new_folder = drive.files.insert.request_schema.new(
          {
            'title' => folder,
            'mimeType' => "application/vnd.google-apps.folder"
          }
        )
        result = client.execute(
          api_method: drive.files.insert,
          body_object: new_folder,
          parameters: {
            fields: "id"
          }
        )
        folder_id = result.data.id
      end

      file = drive.files.insert.request_schema.new(
        {
          'title' => title,
          'description' => description,
          'mimeType' => mime_type,
          'parents' => [{'id' => folder_id}]
        }
      )

      media = Google::APIClient::UploadIO.new(photo, mime_type)
      result = client.execute(
        api_method: drive.files.insert,
        body_object: file,
        media: media,
        parameters: {
          'uploadType' => 'multipart',
          'alt' => 'json'
        }
      )
    end
  end
end