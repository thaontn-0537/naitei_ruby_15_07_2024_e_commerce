document.addEventListener("turbo:load", function() {
  const checkboxes = document.querySelectorAll(".product-checkbox");

  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", function() {
      this.closest("form").requestSubmit();
    });
  });
});
