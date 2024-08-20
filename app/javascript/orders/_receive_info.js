document.addEventListener('turbo:load', function() {
  const select = document.getElementById('address-select');
  const addAddressButton = document.getElementById('add_address_button');
  
  if (select) {
    const selectWrapper = select.closest('.select-wrapper');
    select.addEventListener('focus', function() {
      selectWrapper.classList.add('open');
    });
    select.addEventListener('blur', function() {
      setTimeout(() => {
        selectWrapper.classList.remove('open');
      }, 200);
    });
    select.addEventListener('change', function() {
      selectWrapper.classList.remove('open');
    });
  }

  const popup = document.getElementById('addressPopup');
  const openPopupBtn = document.getElementById('openPopupBtn');
  const closePopupBtn = document.querySelector('.close-popup');

  if (openPopupBtn) {
    openPopupBtn.addEventListener('click', function() {
      popup.style.display = 'flex';
    });
  }

  if (closePopupBtn) {
    closePopupBtn.addEventListener('click', function() {
      popup.style.display = 'none';
    });
  }

  window.addEventListener('click', function(event) {
    if (event.target === popup) {
      popup.style.display = 'none';
    }
  });

  const form = document.querySelector('#new_address_form');
  if (form) {
    form.addEventListener('submit', function(event) {
      event.preventDefault();
      const formData = new FormData(form);

      $.ajax({
        url: form.action,
        type: 'POST',
        data: formData,
        contentType: false,
        processData: false,
        headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
        dataType: 'json',
        success: function(data) {
          if (data.success) {
            const select = document.getElementById('address-select');
            if (select) {
              const newOption = document.createElement('option');
              newOption.value = data.address_id;
              newOption.text = data.place;
              select.add(newOption);
              select.value = data.address_id;
            }
            form.reset();
            popup.style.display = 'none';
            toastr.success(); 
          } else {
            toastr.error();
          }
        },
        error: function(xhr, status, error) {
          toastr.error();
        }
      });
    });
  }
});
