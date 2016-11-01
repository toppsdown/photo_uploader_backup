
$('#upload_widget_opener').cloudinary_upload_widget(
  {
  cloud_name: 'demo',
  upload_preset: 'test1234',
  cropping: 'server',
  cropping_aspect_ratio: 3.4
  folder: 'user_photos'
  },
  (error, result) -> console.log(error, result)
);
