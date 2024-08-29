document.addEventListener('DOMContentLoaded', function() {
  var imageInput = document.getElementById('image_input');
  var previewImage = document.getElementById('preview_image');

  imageInput.addEventListener('change', function(event) {
    var reader = new FileReader();

    reader.onload = function() {
      previewImage.src = reader.result;
      previewImage.style.display = 'block';
    }

    if (imageInput.files && imageInput.files[0]) {
      reader.readAsDataURL(imageInput.files[0]);
    }
  });
});
